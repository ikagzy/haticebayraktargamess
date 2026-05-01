class_name AIQuickPromptResource
extends Resource

enum ResponseTarget { Chat, CodeEditor, OnlyCodeToCodeEditor }
enum CodePlacement { BeforeSelection, AfterSelection, ReplaceSelection }

@export var action_name: String

@export_multiline var action_prompt: String

@export var icon: Texture2D

@export var response_target: ResponseTarget

@export var code_placement: CodePlacement

@export var format_response_as_comment: bool
