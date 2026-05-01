class_name AIAssistantResource
extends Resource

@export var type_name: String

@export var type_icon: Texture2D

@export var ai_model: String

@export var llm_provider: LLMProviderResource

@export_multiline var ai_description: String = "You are a useful Godot AI assistant." 

@export var use_custom_temperature: bool = false

@export_range(0.0, 1.0) var custom_temperature := 0.5

@export var quick_prompts: Array[AIQuickPromptResource]
