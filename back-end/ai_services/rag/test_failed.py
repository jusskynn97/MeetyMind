"""
Hệ thống Q&A cho các cuộc họp sử dụng Local LLM với Ollama
Yêu cầu cài đặt:
pip install langchain langchain-ollama chromadb sentence-transformers python-dotenv
"""

import json
import os
from typing import List, Dict, Optional
from datetime import datetime
import chromadb
from chromadb.config import Settings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_ollama import OllamaLLM
from langchain_core.prompts import PromptTemplate
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings


class MeetingQASystem:
    """Hệ thống Q&A cho transcript cuộc họp"""
    
    def __init__(
        self, 
        model_name: str = "qwen2.5:7b",
        persist_directory: str = "./meeting_vectordb",
        embedding_model: str = "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
    ):
        """
        Khởi tạo hệ thống
        
        Args:
            model_name: Tên model Ollama (qwen2.5:7b, llama4:8b, aya-expanse:8b)
            persist_directory: Thư mục lưu vector database
            embedding_model: Model embedding (multilingual cho tiếng Việt)
        """
        print(f"🚀 Khởi tạo hệ thống với model: {model_name}")
        
        # Khởi tạo LLM
        self.llm = OllamaLLM(
            model=model_name,
            temperature=0.3,  # Giảm creativity để có câu trả lời chính xác hơn
            num_ctx=4096,     # Context window
        )
        
        # Khởi tạo Embedding model (multilingual)
        print("📊 Đang tải embedding model...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=embedding_model,
            model_kwargs={'device': 'cpu'},
            encode_kwargs={'normalize_embeddings': True}
        )
        
        # Khởi tạo ChromaDB
        self.persist_directory = persist_directory
        os.makedirs(persist_directory, exist_ok=True)
        
        self.chroma_client = chromadb.PersistentClient(
            path=persist_directory,
            settings=Settings(anonymized_telemetry=False)
        )
        
        # Text splitter để chia nhỏ transcript
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=800,
            chunk_overlap=200,
            separators=["\n\n", "\n", ". ", " ", ""]
        )
        
        self.vectorstore = None
        self.qa_chain = None
        
        print("✅ Hệ thống đã sẵn sàng!")
    
    def process_transcript(self, transcript_data: Dict) -> str:
        """
        Xử lý dữ liệu transcript từ JSON
        
        Args:
            transcript_data: Dict chứa segments từ transcript
            
        Returns:
            Formatted text của cuộc họp
        """
        segments = transcript_data.get('segments', [])
        
        formatted_text = ""
        for segment in segments:
            speaker = segment.get('speaker', 'Unknown')
            text = segment.get('text', '').strip()
            start_time = segment.get('start', 0)
            
            # Format: [HH:MM:SS] Speaker: Text
            timestamp = self._seconds_to_timestamp(start_time)
            formatted_text += f"[{timestamp}] {speaker}: {text}\n"
        
        return formatted_text
    
    def _seconds_to_timestamp(self, seconds: float) -> str:
        """Chuyển đổi giây thành HH:MM:SS"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    
    def add_meeting(
        self, 
        meeting_id: str, 
        transcript_data: Dict,
        meeting_metadata: Optional[Dict] = None
    ):
        """
        Thêm cuộc họp vào hệ thống
        
        Args:
            meeting_id: ID duy nhất của cuộc họp
            transcript_data: Dữ liệu transcript (segments)
            meeting_metadata: Metadata bổ sung (title, date, participants...)
        """
        print(f"\n📝 Đang xử lý cuộc họp: {meeting_id}")
        
        # Xử lý transcript
        meeting_text = self.process_transcript(transcript_data)
        
        # Chia nhỏ text thành chunks
        chunks = self.text_splitter.split_text(meeting_text)
        print(f"   Chia thành {len(chunks)} chunks")
        
        # Tạo metadata cho mỗi chunk
        metadata = meeting_metadata or {}
        metadata['meeting_id'] = meeting_id
        metadata['total_chunks'] = len(chunks)
        
        metadatas = [
            {**metadata, 'chunk_index': i} 
            for i in range(len(chunks))
        ]
        
        # Tạo hoặc cập nhật vectorstore
        if self.vectorstore is None:
            print("   Tạo vector database mới...")
            self.vectorstore = Chroma.from_texts(
                texts=chunks,
                embedding=self.embeddings,
                metadatas=metadatas,
                persist_directory=self.persist_directory,
                collection_name="meetings"
            )
        else:
            print("   Thêm vào vector database hiện tại...")
            self.vectorstore.add_texts(
                texts=chunks,
                metadatas=metadatas
            )
        
        # Tạo QA chain
        self._create_qa_chain()
        
        print(f"✅ Đã thêm cuộc họp {meeting_id} thành công!")
    
    def _create_qa_chain(self):
        """Tạo RetrievalQA chain"""
        
        # Prompt template tiếng Việt
        prompt_template = """Bạn là một trợ lý AI chuyên phân tích các cuộc họp. 
