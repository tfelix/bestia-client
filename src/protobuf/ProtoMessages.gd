const PROTO_VERSION = 3

#
# BSD 3-Clause License
#
# Copyright (c) 2018, Oleg Malyavkin
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# DEBUG_TAB redefine this "  " if you need, example: const DEBUG_TAB = "\t"
const DEBUG_TAB = "  "

enum PB_ERR {
	NO_ERRORS = 0,
	VARINT_NOT_FOUND = -1,
	REPEATED_COUNT_NOT_FOUND = -2,
	REPEATED_COUNT_MISMATCH = -3,
	LENGTHDEL_SIZE_NOT_FOUND = -4,
	LENGTHDEL_SIZE_MISMATCH = -5,
	PACKAGE_SIZE_MISMATCH = -6,
	UNDEFINED_STATE = -7,
	PARSE_INCOMPLETE = -8,
	REQUIRED_FIELDS = -9
}

enum PB_DATA_TYPE {
	INT32 = 0,
	SINT32 = 1,
	UINT32 = 2,
	INT64 = 3,
	SINT64 = 4,
	UINT64 = 5,
	BOOL = 6,
	ENUM = 7,
	FIXED32 = 8,
	SFIXED32 = 9,
	FLOAT = 10,
	FIXED64 = 11,
	SFIXED64 = 12,
	DOUBLE = 13,
	STRING = 14,
	BYTES = 15,
	MESSAGE = 16,
	MAP = 17
}

const DEFAULT_VALUES_2 = {
	PB_DATA_TYPE.INT32: null,
	PB_DATA_TYPE.SINT32: null,
	PB_DATA_TYPE.UINT32: null,
	PB_DATA_TYPE.INT64: null,
	PB_DATA_TYPE.SINT64: null,
	PB_DATA_TYPE.UINT64: null,
	PB_DATA_TYPE.BOOL: null,
	PB_DATA_TYPE.ENUM: null,
	PB_DATA_TYPE.FIXED32: null,
	PB_DATA_TYPE.SFIXED32: null,
	PB_DATA_TYPE.FLOAT: null,
	PB_DATA_TYPE.FIXED64: null,
	PB_DATA_TYPE.SFIXED64: null,
	PB_DATA_TYPE.DOUBLE: null,
	PB_DATA_TYPE.STRING: null,
	PB_DATA_TYPE.BYTES: null,
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: null
}

const DEFAULT_VALUES_3 = {
	PB_DATA_TYPE.INT32: 0,
	PB_DATA_TYPE.SINT32: 0,
	PB_DATA_TYPE.UINT32: 0,
	PB_DATA_TYPE.INT64: 0,
	PB_DATA_TYPE.SINT64: 0,
	PB_DATA_TYPE.UINT64: 0,
	PB_DATA_TYPE.BOOL: false,
	PB_DATA_TYPE.ENUM: 0,
	PB_DATA_TYPE.FIXED32: 0,
	PB_DATA_TYPE.SFIXED32: 0,
	PB_DATA_TYPE.FLOAT: 0.0,
	PB_DATA_TYPE.FIXED64: 0,
	PB_DATA_TYPE.SFIXED64: 0,
	PB_DATA_TYPE.DOUBLE: 0.0,
	PB_DATA_TYPE.STRING: "",
	PB_DATA_TYPE.BYTES: [],
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: []
}

enum PB_TYPE {
	VARINT = 0,
	FIX64 = 1,
	LENGTHDEL = 2,
	STARTGROUP = 3,
	ENDGROUP = 4,
	FIX32 = 5,
	UNDEFINED = 8
}

enum PB_RULE {
	OPTIONAL = 0,
	REQUIRED = 1,
	REPEATED = 2,
	RESERVED = 3
}

enum PB_SERVICE_STATE {
	FILLED = 0,
	UNFILLED = 1
}

class PBField:
	func _init(a_name, a_type, a_rule, a_tag, packed, a_value = null):
		name = a_name
		type = a_type
		rule = a_rule
		tag = a_tag
		option_packed = packed
		value = a_value
	var name
	var type
	var rule
	var tag
	var option_packed
	var value
	var option_default = false

