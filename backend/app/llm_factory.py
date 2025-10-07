from langchain_core.language_models import BaseChatModel


class LLMFactory:
    """Factory for creating LLM instances based on provider configuration."""

    @staticmethod
    def create_llm(provider: str, **config) -> BaseChatModel:
        """
        Create an LLM instance based on the provider type.

        Args:
            provider: The LLM provider type ('ollama' or 'azure')
            **config: Provider-specific configuration parameters

        Returns:
            BaseChatModel: An instance of the appropriate LLM

        Raises:
            ValueError: If the provider is not supported
        """
        if provider == "ollama":
            from langchain_ollama import ChatOllama

            return ChatOllama(
                model=config.get("model", "llama3.2"),
                base_url=config.get("base_url", "http://localhost:11434"),
                temperature=config.get("temperature", 0.7),
            )
        elif provider == "azure":
            from langchain_openai import AzureChatOpenAI

            return AzureChatOpenAI(
                azure_endpoint=config["endpoint"],
                api_key=config["api_key"],
                azure_deployment=config["deployment_name"],
                api_version=config.get("api_version", "2024-08-01-preview"),
                temperature=config.get("temperature", 0.7),
            )
        else:
            raise ValueError(f"Unsupported LLM provider: {provider}")
