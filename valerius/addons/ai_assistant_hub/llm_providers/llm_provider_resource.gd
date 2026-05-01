class_name LLMProviderResource
extends Resource

@export var api_id: String
@export var name: String
@export var description: String

@export_group("API key setup")
@export var requires_key: bool
@export var get_key_url: String

@export_group("URLs setup")
@export var fix_url: String
@export var models_url_postfix: String
@export var chat_url_postfix: String

@export_group("Chat setup")
@export var system_role_name:String = "system"
@export var user_role_name:String = "user"
@export var assistant_role_name:String = "assistant"
