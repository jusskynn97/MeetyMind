"""
Hệ thống Q&A cho các cuộc họp sử dụng OpenAI-compatible API
Hỗ trợ: Ollama, vLLM, LocalAI, text-generation-webui, và các server tương thích khác

Yêu cầu cài đặt:
pip install openai langchain chromadb sentence-transformers python-dotenv
"""

import json
import os
from typing import List, Dict, Optional, Any
from datetime import datetime
import chromadb
from chromadb.config import Settings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.prompts import PromptTemplate
from langchain.chains import RetrievalQA
from langchain.llms.base import LLM
from langchain.callbacks.manager import CallbackManagerForLLMRun
import openai


class OpenAICompatibleLLM(LLM):
    """Custom LLM wrapper cho OpenAI-compatible API"""
    
    client: openai.OpenAI = None
    model_name: str = "gemma2:9b"
    temperature: float = 0.3
    max_tokens: int = 2000
    
    def __init__(
        self,
        base_url: str,
        api_key: str = "anything",
        model_name: str = "gemma2:9b",
        temperature: float = 0.3,
        max_tokens: int = 2000
    ):
        super().__init__()
        self.client = openai.OpenAI(
            base_url=base_url,
            api_key=api_key
        )
        self.model_name = model_name
        self.temperature = temperature
        self.max_tokens = max_tokens
    
    @property
    def _llm_type(self) -> str:
        return "openai_compatible"
    
    def _call(
        self,
        prompt: str,
        stop: Optional[List[str]] = None,
        run_manager: Optional[CallbackManagerForLLMRun] = None,
        **kwargs
    ) -> str:
        """Gọi API để generate text"""
        try:
            response = self.client.chat.completions.create(
                model=self.model_name,
                messages=[{"role": "user", "content": prompt}],
                temperature=self.temperature,
                max_tokens=self.max_tokens,
                stop=stop
            )
            return response.choices[0].message.content
        except Exception as e:
            return f"Lỗi khi gọi LLM: {str(e)}"