class PBLengthDelimitedField:
	var type = null
	var tag = null
	var begin = null
	var size = null

class PBUnpackedField:
	var offset
	var field

class PBTypeTag:
	var type = null
	var tag = null
	var offset = null

class PBServiceField:
	var field
	var func_ref = null
	var state = PB_SERVICE_STATE.UNFILLED

class PBPacker:
	static func convert_signed(n):
		if n < -2147483648:
			return (n << 1) ^ (n >> 63)
		else:
			return (n << 1) ^ (n >> 31)

	static func deconvert_signed(n):
		if n & 0x01:
			return ~(n >> 1)
		else:
			return (n >> 1)

	static func pack_varint(value):
		var varint = PoolByteArray()
		if typeof(value) == TYPE_BOOL:
			if value:
				value = 1
			else:
				value = 0
		for i in range(9):
			var b = value & 0x7F
			value >>= 7
			if value:
				varint.append(b | 0x80)
			else:
				varint.append(b)
				break
		if varint.size() == 9 && varint[8] == 0xFF:
			varint.append(0x01)
		return varint

	static func pack_bytes(value, count, data_type):
		var bytes = PoolByteArray()
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb = StreamPeerBuffer.new()
			spb.put_float(value)
			bytes = spb.get_data_array()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb = StreamPeerBuffer.new()
			spb.put_double(value)
			bytes = spb.get_data_array()
		else:
			for i in range(count):
				bytes.append(value & 0xFF)
				value >>= 8
		return bytes

	static func unpack_bytes(bytes, index, count, data_type):
		var value = 0
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_float()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_double()
		else:
			for i in range(index + count - 1, index - 1, -1):
				value |= (bytes[i] & 0xFF)
				if i != index:
					value <<= 8
		return value

	static func unpack_varint(varint_bytes):
		var value = 0
		for i in range(varint_bytes.size() - 1, -1, -1):
			value |= varint_bytes[i] & 0x7F
			if i != 0:
				value <<= 7
		return value

	static func pack_type_tag(type, tag):
		return pack_varint((tag << 3) | type)

	static func isolate_varint(bytes, index):
		var result = PoolByteArray()
		for i in range(index, bytes.size()):
			result.append(bytes[i])
			if !(bytes[i] & 0x80):
				break
		return result

	static func unpack_type_tag(bytes, index):
		var varint_bytes = isolate_varint(bytes, index)
		var result = PBTypeTag.new()
		if varint_bytes.size() != 0:
			result.offset = varint_bytes.size()
			var unpacked = unpack_varint(varint_bytes)
			result.type = unpacked & 0x07
			result.tag = unpacked >> 3
		return result

	static func pack_length_delimeted(type, tag, bytes):
		var result = pack_type_tag(type, tag)
		result.append_array(pack_varint(bytes.size()))
		result.append_array(bytes)
		return result

	static func unpack_length_delimiter(bytes, index):
		var result = PBLengthDelimitedField.new()
		var type_tag = unpack_type_tag(bytes, index)
		var offset = type_tag.offset
		if offset != null:
			result.type = type_tag.type
			result.tag = type_tag.tag
			var size = isolate_varint(bytes, offset)
			if size > 0:
				offset += size
				if bytes.size() >= size + offset:
					result.begin = offset
					result.size = size
		return result

	static func pb_type_from_data_type(data_type):
		if data_type == PB_DATA_TYPE.INT32 || data_type == PB_DATA_TYPE.SINT32 || data_type == PB_DATA_TYPE.UINT32 || data_type == PB_DATA_TYPE.INT64 || data_type == PB_DATA_TYPE.SINT64 || data_type == PB_DATA_TYPE.UINT64 || data_type == PB_DATA_TYPE.BOOL || data_type == PB_DATA_TYPE.ENUM:
			return PB_TYPE.VARINT
		elif data_type == PB_DATA_TYPE.FIXED32 || data_type == PB_DATA_TYPE.SFIXED32 || data_type == PB_DATA_TYPE.FLOAT:
			return PB_TYPE.FIX32
		elif data_type == PB_DATA_TYPE.FIXED64 || data_type == PB_DATA_TYPE.SFIXED64 || data_type == PB_DATA_TYPE.DOUBLE:
			return PB_TYPE.FIX64
		elif data_type == PB_DATA_TYPE.STRING || data_type == PB_DATA_TYPE.BYTES || data_type == PB_DATA_TYPE.MESSAGE || data_type == PB_DATA_TYPE.MAP:
			return PB_TYPE.LENGTHDEL
		else:
			return PB_TYPE.UNDEFINED

	static func pack_field(field):
		var type = pb_type_from_data_type(field.type)
		var type_copy = type
		if field.rule == PB_RULE.REPEATED && field.option_packed:
			type = PB_TYPE.LENGTHDEL
		var head = pack_type_tag(type, field.tag)
		var data = PoolByteArray()
		if type == PB_TYPE.VARINT:
			var value
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						value = convert_signed(v)
					else:
						value = v
					data.append_array(pack_varint(value))
				return data
			else:
				if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
					value = convert_signed(field.value)
				else:
					value = field.value
				data = pack_varint(value)
		elif type == PB_TYPE.FIX32:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 4, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 4, field.type))
		elif type == PB_TYPE.FIX64:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 8, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 8, field.type))
		elif type == PB_TYPE.LENGTHDEL:
			if field.rule == PB_RULE.REPEATED:
				if type_copy == PB_TYPE.VARINT:
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						var signed_value
						for v in field.value:
							signed_value = convert_signed(v)
							data.append_array(pack_varint(signed_value))
					else:
						for v in field.value:
							data.append_array(pack_varint(v))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX32:
					for v in field.value:
						data.append_array(pack_bytes(v, 4, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX64:
					for v in field.value:
						data.append_array(pack_bytes(v, 8, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif field.type == PB_DATA_TYPE.STRING:
					for v in field.value:
						var obj = v.to_utf8()
						data.append_array(pack_length_delimeted(type, field.tag, obj))
					return data
				elif field.type == PB_DATA_TYPE.BYTES:
					for v in field.value:
						data.append_array(pack_length_delimeted(type, field.tag, v))
					return data
				elif typeof(field.value[0]) == TYPE_OBJECT:
					for v in field.value:
						var obj = v.to_bytes()
						#if obj != null && obj.size() > 0:
						#	data.append_array(pack_length_delimeted(type, field.tag, obj))
						#else:
						#	data = PoolByteArray()
						#	return data
						if obj != null:#
							data.append_array(pack_length_delimeted(type, field.tag, obj))#
						else:#
							data = PoolByteArray()#
							return data#
					return data
			else:
				if field.type == PB_DATA_TYPE.STRING:
					var str_bytes = field.value.to_utf8()
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && str_bytes.size() > 0):
						data.append_array(str_bytes)
						return pack_length_delimeted(type, field.tag, data)
				if field.type == PB_DATA_TYPE.BYTES:
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && field.value.size() > 0):
						data.append_array(field.value)
						return pack_length_delimeted(type, field.tag, data)
				elif typeof(field.value) == TYPE_OBJECT:
					var obj = field.value.to_bytes()
					#if obj != null && obj.size() > 0:
					#	data.append_array(obj)
					#	return pack_length_delimeted(type, field.tag, data)
					if obj != null:#
						if obj.size() > 0:#
							data.append_array(obj)#
						return pack_length_delimeted(type, field.tag, data)#
				else:
					pass
		if data.size() > 0:
			head.append_array(data)
			return head
		else:
			return data

	static func unpack_field(bytes, offset, field, type, message_func_ref):
		if field.rule == PB_RULE.REPEATED && type != PB_TYPE.LENGTHDEL && field.option_packed:
			var count = isolate_varint(bytes, offset)
			if count.size() > 0:
				offset += count.size()
				count = unpack_varint(count)
				if type == PB_TYPE.VARINT:
					var val
					var counter = offset + count
					while offset < counter:
						val = isolate_varint(bytes, offset)
						if val.size() > 0:
							offset += val.size()
							val = unpack_varint(val)
							if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
								val = deconvert_signed(val)
							elif field.type == PB_DATA_TYPE.BOOL:
								if val:
									val = true
								else:
									val = false
							field.value.append(val)
						else:
							return PB_ERR.REPEATED_COUNT_MISMATCH
					return offset
				elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
					var type_size
					if type == PB_TYPE.FIX32:
						type_size = 4
					else:
						type_size = 8
					var val
					var counter = offset + count
					while offset < counter:
						if (offset + type_size) > bytes.size():
							return PB_ERR.REPEATED_COUNT_MISMATCH
						val = unpack_bytes(bytes, offset, type_size, field.type)
						offset += type_size
						field.value.append(val)
					return offset
			else:
				return PB_ERR.REPEATED_COUNT_NOT_FOUND
		else:
			if type == PB_TYPE.VARINT:
				var val = isolate_varint(bytes, offset)
				if val.size() > 0:
					offset += val.size()
					val = unpack_varint(val)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						val = deconvert_signed(val)
					elif field.type == PB_DATA_TYPE.BOOL:
						if val:
							val = true
						else:
							val = false
					if field.rule == PB_RULE.REPEATED:
						field.value.append(val)
					else:
						field.value = val
				else:
					return PB_ERR.VARINT_NOT_FOUND
				return offset
			elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
				var type_size
				if type == PB_TYPE.FIX32:
					type_size = 4
				else:
					type_size = 8
				var val
				if (offset + type_size) > bytes.size():
					return PB_ERR.REPEATED_COUNT_MISMATCH
				val = unpack_bytes(bytes, offset, type_size, field.type)
				offset += type_size
				if field.rule == PB_RULE.REPEATED:
					field.value.append(val)
				else:
					field.value = val
				return offset
			elif type == PB_TYPE.LENGTHDEL:
				var inner_size = isolate_varint(bytes, offset)
				if inner_size.size() > 0:
					offset += inner_size.size()
					inner_size = unpack_varint(inner_size)
					if inner_size >= 0:
						if inner_size + offset > bytes.size():
							return PB_ERR.LENGTHDEL_SIZE_MISMATCH
						if message_func_ref != null:
							var message = message_func_ref.call_func()
							if inner_size > 0:
								var sub_offset = message.from_bytes(bytes, offset, inner_size + offset)
								if sub_offset > 0:
									if sub_offset - offset >= inner_size:
										offset = sub_offset
										return offset
									else:
										return PB_ERR.LENGTHDEL_SIZE_MISMATCH
								return sub_offset
							else:
								return offset
						elif field.type == PB_DATA_TYPE.STRING:
							var str_bytes = PoolByteArray()
							for i in range(offset, inner_size + offset):
								str_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(str_bytes.get_string_from_utf8())
							else:
								field.value = str_bytes.get_string_from_utf8()
							return offset + inner_size
						elif field.type == PB_DATA_TYPE.BYTES:
							var val_bytes = PoolByteArray()
							for i in range(offset, inner_size + offset):
								val_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(val_bytes)
							else:
								field.value = val_bytes
							return offset + inner_size
					else:
						return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
				else:
					return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
		return PB_ERR.UNDEFINED_STATE

	static func unpack_message(data, bytes, offset, limit):
		while true:
			var tt = unpack_type_tag(bytes, offset)
			if tt.offset != null:
				offset += tt.offset
				if data.has(tt.tag):
					var service = data[tt.tag]
					var type = pb_type_from_data_type(service.field.type)
					if type == tt.type || (tt.type == PB_TYPE.LENGTHDEL && service.field.rule == PB_RULE.REPEATED && service.field.option_packed):
						var res = unpack_field(bytes, offset, service.field, type, service.func_ref)
						if res > 0:
							service.state = PB_SERVICE_STATE.FILLED
							offset = res
							if offset == limit:
								return offset
							elif offset > limit:
								return PB_ERR.PACKAGE_SIZE_MISMATCH
						elif res < 0:
							return res
						else:
							break
			else:
				return offset
		return PB_ERR.UNDEFINED_STATE

	static func pack_message(data):
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result = PoolByteArray()
		var keys = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result.append_array(pack_field(data[i].field))
			elif data[i].field.rule == PB_RULE.REQUIRED:
				print("Error: required field is not filled: Tag:", data[i].field.tag)
				return null
		return result

	static func check_required(data):
		var keys = data.keys()
		for i in keys:
			if data[i].field.rule == PB_RULE.REQUIRED && data[i].state == PB_SERVICE_STATE.UNFILLED:
				return false
		return true

	static func construct_map(key_values):
		var result = {}
		for kv in key_values:
			result[kv.get_key()] = kv.get_value()
		return result
	
	static func tabulate(text, nesting):
		var tab = ""
		for i in range(nesting):
			tab += DEBUG_TAB
		return tab + text
	
	static func value_to_string(value, field, nesting):
		var result = ""
		var text
		if field.type == PB_DATA_TYPE.MESSAGE:
			result += "{"
			nesting += 1
			text = message_to_string(value.data, nesting)
			if text != "":
				result += "\n" + text
				nesting -= 1
				result += tabulate("}", nesting)
			else:
				nesting -= 1
				result += "}"
		elif field.type == PB_DATA_TYPE.BYTES:
			result += "<"
			for i in range(value.size()):
				result += String(value[i])
				if i != (value.size() - 1):
					result += ", "
			result += ">"
		elif field.type == PB_DATA_TYPE.STRING:
			result += "\"" + value + "\""
		elif field.type == PB_DATA_TYPE.ENUM:
			result += "ENUM::" + String(value)
		else:
			result += String(value)
		return result
	
	static func field_to_string(field, nesting):
		var result = tabulate(field.name + ": ", nesting)
		if field.type == PB_DATA_TYPE.MAP:
			if field.value.size() > 0:
				result += "(\n"
				nesting += 1
				for i in range(field.value.size()):
					var local_key_value = field.value[i].data[1].field
					result += tabulate(value_to_string(local_key_value.value, local_key_value, nesting), nesting) + ": "
					local_key_value = field.value[i].data[2].field
					result += value_to_string(local_key_value.value, local_key_value, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate(")", nesting)
			else:
				result += "()"
		elif field.rule == PB_RULE.REPEATED:
			if field.value.size() > 0:
				result += "[\n"
				nesting += 1
				for i in range(field.value.size()):
					result += tabulate(String(i) + ": ", nesting)
					result += value_to_string(field.value[i], field, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate("]", nesting)
			else:
				result += "[]"
		else:
			result += value_to_string(field.value, field, nesting)
		result += ";\n"
		return result
		
	static func message_to_string(data, nesting = 0):
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result = ""
		var keys = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result += field_to_string(data[i].field, nesting)
			elif data[i].field.rule == PB_RULE.REQUIRED:
				result += data[i].field.name + ": " + "error"
		return result


############### USER DATA BEGIN ################


class MessageSize:
	func _init():
		var service
		
		_packet_size = PBField.new("packet_size", PB_DATA_TYPE.INT32, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _packet_size
		data[_packet_size.tag] = service
		
	var data = {}
	
	var _packet_size
	func get_packet_size():
		return _packet_size.value
	func clear_packet_size():
		_packet_size.value = DEFAULT_VALUES_3[PB_DATA_TYPE.INT32]
	func set_packet_size(value):
		_packet_size.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class Wrapper:
	func _init():
		var service
		
		_auth = PBField.new("auth", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _auth
		service.func_ref = funcref(self, "new_auth")
		data[_auth.tag] = service
		
		_cmd_use_item = PBField.new("cmd_use_item", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 100, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _cmd_use_item
		service.func_ref = funcref(self, "new_cmd_use_item")
		data[_cmd_use_item.tag] = service
		
		_cmd_drop_item = PBField.new("cmd_drop_item", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 101, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _cmd_drop_item
		service.func_ref = funcref(self, "new_cmd_drop_item")
		data[_cmd_drop_item.tag] = service
		
		_cmd_pickup_item = PBField.new("cmd_pickup_item", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 102, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _cmd_pickup_item
		service.func_ref = funcref(self, "new_cmd_pickup_item")
		data[_cmd_pickup_item.tag] = service
		
		_cmd_get_client_var = PBField.new("cmd_get_client_var", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 103, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _cmd_get_client_var
		service.func_ref = funcref(self, "new_cmd_get_client_var")
		data[_cmd_get_client_var.tag] = service
		
		_resp_client_var = PBField.new("resp_client_var", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 200, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _resp_client_var
		service.func_ref = funcref(self, "new_resp_client_var")
		data[_resp_client_var.tag] = service
		
	var data = {}
	
	var _auth
	func has_auth():
		if data[1].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_auth():
		return _auth.value
	func clear_auth():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_auth():
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_auth.value = Auth.new()
		return _auth.value
	
	var _cmd_use_item
	func has_cmd_use_item():
		if data[100].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_cmd_use_item():
		return _cmd_use_item.value
	func clear_cmd_use_item():
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_cmd_use_item():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_use_item.value = UseItem.new()
		return _cmd_use_item.value
	
	var _cmd_drop_item
	func has_cmd_drop_item():
		if data[101].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_cmd_drop_item():
		return _cmd_drop_item.value
	func clear_cmd_drop_item():
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_cmd_drop_item():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DropItem.new()
		return _cmd_drop_item.value
	
	var _cmd_pickup_item
	func has_cmd_pickup_item():
		if data[102].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_cmd_pickup_item():
		return _cmd_pickup_item.value
	func clear_cmd_pickup_item():
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_cmd_pickup_item():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = PickupItem.new()
		return _cmd_pickup_item.value
	
	var _cmd_get_client_var
	func has_cmd_get_client_var():
		if data[103].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_cmd_get_client_var():
		return _cmd_get_client_var.value
	func clear_cmd_get_client_var():
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_cmd_get_client_var():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = GetClientVar.new()
		return _cmd_get_client_var.value
	
	var _resp_client_var
	func has_resp_client_var():
		if data[200].state == PB_SERVICE_STATE.FILLED:
			return true
		return false
	func get_resp_client_var():
		return _resp_client_var.value
	func clear_resp_client_var():
		_resp_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_resp_client_var():
		_auth.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_use_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_drop_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_pickup_item.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_cmd_get_client_var.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
		_resp_client_var.value = ClientVar.new()
		return _resp_client_var.value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class Auth:
	func _init():
		var service
		
		_accountId = PBField.new("accountId", PB_DATA_TYPE.INT64, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.INT64])
		service = PBServiceField.new()
		service.field = _accountId
		data[_accountId.tag] = service
		
		_token = PBField.new("token", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _token
		data[_token.tag] = service
		
	var data = {}
	
	var _accountId
	func get_accountId():
		return _accountId.value
	func clear_accountId():
		_accountId.value = DEFAULT_VALUES_3[PB_DATA_TYPE.INT64]
	func set_accountId(value):
		_accountId.value = value
	
	var _token
	func get_token():
		return _token.value
	func clear_token():
		_token.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_token(value):
		_token.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class Client:
	func _init():
		var service
		
		_account_id = PBField.new("account_id", PB_DATA_TYPE.UINT64, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64])
		service = PBServiceField.new()
		service.field = _account_id
		data[_account_id.tag] = service
		
	var data = {}
	
	var _account_id
	func get_account_id():
		return _account_id.value
	func clear_account_id():
		_account_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64]
	func set_account_id(value):
		_account_id.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class UseItem:
	func _init():
		var service
		
		_client = PBField.new("client", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _client
		service.func_ref = funcref(self, "new_client")
		data[_client.tag] = service
		
		_player_item_id = PBField.new("player_item_id", PB_DATA_TYPE.UINT64, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64])
		service = PBServiceField.new()
		service.field = _player_item_id
		data[_player_item_id.tag] = service
		
	var data = {}
	
	var _client
	func get_client():
		return _client.value
	func clear_client():
		_client.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_client():
		_client.value = Client.new()
		return _client.value
	
	var _player_item_id
	func get_player_item_id():
		return _player_item_id.value
	func clear_player_item_id():
		_player_item_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64]
	func set_player_item_id(value):
		_player_item_id.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class DropItem:
	func _init():
		var service
		
		_client = PBField.new("client", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _client
		service.func_ref = funcref(self, "new_client")
		data[_client.tag] = service
		
		_player_item_id = PBField.new("player_item_id", PB_DATA_TYPE.UINT64, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64])
		service = PBServiceField.new()
		service.field = _player_item_id
		data[_player_item_id.tag] = service
		
		_amount = PBField.new("amount", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _amount
		data[_amount.tag] = service
		
	var data = {}
	
	var _client
	func get_client():
		return _client.value
	func clear_client():
		_client.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_client():
		_client.value = Client.new()
		return _client.value
	
	var _player_item_id
	func get_player_item_id():
		return _player_item_id.value
	func clear_player_item_id():
		_player_item_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64]
	func set_player_item_id(value):
		_player_item_id.value = value
	
	var _amount
	func get_amount():
		return _amount.value
	func clear_amount():
		_amount.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_amount(value):
		_amount.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PickupItem:
	func _init():
		var service
		
		_client = PBField.new("client", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _client
		service.func_ref = funcref(self, "new_client")
		data[_client.tag] = service
		
		_player_item_id = PBField.new("player_item_id", PB_DATA_TYPE.UINT64, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64])
		service = PBServiceField.new()
		service.field = _player_item_id
		data[_player_item_id.tag] = service
		
		_amount = PBField.new("amount", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _amount
		data[_amount.tag] = service
		
	var data = {}
	
	var _client
	func get_client():
		return _client.value
	func clear_client():
		_client.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_client():
		_client.value = Client.new()
		return _client.value
	
	var _player_item_id
	func get_player_item_id():
		return _player_item_id.value
	func clear_player_item_id():
		_player_item_id.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT64]
	func set_player_item_id(value):
		_player_item_id.value = value
	
	var _amount
	func get_amount():
		return _amount.value
	func clear_amount():
		_amount.value = DEFAULT_VALUES_3[PB_DATA_TYPE.UINT32]
	func set_amount(value):
		_amount.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class GetClientVar:
	func _init():
		var service
		
		_client = PBField.new("client", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _client
		service.func_ref = funcref(self, "new_client")
		data[_client.tag] = service
		
		_key = PBField.new("key", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _key
		data[_key.tag] = service
		
	var data = {}
	
	var _client
	func get_client():
		return _client.value
	func clear_client():
		_client.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_client():
		_client.value = Client.new()
		return _client.value
	
	var _key
	func get_key():
		return _key.value
	func clear_key():
		_key.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_key(value):
		_key.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class ClientVar:
	func _init():
		var service
		
		_client = PBField.new("client", PB_DATA_TYPE.MESSAGE, PB_RULE.OPTIONAL, 1, true, DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _client
		service.func_ref = funcref(self, "new_client")
		data[_client.tag] = service
		
		_key = PBField.new("key", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 2, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _key
		data[_key.tag] = service
		
		_value = PBField.new("value", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 3, true, DEFAULT_VALUES_3[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _value
		data[_value.tag] = service
		
	var data = {}
	
	var _client
	func get_client():
		return _client.value
	func clear_client():
		_client.value = DEFAULT_VALUES_3[PB_DATA_TYPE.MESSAGE]
	func new_client():
		_client.value = Client.new()
		return _client.value
	
	var _key
	func get_key():
		return _key.value
	func clear_key():
		_key.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_key(value):
		_key.value = value
	
	var _value
	func get_value():
		return _value.value
	func clear_value():
		_value.value = DEFAULT_VALUES_3[PB_DATA_TYPE.STRING]
	func set_value(value):
		_value.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
################ USER DATA END #################