Dựa trên thông tin từ cuộc họp dưới đây, hãy trả lời câu hỏi một cách chính xác và chi tiết.

Nếu bạn không tìm thấy thông tin trong cuộc họp, hãy trả lời rõ ràng là "Tôi không tìm thấy thông tin này trong cuộc họp."

Thông tin từ cuộc họp:
{context}

Câu hỏi: {question}

Câu trả lời chi tiết:"""

        PROMPT = PromptTemplate(
            template=prompt_template, 
            input_variables=["context", "question"]
        )
        
        self.qa_chain = RetrievalQA.from_chain_type(
            llm=self.llm,
            chain_type="stuff",
            retriever=self.vectorstore.as_retriever(
                search_type="similarity",
                search_kwargs={"k": 5}  # Lấy 5 chunks liên quan nhất
            ),
            chain_type_kwargs={"prompt": PROMPT},
            return_source_documents=True
        )
    
    def load_existing_meetings(self):
        """Load các cuộc họp đã lưu từ database"""
        try:
            self.vectorstore = Chroma(
                persist_directory=self.persist_directory,
                embedding_function=self.embeddings,
                collection_name="meetings"
            )
            self._create_qa_chain()
            print("✅ Đã load vector database thành công!")
            return True
        except Exception as e:
            print(f"⚠️  Chưa có dữ liệu: {e}")
            return False
    
    def query_meeting(
        self, 
        question: str, 
        meeting_id: Optional[str] = None
    ) -> Dict:
        """
        Đặt câu hỏi về cuộc họp
        
        Args:
            question: Câu hỏi
            meeting_id: ID cuộc họp cụ thể (None = tìm trong tất cả)
            
        Returns:
            Dict chứa answer và sources
        """
        if self.qa_chain is None:
            return {
                "answer": "Vui lòng thêm cuộc họp trước khi đặt câu hỏi!",
                "sources": []
            }
        
        # Nếu chỉ định meeting_id, filter theo meeting
        if meeting_id:
            # Update retriever với filter
            self.qa_chain.retriever.search_kwargs = {
                "k": 5,
                "filter": {"meeting_id": meeting_id}
            }
        else:
            # Reset filter
            self.qa_chain.retriever.search_kwargs = {"k": 5}
        
        # Chạy query
        result = self.qa_chain.invoke({"query": question})
        
        # Trích xuất sources
        sources = []
        for doc in result.get("source_documents", []):
            sources.append({
                "content": doc.page_content[:200] + "...",
                "metadata": doc.metadata
            })
        
        return {
            "answer": result["result"],
            "sources": sources
        }
    
    def list_meetings(self) -> List[str]:
        """Liệt kê tất cả meeting_id trong database"""
        if self.vectorstore is None:
            return []
        
        # Query để lấy tất cả unique meeting_id
        results = self.vectorstore.get()
        meeting_ids = set()
        
        for metadata in results.get('metadatas', []):
            if 'meeting_id' in metadata:
                meeting_ids.add(metadata['meeting_id'])
        
        return sorted(list(meeting_ids))


def main():
    """Demo sử dụng hệ thống"""
    
    # Khởi tạo hệ thống
    # Các model khuyên dùng cho tiếng Việt:
    # - qwen2.5:7b (đa ngôn ngữ tốt, 4.7GB)
    # - llama4:8b (hỗ trợ Vietnamese, 4.9GB)
    # - aya-expanse:8b (multilingual, 4.9GB)
    # - nqduc/mixsura-sft (model Việt Nam chuyên biệt)
    
    system = MeetingQASystem(
        model_name="qwen2.5:7b",  # Thay đổi model ở đây
        persist_directory="./meeting_vectordb"
    )
    
    # Load database cũ nếu có
    system.load_existing_meetings()
    
    # Thêm cuộc họp mới (dữ liệu mẫu từ user)
    sample_transcript = {
        "segments": [
            {
                "start": 0.0,
                "end": 2.02,
                "text": "Chào chào bác",
                "speaker": "SPEAKER_04"
            },
            {
                "start": 2.0,
                "end": 4.02,
                "text": "Ừ, chào cháu",
                "speaker": "SPEAKER_04"
            },
            {
                "start": 4.0,
                "end": 6.02,
                "text": "Cháu đi đâu thế?",
                "speaker": "SPEAKER_04"
            },
            {
                "start": 6.0,
                "end": 8.02,
                "text": "Dạ cháu đi chơi ạ",
                "speaker": "SPEAKER_04"
            },
            {
                "start": 8.0,
                "end": 10.02,
                "text": "Chào cháu bác nhé",
                "speaker": "SPEAKER_03"
            },
            {
                "start": 10.0,
                "end": 12.02,
                "text": "Ừ, chào cháu",
                "speaker": "SPEAKER_03"
            }
        ]
    }
    
    # Thêm cuộc họp
    system.add_meeting(
        meeting_id="meeting_001",
        transcript_data=sample_transcript,
        meeting_metadata={
            "title": "Cuộc họp mẫu 1",
            "date": "2026-01-01",
            "participants": ["SPEAKER_03", "SPEAKER_04"]
        }
    )
    
    # Interactive mode
    print("\n" + "="*60)
    print("💬 Chế độ hỏi đáp - Gõ 'exit' để thoát")
    print("="*60)
    
    while True:
        print("\nDanh sách cuộc họp:", system.list_meetings())
        meeting_id = input("\n🎯 Meeting ID (Enter để tìm tất cả): ").strip()
        
        if meeting_id.lower() == 'exit':
            break
        
        question = input("❓ Câu hỏi: ").strip()
        
        if question.lower() == 'exit':
            break
        
        if not question:
            continue
        
        print("\n🤔 Đang tìm kiếm...")
        result = system.query_meeting(
            question=question,
            meeting_id=meeting_id if meeting_id else None
        )
        
        print(f"\n💡 Trả lời:\n{result['answer']}")
        
        if result['sources']:
            print(f"\n📚 Nguồn tham khảo ({len(result['sources'])} chunks):")
            for i, source in enumerate(result['sources'][:3], 1):
                print(f"\n  [{i}] Meeting: {source['metadata'].get('meeting_id')}")
                print(f"      {source['content']}")


if __name__ == "__main__":
    """
    Hướng dẫn cài đặt và sử dụng:
    
    1. Cài đặt Ollama:
       - MacOS/Linux: curl -fsSL https://ollama.com/install.sh | sh
       - Windows: Tải từ https://ollama.com/download
    
    2. Pull model (chọn 1):
       ollama pull qwen2.5:7b          # Multilingual tốt, 4.7GB
       ollama pull llama4:8b            # Hỗ trợ Vietnamese
       ollama pull aya-expanse:8b       # Multilingual
    
    3. Cài đặt dependencies:
       pip install langchain langchain-ollama chromadb sentence-transformers
    
    4. Chạy:
       python meeting_qa.py
    
    Mẹo tối ưu:
    - Sử dụng GPU nếu có: embeddings với model_kwargs={'device': 'cuda'}
    - Điều chỉnh chunk_size dựa trên độ dài transcript
    - Temperature thấp (0.1-0.3) cho câu trả lời chính xác
    - Temperature cao (0.7-0.9) cho câu trả lời sáng tạo
    """
    main()