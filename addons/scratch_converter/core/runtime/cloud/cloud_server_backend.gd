class_name CloudServerBackend
extends CloudBackend

const RATE_LIMIT_MS := 100.0

const CONTACT_URL := "https://github.com/Br0tcraft/Scratch2Godot/issues"
const USER_AGENT := "GodotScratchPlayer/1.0 (+" + CONTACT_URL + ")"

var _ws: WebSocketPeer
var _host: String
var _project_id: String
var _user: String = "godot_player"

var _pending: Dictionary = {} # name -> value
var _last_sent: Dictionary = {} # name -> timestamp
var _sent_handshake: bool = false

func _init(host: String = "", project_id: String = "") -> void:
	_host = host
	_project_id = project_id

func start() -> void:
	if _host.is_empty():
		return
	_ws = WebSocketPeer.new()
	_ws.set_handshake_headers(PackedStringArray(["User-Agent: " + USER_AGENT]))
	var err := _ws.connect_to_url(_host)
func send(name: String, value: String) -> void:
	_pending[name] = value

var _last_state: int = -1

func _process(_delta: float) -> void:
	if _ws == null:
		return
	_ws.poll()

	var st := _ws.get_ready_state()
	if st != _last_state:
		_last_state = st
		var labels := ["CONNECTING", "OPEN", "CLOSING", "CLOSED"]

	if st == WebSocketPeer.STATE_OPEN and not _sent_handshake:
		_sent_handshake = true
		_send_json({"method": "handshake", "user": _user, "project_id": _project_id})

	while st == WebSocketPeer.STATE_OPEN and _ws.get_available_packet_count() > 0:
		var packet := _ws.get_packet().get_string_from_utf8()
		_handle_incoming(packet)

	_flush_pending()

func _handle_incoming(raw: String) -> void:
	for line in raw.split("\n", false):
		var json = JSON.parse_string(line)
		if not json is Dictionary:
			continue

		var method = json.get("method", "")

		if method != "set":
			continue

		var name: String = str(json.get("name", ""))
		if name.is_empty():
			continue

		var value = str(json.get("value", ""))
		value_received.emit(name, value)

func _flush_pending() -> void:
	if _ws == null or _ws.get_ready_state() != WebSocketPeer.STATE_OPEN: return
	var now := Time.get_ticks_msec()
	for name in _pending.keys():
		var last: float = _last_sent.get(name, 0.0)
		if now - last < RATE_LIMIT_MS:
			continue
		var value: String = str(_pending[name])
		_send_json({
			"method": "set", "name": name, "value": value,
			"user": _user, "project_id": _project_id,
		})
		_last_sent[name] = now
		_pending.erase(name)

func _send_json(d: Dictionary) -> void:
	if _ws and _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_ws.send_text(JSON.stringify(d))