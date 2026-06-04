import openai

client = openai.OpenAI(
    base_url="https://7eaa6f818dea.ngrok-free.app/v1",  # Thay bằng public_url từ Colab
    api_key="anything"  # Ollama không cần key thật
)

response = client.chat.completions.create(
    model="gemma2:9b",
    messages=[{"role": "user", "content": "cho tôi một quy trình về phát triển phần mềm chuyên nghiệp"}]
)

print(response.choices[0].message.content)