class MeetingQASystem:
    """Hệ thống Q&A cho transcript cuộc họp"""
    
    def __init__(
        self, 
        base_url: str,
        model_name: str = "gemma2:9b",
        api_key: str = "anything",
        temperature: float = 0.3,
        persist_directory: str = "./meeting_vectordb",
        embedding_model: str = "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
    ):
        """
        Khởi tạo hệ thống
        
        Args:
            base_url: URL của LLM server (vd: https://xxx.ngrok-free.app/v1)
            model_name: Tên model trên server
            api_key: API key (không quan trọng với local server)
            temperature: Độ sáng tạo (0.1-1.0, thấp = chính xác hơn)
            persist_directory: Thư mục lưu vector database
            embedding_model: Model embedding multilingual
        """
        print(f"🚀 Khởi tạo hệ thống")
        print(f"   Server: {base_url}")
        print(f"   Model: {model_name}")
        
        # Khởi tạo LLM
        self.llm = OpenAICompatibleLLM(
            base_url=base_url,
            api_key=api_key,
            model_name=model_name,
            temperature=temperature,
            max_tokens=2000
        )
        
        # Test connection
        try:
            test_response = self.llm._call("Hi")
            print("✅ Kết nối LLM server thành công!")
        except Exception as e:
            print(f"⚠️  Lỗi kết nối LLM server: {e}")
            print("   Vui lòng kiểm tra base_url và đảm bảo server đang chạy")
        
        # Khởi tạo Embedding model
        print("📊 Đang tải embedding model...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=embedding_model,
            model_kwargs={'device': 'cpu'},
            encode_kwargs={'normalize_embeddings': True}
        )
        
        # Khởi tạo ChromaDB với PersistentClient
        self.persist_directory = persist_directory
        os.makedirs(persist_directory, exist_ok=True)
        
        # Tạo settings cho ChromaDB
        self.chroma_settings = Settings(
            anonymized_telemetry=False,
            allow_reset=True
        )
        
        # Khởi tạo client
        self.chroma_client = chromadb.PersistentClient(
            path=persist_directory,
            settings=self.chroma_settings
        )
        
        # Text splitter
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=800,
            chunk_overlap=200,
            separators=["\n\n", "\n", ". ", " ", ""]
        )
        
        self.vectorstore = None
        self.qa_chain = None
        self.collection_name = "meetings"
        
        print("✅ Hệ thống đã sẵn sàng!")
    
    def _sanitize_metadata(self, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Chuyển đổi metadata phức tạp thành format ChromaDB chấp nhận
        ChromaDB chỉ chấp nhận: str, int, float, bool
        """
        sanitized = {}
        for key, value in metadata.items():
            if isinstance(value, (str, int, float, bool)):
                sanitized[key] = value
            elif isinstance(value, list):
                # Chuyển list thành string với separator
                sanitized[key] = ", ".join(str(item) for item in value)
            elif isinstance(value, dict):
                # Chuyển dict thành JSON string
                sanitized[key] = json.dumps(value, ensure_ascii=False)
            elif value is None:
                # Skip None values
                continue
            else:
                # Convert khác thành string
                sanitized[key] = str(value)
        return sanitized
    
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
            meeting_metadata: Metadata bổ sung
        """
        print(f"\n📝 Đang xử lý cuộc họp: {meeting_id}")
        
        # Xử lý transcript
        meeting_text = self.process_transcript(transcript_data)
        
        # Chia nhỏ text
        chunks = self.text_splitter.split_text(meeting_text)
        print(f"   Chia thành {len(chunks)} chunks")
        
        # Metadata - QUAN TRỌNG: Sanitize metadata
        metadata = meeting_metadata or {}
        metadata['meeting_id'] = meeting_id
        metadata['total_chunks'] = len(chunks)
        
        # Sanitize metadata để loại bỏ list/dict
        metadata = self._sanitize_metadata(metadata)
        
        metadatas = [
            {**metadata, 'chunk_index': i} 
            for i in range(len(chunks))
        ]
        
        # Tạo/cập nhật vectorstore
        if self.vectorstore is None:
            print("   Tạo vector database mới...")
            # Sử dụng client đã tạo sẵn
            self.vectorstore = Chroma(
                client=self.chroma_client,
                collection_name=self.collection_name,
                embedding_function=self.embeddings
            )
            # Thêm texts
            self.vectorstore.add_texts(
                texts=chunks,
                metadatas=metadatas
            )
        else:
            print("   Thêm vào database...")
            self.vectorstore.add_texts(
                texts=chunks,
                metadatas=metadatas
            )
        
        # Tạo QA chain
        self._create_qa_chain()
        
        print(f"✅ Đã thêm cuộc họp {meeting_id}")
    
    def _create_qa_chain(self):
        """Tạo RetrievalQA chain"""
        
        prompt_template = """Bạn là trợ lý AI chuyên phân tích cuộc họp.
Dựa trên thông tin dưới đây, hãy trả lời câu hỏi chính xác và chi tiết.

Nếu không tìm thấy thông tin, hãy nói rõ "Tôi không tìm thấy thông tin này trong cuộc họp."

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
                search_kwargs={"k": 5}
            ),
            chain_type_kwargs={"prompt": PROMPT},
            return_source_documents=True
        )
    
    def load_existing_meetings(self):
        """Load các cuộc họp đã lưu"""
        try:
            # Sử dụng client đã có
            self.vectorstore = Chroma(
                client=self.chroma_client,
                collection_name=self.collection_name,
                embedding_function=self.embeddings
            )
            
            # Kiểm tra có dữ liệu không
            count = self.vectorstore._collection.count()
            if count == 0:
                print("⚠️  Database trống")
                self.vectorstore = None
                return False
            
            self._create_qa_chain()
            print(f"✅ Đã load {count} chunks từ database!")
            return True
        except Exception as e:
            print(f"⚠️  Lỗi load database: {e}")
            self.vectorstore = None
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
            meeting_id: ID cuộc họp cụ thể (None = tìm tất cả)
            
        Returns:
            Dict chứa answer và sources
        """
        if self.qa_chain is None:
            return {
                "answer": "Vui lòng thêm cuộc họp trước!",
                "sources": []
            }
        
        # Filter theo meeting_id nếu có
        if meeting_id:
            self.qa_chain.retriever.search_kwargs = {
                "k": 5,
                "filter": {"meeting_id": meeting_id}
            }
        else:
            self.qa_chain.retriever.search_kwargs = {"k": 5}
        
        # Query
        result = self.qa_chain.invoke({"query": question})
        
        # Extract sources
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
        """Liệt kê tất cả meeting_id"""
        if self.vectorstore is None:
            return []
        
        try:
            results = self.vectorstore.get()
            meeting_ids = set()
            
            for metadata in results.get('metadatas', []):
                if 'meeting_id' in metadata:
                    meeting_ids.add(metadata['meeting_id'])
            
            return sorted(list(meeting_ids))
        except Exception as e:
            print(f"⚠️  Lỗi list meetings: {e}")
            return []
    
    def reset_database(self):
        """Reset toàn bộ database - XÓA TẤT CẢ DỮ LIỆU"""
        try:
            # Xóa collection
            if self.vectorstore is not None:
                self.chroma_client.delete_collection(self.collection_name)
                print(f"✅ Đã xóa collection '{self.collection_name}'")
            
            # Reset vectorstore
            self.vectorstore = None
            self.qa_chain = None
            
            print("✅ Database đã được reset!")
            return True
        except Exception as e:
            print(f"⚠️  Lỗi reset database: {e}")
            return False
    
    def delete_meeting(self, meeting_id: str) -> bool:
        """Xóa một cuộc họp khỏi database"""
        if self.vectorstore is None:
            print("⚠️  Database trống!")
            return False
        
        try:
            # Get all IDs with matching meeting_id
            results = self.vectorstore.get(
                where={"meeting_id": meeting_id}
            )
            
            ids_to_delete = results.get('ids', [])
            
            if not ids_to_delete:
                print(f"⚠️  Không tìm thấy meeting: {meeting_id}")
                return False
            
            # Delete
            self.vectorstore.delete(ids=ids_to_delete)
            print(f"✅ Đã xóa {len(ids_to_delete)} chunks của meeting '{meeting_id}'")
            
            # Recreate QA chain
            if self.vectorstore._collection.count() > 0:
                self._create_qa_chain()
            else:
                self.vectorstore = None
                self.qa_chain = None
                print("⚠️  Database đã trống")
            
            return True
        except Exception as e:
            print(f"⚠️  Lỗi xóa meeting: {e}")
            return False


def main():
    """Demo sử dụng với ngrok server"""
    
    # ============== CẤU HÌNH ==============
    # Thay đổi các thông số này theo server của bạn
    BASE_URL = "https://7eaa6f818dea.ngrok-free.app/v1"  # URL server LLM
    MODEL_NAME = "gemma2:9b"  # Tên model trên server
    API_KEY = "anything"  # API key (không quan trọng với local)
    # ======================================
    
    # Khởi tạo hệ thống
    system = MeetingQASystem(
        base_url=BASE_URL,
        model_name=MODEL_NAME,
        api_key=API_KEY,
        temperature=0.3,
        persist_directory="./meeting_vectordb"
    )
    
    # Load database cũ hoặc tạo mới
    system.load_existing_meetings()
    
    # Thêm cuộc họp mẫu
    sample_transcript = {
        "segments": [
            {
                "start": 0.0,
                "end": 5.0,
                "text": "Chào buổi sáng team. Hôm nay chúng ta review sprint vừa rồi.",
                "speaker": "SPEAKER_01"
            },
            {
                "start": 5.0,
                "end": 12.0,
                "text": "Sprint này team hoàn thành được 15 tickets, có 3 bugs critical đã fix.",
                "speaker": "SPEAKER_01"
            },
            {
                "start": 12.0,
                "end": 18.0,
                "text": "Tuy nhiên test coverage mới đạt 65%, cần cải thiện lên 80%.",
                "speaker": "SPEAKER_02"
            },
            {
                "start": 18.0,
                "end": 25.0,
                "text": "Sprint tới mục tiêu là tăng coverage lên 80% và refactor module authentication.",
                "speaker": "SPEAKER_01"
            }
        ]
    }
    
    # Thêm cuộc họp - participants sẽ được tự động chuyển thành string
    system.add_meeting(
        meeting_id="tech_sprint_2026_01",
        transcript_data=sample_transcript,
        meeting_metadata={
            "title": "Sprint Review - Tech Team",
            "date": "2026-01-01",
            "participants": ["SPEAKER_01", "SPEAKER_02"]  # List sẽ được chuyển thành "SPEAKER_01, SPEAKER_02"
        }
    )
    
    # Interactive mode
    print("\n" + "="*60)
    print("💬 Chế độ hỏi đáp - Gõ 'exit' để thoát")
    print("   Gõ 'list' để xem danh sách cuộc họp")
    print("="*60)
    
    while True:
        print("\n" + "-"*60)
        
        cmd = input("\n💬 Nhập lệnh hoặc câu hỏi: ").strip()
        
        if cmd.lower() in ['exit', 'quit']:
            print("👋 Tạm biệt!")
            break
        
        if cmd.lower() == 'list':
            meetings = system.list_meetings()
            print(f"\n📋 Danh sách {len(meetings)} cuộc họp:")
            for i, m in enumerate(meetings, 1):
                print(f"   {i}. {m}")
            continue
        
        if not cmd:
            continue
        
        # Hỏi meeting ID
        meeting_id = input("🎯 Meeting ID (Enter = tất cả): ").strip()
        
        # Query
        print("\n🤔 Đang tìm kiếm...")
        result = system.query_meeting(
            cmd, 
            meeting_id if meeting_id else None
        )
        
        print(f"\n💡 Trả lời:\n{result['answer']}")
        
        # Sources
        if result['sources']:
            show = input("\n📚 Xem nguồn? (y/n): ").strip().lower()
            if show == 'y':
                print(f"\nTìm thấy {len(result['sources'])} nguồn:")
                for i, src in enumerate(result['sources'], 1):
                    print(f"\n[{i}] Meeting: {src['metadata'].get('meeting_id')}")
                    print(f"    Chunk {src['metadata'].get('chunk_index')}")
                    print(f"    {src['content']}")


if __name__ == "__main__":
    """
    Hướng dẫn sử dụng với ngrok/server khác:
    
    1. Khởi động LLM server của bạn (Ollama, vLLM, etc.)
    
    2. Expose qua ngrok (nếu cần):
       ngrok http 11434
    
    3. Lấy URL và cập nhật BASE_URL trong code:
       BASE_URL = "https://xxx.ngrok-free.app/v1"
    
    4. Cài đặt dependencies:
       pip install openai langchain chromadb sentence-transformers
    
    5. Chạy:
       python meeting_qa.py
    
    Các server tương thích:
    - Ollama (với OpenAI compatibility)
    - vLLM
    - LocalAI
    - text-generation-webui (với OpenAI extension)
    - FastChat
    - Xinference
    
    Mẹo:
    - Temperature thấp (0.1-0.3) cho câu trả lời chính xác
    - Tăng max_tokens nếu cần câu trả lời dài
    - Sử dụng model lớn hơn cho chất lượng tốt hơn
    """
    main()