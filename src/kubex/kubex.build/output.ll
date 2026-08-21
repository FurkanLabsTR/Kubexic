target triple = "x86_64-unknown-linux-gnu"

declare i32 @kx_argc()
declare ptr @kx_argv(i32)
declare i64 @kx_println(ptr)
declare i64 @kx_print(ptr)
declare ptr @kx_read_file(ptr)
declare i1 @kx_write_file(ptr, ptr)
declare ptr @kx_int_str(i64)
declare i64 @kx_system(ptr)
declare void @kx_exit(i32)
declare void @kx_panic(ptr)
declare void @kx_save_args(i32, ptr)
declare i64 @kx_args(i64)
declare ptr @kx_str_trim(ptr)
declare i64 @kx_str_index_of(ptr, ptr)
declare i64 @kx_list_new(i32)
declare void @kx_list_add(i64, i64)
declare i64 @kx_list_get(i64, i64)
declare void @kx_list_set(i64, i64, i64)
declare i64 @kx_list_size(i64)
declare void @kx_list_remove_at(i64, i64)
declare void @kx_list_clear(i64)
declare i64 @kx_map_new(i32, i32)
declare void @kx_map_set(i64, i64, i64)
declare i64 @kx_map_get(i64, i64)
declare i1 @kx_map_has(i64, i64)
declare i64 @kx_str_len(ptr)
declare ptr @kx_str_cat(ptr, ptr)
declare i1 @kx_str_eq(ptr, ptr)
declare i1 @kx_str_lt(ptr, ptr)
declare i1 @kx_str_le(ptr, ptr)
declare i1 @kx_str_gt(ptr, ptr)
declare i1 @kx_str_ge(ptr, ptr)
declare ptr @kx_str_substr(ptr, i64, i64)
declare i1 @kx_str_contains(ptr, ptr)
declare i1 @kx_str_starts_with(ptr, ptr)
declare i1 @kx_str_ends_with(ptr, ptr)
declare ptr @kx_str_upper(ptr)
declare ptr @kx_str_lower(ptr)
declare double @kx_rng_next_double(i64)
declare i64 @kx_struct_new(i32)
declare i64 @kx_struct_get(i64, i32)
declare void @kx_struct_set(i64, i32, i64)
declare i64 @kx_spawn(i64)
declare void @kx_despawn(i64)
declare void @kx_attach(i64, i32)
declare void @kx_detach(i64, i32)
declare void @kx_set_field_i64(i64, i32, i32, i64)
declare i64 @kx_get_field_i64(i64, i32, i32)
declare void @kx_set_field_str(i64, i32, i32, ptr)
declare ptr @kx_get_field_str(i64, i32, i32)
declare void @kx_set_field_f64(i64, i32, i32, double)
declare double @kx_get_field_f64(i64, i32, i32)

define i64 @IsDigit(ptr %c) {
entry:
  %c.addr = alloca ptr
  store ptr %c, ptr %c.addr
  %t.1 = load ptr, ptr %c.addr
  %r.3 = call i1 @kx_str_ge(ptr %t.1, ptr @.str.1)
  %t.4 = load ptr, ptr %c.addr
  %r.6 = call i1 @kx_str_le(ptr %t.4, ptr @.str.2)
  %t.7 = and i1 %r.3, %r.6
  %ext.8 = zext i1 %t.7 to i64
  ret i64 %ext.8
dead.9:
  ret i64 0
}

define i64 @IsLetter(ptr %c) {
entry:
  %c.addr = alloca ptr
  store ptr %c, ptr %c.addr
  %t.10 = load ptr, ptr %c.addr
  %r.12 = call i1 @kx_str_ge(ptr %t.10, ptr @.str.3)
  %t.13 = load ptr, ptr %c.addr
  %r.15 = call i1 @kx_str_le(ptr %t.13, ptr @.str.4)
  %t.16 = and i1 %r.12, %r.15
  %t.17 = load ptr, ptr %c.addr
  %r.19 = call i1 @kx_str_ge(ptr %t.17, ptr @.str.5)
  %t.20 = load ptr, ptr %c.addr
  %r.22 = call i1 @kx_str_le(ptr %t.20, ptr @.str.6)
  %t.23 = and i1 %r.19, %r.22
  %t.24 = or i1 %t.16, %t.23
  %ext.25 = zext i1 %t.24 to i64
  ret i64 %ext.25
dead.26:
  ret i64 0
}

define i64 @IsIdentPart(ptr %c) {
entry:
  %c.addr = alloca ptr
  store ptr %c, ptr %c.addr
  %t.27 = load ptr, ptr %c.addr
  %r.28 = call i64 @IsLetter(ptr %t.27)
  %t.29 = load ptr, ptr %c.addr
  %r.30 = call i64 @IsDigit(ptr %t.29)
  %ext.32 = icmp ne i64 %r.28, 0
  %ext.33 = icmp ne i64 %r.30, 0
  %t.31 = or i1 %ext.32, %ext.33
  %t.34 = load ptr, ptr %c.addr
  %r.36 = call i1 @kx_str_eq(ptr %t.34, ptr @.str.7)
  %t.37 = or i1 %t.31, %r.36
  %ext.38 = zext i1 %t.37 to i64
  ret i64 %ext.38
dead.39:
  ret i64 0
}

define i64 @IsSpace(ptr %c) {
entry:
  %c.addr = alloca ptr
  store ptr %c, ptr %c.addr
  %t.40 = load ptr, ptr %c.addr
  %r.42 = call i1 @kx_str_eq(ptr %t.40, ptr @.str.8)
  %t.43 = load ptr, ptr %c.addr
  %r.45 = call i1 @kx_str_eq(ptr %t.43, ptr @.str.9)
  %t.46 = or i1 %r.42, %r.45
  %t.47 = load ptr, ptr %c.addr
  %r.49 = call i1 @kx_str_eq(ptr %t.47, ptr @.str.10)
  %t.50 = or i1 %t.46, %r.49
  %t.51 = load ptr, ptr %c.addr
  %r.53 = call i1 @kx_str_eq(ptr %t.51, ptr @.str.11)
  %t.54 = or i1 %t.50, %r.53
  %ext.55 = zext i1 %t.54 to i64
  ret i64 %ext.55
dead.56:
  ret i64 0
}

define ptr @CharAt(ptr %s, i64 %i) {
entry:
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %i.addr = alloca i64
  store i64 %i, ptr %i.addr
  %t.57 = load i64, ptr %i.addr
  %ext.58 = sext i32 0 to i64
  %t.59 = icmp slt i64 %t.57, %ext.58
  %t.60 = load i64, ptr %i.addr
  %t.61 = load ptr, ptr %s.addr
  %r.62 = call i64 @kx_str_len(ptr %t.61)
  %t.63 = icmp sge i64 %t.60, %r.62
  %t.64 = or i1 %t.59, %t.63
  br i1 %t.64, label %if.then.65, label %if.merge.66
if.then.65:
  ret ptr @.str.12
dead.67:
  br label %if.merge.66
if.merge.66:
  %t.68 = load ptr, ptr %s.addr
  %t.69 = load i64, ptr %i.addr
  %ext.70 = sext i32 1 to i64
  %r.71 = call ptr @kx_str_substr(ptr %t.68, i64 %t.69, i64 %ext.70)
  ret ptr %r.71
dead.72:
  ret ptr null
}

define i64 @LexAll(ptr %src) {
entry:
  %src.addr = alloca ptr
  store ptr %src, ptr %src.addr
  %r.73 = call i64 @kx_list_new(i32 0)
  %tokens.0 = alloca i64
  store i64 %r.73, ptr %tokens.0
  %pos.1 = alloca i32
  store i32 0, ptr %pos.1
  %line.2 = alloca i32
  store i32 1, ptr %line.2
  %col.3 = alloca i32
  store i32 1, ptr %col.3
  %t.74 = load ptr, ptr %src.addr
  %r.75 = call i64 @kx_str_len(ptr %t.74)
  %n.4 = alloca i64
  store i64 %r.75, ptr %n.4
  br label %w.cond.76
w.cond.76:
  %t.79 = load i32, ptr %pos.1
  %t.80 = load i64, ptr %n.4
  %ext.81 = sext i32 %t.79 to i64
  %t.82 = icmp slt i64 %ext.81, %t.80
  br i1 %t.82, label %w.body.77, label %w.end.78
w.body.77:
  %t.83 = load ptr, ptr %src.addr
  %t.84 = load i32, ptr %pos.1
  %cast.85 = sext i32 %t.84 to i64
  %r.86 = call ptr @CharAt(ptr %t.83, i64 %cast.85)
  %c.5 = alloca ptr
  store ptr %r.86, ptr %c.5
  %t.87 = load ptr, ptr %c.5
  %r.88 = call i64 @IsSpace(ptr %t.87)
  %ext.89 = icmp ne i64 %r.88, 0
  br i1 %ext.89, label %if.then.90, label %if.merge.91
if.then.90:
  %t.92 = load i32, ptr %pos.1
  %t.93 = add i32 %t.92, 1
  store i32 %t.93, ptr %pos.1
  %t.94 = load i32, ptr %col.3
  %t.95 = add i32 %t.94, 1
  store i32 %t.95, ptr %col.3
  %t.96 = load ptr, ptr %c.5
  %r.98 = call i1 @kx_str_eq(ptr %t.96, ptr @.str.10)
  br i1 %r.98, label %if.then.99, label %if.merge.100
if.then.99:
  %t.101 = load i32, ptr %line.2
  %t.102 = add i32 %t.101, 1
  store i32 %t.102, ptr %line.2
  store i32 1, ptr %col.3
  br label %if.merge.100
if.merge.100:
  br label %w.cond.76
dead.103:
  br label %if.merge.91
if.merge.91:
  %t.104 = load ptr, ptr %c.5
  %r.106 = call i1 @kx_str_eq(ptr %t.104, ptr @.str.13)
  %t.107 = load ptr, ptr %src.addr
  %t.108 = load i32, ptr %pos.1
  %t.109 = add i32 %t.108, 1
  %cast.110 = sext i32 %t.109 to i64
  %r.111 = call ptr @CharAt(ptr %t.107, i64 %cast.110)
  %r.113 = call i1 @kx_str_eq(ptr %r.111, ptr @.str.13)
  %t.114 = and i1 %r.106, %r.113
  br i1 %t.114, label %if.then.115, label %if.merge.116
if.then.115:
  br label %w.cond.117
w.cond.117:
  %t.120 = load i32, ptr %pos.1
  %t.121 = load i64, ptr %n.4
  %ext.122 = sext i32 %t.120 to i64
  %t.123 = icmp slt i64 %ext.122, %t.121
  %t.124 = load ptr, ptr %src.addr
  %t.125 = load i32, ptr %pos.1
  %cast.126 = sext i32 %t.125 to i64
  %r.127 = call ptr @CharAt(ptr %t.124, i64 %cast.126)
  %r.129 = call i1 @kx_str_eq(ptr %r.127, ptr @.str.10)
  %t.130 = and i1 %t.123, %r.129
  br i1 %t.130, label %w.body.118, label %w.end.119
w.body.118:
  %t.131 = load i32, ptr %pos.1
  %t.132 = add i32 %t.131, 1
  store i32 %t.132, ptr %pos.1
  %t.133 = load i32, ptr %col.3
  %t.134 = add i32 %t.133, 1
  store i32 %t.134, ptr %col.3
  br label %w.cond.117
w.end.119:
  br label %w.cond.76
dead.135:
  br label %if.merge.116
if.merge.116:
  %t.136 = load ptr, ptr %c.5
  %r.138 = call i1 @kx_str_eq(ptr %t.136, ptr @.str.13)
  %t.139 = load ptr, ptr %src.addr
  %t.140 = load i32, ptr %pos.1
  %t.141 = add i32 %t.140, 1
  %cast.142 = sext i32 %t.141 to i64
  %r.143 = call ptr @CharAt(ptr %t.139, i64 %cast.142)
  %r.145 = call i1 @kx_str_eq(ptr %r.143, ptr @.str.14)
  %t.146 = and i1 %r.138, %r.145
  br i1 %t.146, label %if.then.147, label %if.merge.148
if.then.147:
  %t.149 = load i32, ptr %pos.1
  %t.150 = add i32 %t.149, 2
  store i32 %t.150, ptr %pos.1
  %t.151 = load i32, ptr %col.3
  %t.152 = add i32 %t.151, 2
  store i32 %t.152, ptr %col.3
  br label %w.cond.153
w.cond.153:
  %t.156 = load i32, ptr %pos.1
  %t.157 = load i64, ptr %n.4
  %ext.158 = sext i32 %t.156 to i64
  %t.159 = icmp slt i64 %ext.158, %t.157
  %t.160 = load ptr, ptr %src.addr
  %t.161 = load i32, ptr %pos.1
  %cast.162 = sext i32 %t.161 to i64
  %r.163 = call ptr @CharAt(ptr %t.160, i64 %cast.162)
  %r.165 = call i1 @kx_str_eq(ptr %r.163, ptr @.str.14)
  %t.166 = load ptr, ptr %src.addr
  %t.167 = load i32, ptr %pos.1
  %t.168 = add i32 %t.167, 1
  %cast.169 = sext i32 %t.168 to i64
  %r.170 = call ptr @CharAt(ptr %t.166, i64 %cast.169)
  %r.172 = call i1 @kx_str_eq(ptr %r.170, ptr @.str.13)
  %t.173 = and i1 %r.165, %r.172
  %t.174 = xor i1 %t.173, true
  %t.175 = and i1 %t.159, %t.174
  br i1 %t.175, label %w.body.154, label %w.end.155
w.body.154:
  %t.176 = load ptr, ptr %src.addr
  %t.177 = load i32, ptr %pos.1
  %cast.178 = sext i32 %t.177 to i64
  %r.179 = call ptr @CharAt(ptr %t.176, i64 %cast.178)
  %r.181 = call i1 @kx_str_eq(ptr %r.179, ptr @.str.10)
  br i1 %r.181, label %if.then.182, label %if.else.184
if.then.182:
  %t.185 = load i32, ptr %line.2
  %t.186 = add i32 %t.185, 1
  store i32 %t.186, ptr %line.2
  store i32 1, ptr %col.3
  br label %if.merge.183
if.else.184:
  %t.187 = load i32, ptr %col.3
  %t.188 = add i32 %t.187, 1
  store i32 %t.188, ptr %col.3
  br label %if.merge.183
if.merge.183:
  %t.189 = load i32, ptr %pos.1
  %t.190 = add i32 %t.189, 1
  store i32 %t.190, ptr %pos.1
  br label %w.cond.153
w.end.155:
  %t.191 = load i32, ptr %pos.1
  %t.192 = add i32 %t.191, 2
  store i32 %t.192, ptr %pos.1
  %t.193 = load i32, ptr %col.3
  %t.194 = add i32 %t.193, 2
  store i32 %t.194, ptr %col.3
  br label %w.cond.76
dead.195:
  br label %if.merge.148
if.merge.148:
  %t.196 = load ptr, ptr %c.5
  %r.197 = call i64 @IsLetter(ptr %t.196)
  %t.198 = load ptr, ptr %c.5
  %r.200 = call i1 @kx_str_eq(ptr %t.198, ptr @.str.7)
  %ext.202 = icmp ne i64 %r.197, 0
  %t.201 = or i1 %ext.202, %r.200
  br i1 %t.201, label %if.then.203, label %if.merge.204
if.then.203:
  %t.205 = load i32, ptr %pos.1
  %start.6 = alloca i32
  store i32 %t.205, ptr %start.6
  %t.206 = load i32, ptr %col.3
  %startCol.7 = alloca i32
  store i32 %t.206, ptr %startCol.7
  %t.207 = load i32, ptr %line.2
  %startLine.8 = alloca i32
  store i32 %t.207, ptr %startLine.8
  br label %w.cond.208
w.cond.208:
  %t.211 = load i32, ptr %pos.1
  %t.212 = load i64, ptr %n.4
  %ext.213 = sext i32 %t.211 to i64
  %t.214 = icmp slt i64 %ext.213, %t.212
  %t.215 = load ptr, ptr %src.addr
  %t.216 = load i32, ptr %pos.1
  %cast.217 = sext i32 %t.216 to i64
  %r.218 = call ptr @CharAt(ptr %t.215, i64 %cast.217)
  %r.219 = call i64 @IsIdentPart(ptr %r.218)
  %ext.221 = icmp ne i64 %r.219, 0
  %t.220 = and i1 %t.214, %ext.221
  br i1 %t.220, label %w.body.209, label %w.end.210
w.body.209:
  %t.222 = load i32, ptr %pos.1
  %t.223 = add i32 %t.222, 1
  store i32 %t.223, ptr %pos.1
  %t.224 = load i32, ptr %col.3
  %t.225 = add i32 %t.224, 1
  store i32 %t.225, ptr %col.3
  br label %w.cond.208
w.end.210:
  %t.226 = load ptr, ptr %src.addr
  %t.227 = load i32, ptr %start.6
  %ext.228 = sext i32 %t.227 to i64
  %t.229 = load i32, ptr %pos.1
  %t.230 = load i32, ptr %start.6
  %t.231 = sub i32 %t.229, %t.230
  %ext.232 = sext i32 %t.231 to i64
  %r.233 = call ptr @kx_str_substr(ptr %t.226, i64 %ext.228, i64 %ext.232)
  %text.9 = alloca ptr
  store ptr %r.233, ptr %text.9
  %kind.10 = alloca ptr
  store ptr @.str.15, ptr %kind.10
  %t.234 = load ptr, ptr %text.9
  %r.236 = call i1 @kx_str_eq(ptr %t.234, ptr @.str.16)
  %t.237 = load ptr, ptr %text.9
  %r.239 = call i1 @kx_str_eq(ptr %t.237, ptr @.str.17)
  %t.240 = or i1 %r.236, %r.239
  %t.241 = load ptr, ptr %text.9
  %r.243 = call i1 @kx_str_eq(ptr %t.241, ptr @.str.18)
  %t.244 = or i1 %t.240, %r.243
  %t.245 = load ptr, ptr %text.9
  %r.247 = call i1 @kx_str_eq(ptr %t.245, ptr @.str.19)
  %t.248 = or i1 %t.244, %r.247
  %t.249 = load ptr, ptr %text.9
  %r.251 = call i1 @kx_str_eq(ptr %t.249, ptr @.str.20)
  %t.252 = or i1 %t.248, %r.251
  %t.253 = load ptr, ptr %text.9
  %r.255 = call i1 @kx_str_eq(ptr %t.253, ptr @.str.21)
  %t.256 = or i1 %t.252, %r.255
  %t.257 = load ptr, ptr %text.9
  %r.259 = call i1 @kx_str_eq(ptr %t.257, ptr @.str.22)
  %t.260 = or i1 %t.256, %r.259
  %t.261 = load ptr, ptr %text.9
  %r.263 = call i1 @kx_str_eq(ptr %t.261, ptr @.str.23)
  %t.264 = or i1 %t.260, %r.263
  %t.265 = load ptr, ptr %text.9
  %r.267 = call i1 @kx_str_eq(ptr %t.265, ptr @.str.24)
  %t.268 = or i1 %t.264, %r.267
  %t.269 = load ptr, ptr %text.9
  %r.271 = call i1 @kx_str_eq(ptr %t.269, ptr @.str.25)
  %t.272 = or i1 %t.268, %r.271
  %t.273 = load ptr, ptr %text.9
  %r.275 = call i1 @kx_str_eq(ptr %t.273, ptr @.str.26)
  %t.276 = or i1 %t.272, %r.275
  %t.277 = load ptr, ptr %text.9
  %r.279 = call i1 @kx_str_eq(ptr %t.277, ptr @.str.27)
  %t.280 = or i1 %t.276, %r.279
  %t.281 = load ptr, ptr %text.9
  %r.283 = call i1 @kx_str_eq(ptr %t.281, ptr @.str.28)
  %t.284 = or i1 %t.280, %r.283
  %t.285 = load ptr, ptr %text.9
  %r.287 = call i1 @kx_str_eq(ptr %t.285, ptr @.str.29)
  %t.288 = or i1 %t.284, %r.287
  %t.289 = load ptr, ptr %text.9
  %r.291 = call i1 @kx_str_eq(ptr %t.289, ptr @.str.30)
  %t.292 = or i1 %t.288, %r.291
  %t.293 = load ptr, ptr %text.9
  %r.295 = call i1 @kx_str_eq(ptr %t.293, ptr @.str.31)
  %t.296 = or i1 %t.292, %r.295
  %t.297 = load ptr, ptr %text.9
  %r.299 = call i1 @kx_str_eq(ptr %t.297, ptr @.str.32)
  %t.300 = or i1 %t.296, %r.299
  %t.301 = load ptr, ptr %text.9
  %r.303 = call i1 @kx_str_eq(ptr %t.301, ptr @.str.33)
  %t.304 = or i1 %t.300, %r.303
  %t.305 = load ptr, ptr %text.9
  %r.307 = call i1 @kx_str_eq(ptr %t.305, ptr @.str.34)
  %t.308 = or i1 %t.304, %r.307
  %t.309 = load ptr, ptr %text.9
  %r.311 = call i1 @kx_str_eq(ptr %t.309, ptr @.str.35)
  %t.312 = or i1 %t.308, %r.311
  %t.313 = load ptr, ptr %text.9
  %r.315 = call i1 @kx_str_eq(ptr %t.313, ptr @.str.36)
  %t.316 = or i1 %t.312, %r.315
  %t.317 = load ptr, ptr %text.9
  %r.319 = call i1 @kx_str_eq(ptr %t.317, ptr @.str.37)
  %t.320 = or i1 %t.316, %r.319
  %t.321 = load ptr, ptr %text.9
  %r.323 = call i1 @kx_str_eq(ptr %t.321, ptr @.str.38)
  %t.324 = or i1 %t.320, %r.323
  %t.325 = load ptr, ptr %text.9
  %r.327 = call i1 @kx_str_eq(ptr %t.325, ptr @.str.39)
  %t.328 = or i1 %t.324, %r.327
  %t.329 = load ptr, ptr %text.9
  %r.331 = call i1 @kx_str_eq(ptr %t.329, ptr @.str.40)
  %t.332 = or i1 %t.328, %r.331
  %t.333 = load ptr, ptr %text.9
  %r.335 = call i1 @kx_str_eq(ptr %t.333, ptr @.str.41)
  %t.336 = or i1 %t.332, %r.335
  %t.337 = load ptr, ptr %text.9
  %r.339 = call i1 @kx_str_eq(ptr %t.337, ptr @.str.42)
  %t.340 = or i1 %t.336, %r.339
  %t.341 = load ptr, ptr %text.9
  %r.343 = call i1 @kx_str_eq(ptr %t.341, ptr @.str.43)
  %t.344 = or i1 %t.340, %r.343
  %t.345 = load ptr, ptr %text.9
  %r.347 = call i1 @kx_str_eq(ptr %t.345, ptr @.str.44)
  %t.348 = or i1 %t.344, %r.347
  %t.349 = load ptr, ptr %text.9
  %r.351 = call i1 @kx_str_eq(ptr %t.349, ptr @.str.45)
  %t.352 = or i1 %t.348, %r.351
  %t.353 = load ptr, ptr %text.9
  %r.355 = call i1 @kx_str_eq(ptr %t.353, ptr @.str.46)
  %t.356 = or i1 %t.352, %r.355
  %t.357 = load ptr, ptr %text.9
  %r.359 = call i1 @kx_str_eq(ptr %t.357, ptr @.str.47)
  %t.360 = or i1 %t.356, %r.359
  %t.361 = load ptr, ptr %text.9
  %r.363 = call i1 @kx_str_eq(ptr %t.361, ptr @.str.48)
  %t.364 = or i1 %t.360, %r.363
  %t.365 = load ptr, ptr %text.9
  %r.367 = call i1 @kx_str_eq(ptr %t.365, ptr @.str.49)
  %t.368 = or i1 %t.364, %r.367
  %t.369 = load ptr, ptr %text.9
  %r.371 = call i1 @kx_str_eq(ptr %t.369, ptr @.str.50)
  %t.372 = or i1 %t.368, %r.371
  %t.373 = load ptr, ptr %text.9
  %r.375 = call i1 @kx_str_eq(ptr %t.373, ptr @.str.51)
  %t.376 = or i1 %t.372, %r.375
  %t.377 = load ptr, ptr %text.9
  %r.379 = call i1 @kx_str_eq(ptr %t.377, ptr @.str.52)
  %t.380 = or i1 %t.376, %r.379
  %t.381 = load ptr, ptr %text.9
  %r.383 = call i1 @kx_str_eq(ptr %t.381, ptr @.str.53)
  %t.384 = or i1 %t.380, %r.383
  %t.385 = load ptr, ptr %text.9
  %r.387 = call i1 @kx_str_eq(ptr %t.385, ptr @.str.54)
  %t.388 = or i1 %t.384, %r.387
  %t.389 = load ptr, ptr %text.9
  %r.391 = call i1 @kx_str_eq(ptr %t.389, ptr @.str.55)
  %t.392 = or i1 %t.388, %r.391
  %t.393 = load ptr, ptr %text.9
  %r.395 = call i1 @kx_str_eq(ptr %t.393, ptr @.str.56)
  %t.396 = or i1 %t.392, %r.395
  %t.397 = load ptr, ptr %text.9
  %r.399 = call i1 @kx_str_eq(ptr %t.397, ptr @.str.57)
  %t.400 = or i1 %t.396, %r.399
  %t.401 = load ptr, ptr %text.9
  %r.403 = call i1 @kx_str_eq(ptr %t.401, ptr @.str.58)
  %t.404 = or i1 %t.400, %r.403
  br i1 %t.404, label %if.then.405, label %if.merge.406
if.then.405:
  store ptr @.str.59, ptr %kind.10
  br label %if.merge.406
if.merge.406:
  %t.407 = load i64, ptr %tokens.0
  %r.408 = call i64 @kx_struct_new(i32 4)
  %t.409 = load ptr, ptr %kind.10
  %ext.410 = ptrtoint ptr %t.409 to i64
  call void @kx_struct_set(i64 %r.408, i32 0, i64 %ext.410)
  %t.411 = load ptr, ptr %text.9
  %ext.412 = ptrtoint ptr %t.411 to i64
  call void @kx_struct_set(i64 %r.408, i32 1, i64 %ext.412)
  %t.413 = load i32, ptr %startLine.8
  %ext.414 = sext i32 %t.413 to i64
  call void @kx_struct_set(i64 %r.408, i32 2, i64 %ext.414)
  %t.415 = load i32, ptr %startCol.7
  %ext.416 = sext i32 %t.415 to i64
  call void @kx_struct_set(i64 %r.408, i32 3, i64 %ext.416)
  call void @kx_list_add(i64 %t.407, i64 %r.408)
  br label %w.cond.76
dead.417:
  br label %if.merge.204
if.merge.204:
  %t.418 = load ptr, ptr %c.5
  %r.419 = call i64 @IsDigit(ptr %t.418)
  %ext.420 = icmp ne i64 %r.419, 0
  br i1 %ext.420, label %if.then.421, label %if.merge.422
if.then.421:
  %t.423 = load i32, ptr %pos.1
  %start.11 = alloca i32
  store i32 %t.423, ptr %start.11
  %t.424 = load i32, ptr %col.3
  %startCol.12 = alloca i32
  store i32 %t.424, ptr %startCol.12
  %t.425 = load i32, ptr %line.2
  %startLine.13 = alloca i32
  store i32 %t.425, ptr %startLine.13
  %isFloat.14 = alloca i1
  store i1 false, ptr %isFloat.14
  br label %w.cond.426
w.cond.426:
  %t.429 = load i32, ptr %pos.1
  %t.430 = load i64, ptr %n.4
  %ext.431 = sext i32 %t.429 to i64
  %t.432 = icmp slt i64 %ext.431, %t.430
  %t.433 = load ptr, ptr %src.addr
  %t.434 = load i32, ptr %pos.1
  %cast.435 = sext i32 %t.434 to i64
  %r.436 = call ptr @CharAt(ptr %t.433, i64 %cast.435)
  %r.437 = call i64 @IsDigit(ptr %r.436)
  %ext.439 = icmp ne i64 %r.437, 0
  %t.438 = and i1 %t.432, %ext.439
  br i1 %t.438, label %w.body.427, label %w.end.428
w.body.427:
  %t.440 = load i32, ptr %pos.1
  %t.441 = add i32 %t.440, 1
  store i32 %t.441, ptr %pos.1
  %t.442 = load i32, ptr %col.3
  %t.443 = add i32 %t.442, 1
  store i32 %t.443, ptr %col.3
  br label %w.cond.426
w.end.428:
  %t.444 = load ptr, ptr %src.addr
  %t.445 = load i32, ptr %pos.1
  %cast.446 = sext i32 %t.445 to i64
  %r.447 = call ptr @CharAt(ptr %t.444, i64 %cast.446)
  %r.449 = call i1 @kx_str_eq(ptr %r.447, ptr @.str.60)
  %t.450 = load ptr, ptr %src.addr
  %t.451 = load i32, ptr %pos.1
  %t.452 = add i32 %t.451, 1
  %cast.453 = sext i32 %t.452 to i64
  %r.454 = call ptr @CharAt(ptr %t.450, i64 %cast.453)
  %r.455 = call i64 @IsDigit(ptr %r.454)
  %ext.457 = icmp ne i64 %r.455, 0
  %t.456 = and i1 %r.449, %ext.457
  br i1 %t.456, label %if.then.458, label %if.merge.459
if.then.458:
  store i1 true, ptr %isFloat.14
  %t.460 = load i32, ptr %pos.1
  %t.461 = add i32 %t.460, 1
  store i32 %t.461, ptr %pos.1
  %t.462 = load i32, ptr %col.3
  %t.463 = add i32 %t.462, 1
  store i32 %t.463, ptr %col.3
  br label %w.cond.464
w.cond.464:
  %t.467 = load i32, ptr %pos.1
  %t.468 = load i64, ptr %n.4
  %ext.469 = sext i32 %t.467 to i64
  %t.470 = icmp slt i64 %ext.469, %t.468
  %t.471 = load ptr, ptr %src.addr
  %t.472 = load i32, ptr %pos.1
  %cast.473 = sext i32 %t.472 to i64
  %r.474 = call ptr @CharAt(ptr %t.471, i64 %cast.473)
  %r.475 = call i64 @IsDigit(ptr %r.474)
  %ext.477 = icmp ne i64 %r.475, 0
  %t.476 = and i1 %t.470, %ext.477
  br i1 %t.476, label %w.body.465, label %w.end.466
w.body.465:
  %t.478 = load i32, ptr %pos.1
  %t.479 = add i32 %t.478, 1
  store i32 %t.479, ptr %pos.1
  %t.480 = load i32, ptr %col.3
  %t.481 = add i32 %t.480, 1
  store i32 %t.481, ptr %col.3
  br label %w.cond.464
w.end.466:
  br label %if.merge.459
if.merge.459:
  %t.482 = load ptr, ptr %src.addr
  %t.483 = load i32, ptr %start.11
  %ext.484 = sext i32 %t.483 to i64
  %t.485 = load i32, ptr %pos.1
  %t.486 = load i32, ptr %start.11
  %t.487 = sub i32 %t.485, %t.486
  %ext.488 = sext i32 %t.487 to i64
  %r.489 = call ptr @kx_str_substr(ptr %t.482, i64 %ext.484, i64 %ext.488)
  %text.15 = alloca ptr
  store ptr %r.489, ptr %text.15
  %t.490 = load i64, ptr %tokens.0
  %r.491 = call i64 @kx_struct_new(i32 4)
  %t.492 = load i1, ptr %isFloat.14
  br i1 %t.492, label %tern.then.493, label %tern.else.494
tern.then.493:
  br label %tern.merge.495
tern.else.494:
  br label %tern.merge.495
tern.merge.495:
  %phi.496 = phi ptr [@.str.26, %tern.then.493], [@.str.24, %tern.else.494]
  %ext.497 = ptrtoint ptr %phi.496 to i64
  call void @kx_struct_set(i64 %r.491, i32 0, i64 %ext.497)
  %t.498 = load ptr, ptr %text.15
  %ext.499 = ptrtoint ptr %t.498 to i64
  call void @kx_struct_set(i64 %r.491, i32 1, i64 %ext.499)
  %t.500 = load i32, ptr %startLine.13
  %ext.501 = sext i32 %t.500 to i64
  call void @kx_struct_set(i64 %r.491, i32 2, i64 %ext.501)
  %t.502 = load i32, ptr %startCol.12
  %ext.503 = sext i32 %t.502 to i64
  call void @kx_struct_set(i64 %r.491, i32 3, i64 %ext.503)
  call void @kx_list_add(i64 %t.490, i64 %r.491)
  br label %w.cond.76
dead.504:
  br label %if.merge.422
if.merge.422:
  %t.505 = load ptr, ptr %c.5
  %r.507 = call i1 @kx_str_eq(ptr %t.505, ptr @.str.61)
  %t.508 = load ptr, ptr %src.addr
  %t.509 = load i32, ptr %pos.1
  %t.510 = add i32 %t.509, 1
  %cast.511 = sext i32 %t.510 to i64
  %r.512 = call ptr @CharAt(ptr %t.508, i64 %cast.511)
  %r.514 = call i1 @kx_str_eq(ptr %r.512, ptr @.str.62)
  %t.515 = and i1 %r.507, %r.514
  br i1 %t.515, label %if.then.516, label %if.merge.517
if.then.516:
  %t.518 = load i32, ptr %col.3
  %startCol.16 = alloca i32
  store i32 %t.518, ptr %startCol.16
  %t.519 = load i32, ptr %line.2
  %startLine.17 = alloca i32
  store i32 %t.519, ptr %startLine.17
  %t.520 = load i32, ptr %pos.1
  %t.521 = add i32 %t.520, 2
  store i32 %t.521, ptr %pos.1
  %t.522 = load i32, ptr %col.3
  %t.523 = add i32 %t.522, 2
  store i32 %t.523, ptr %col.3
  %text.18 = alloca ptr
  store ptr @.str.12, ptr %text.18
  %depth.19 = alloca i32
  store i32 0, ptr %depth.19
  br label %w.cond.524
w.cond.524:
  %t.527 = load i32, ptr %pos.1
  %t.528 = load i64, ptr %n.4
  %ext.529 = sext i32 %t.527 to i64
  %t.530 = icmp slt i64 %ext.529, %t.528
  br i1 %t.530, label %w.body.525, label %w.end.526
w.body.525:
  %t.531 = load ptr, ptr %src.addr
  %t.532 = load i32, ptr %pos.1
  %cast.533 = sext i32 %t.532 to i64
  %r.534 = call ptr @CharAt(ptr %t.531, i64 %cast.533)
  %dc.20 = alloca ptr
  store ptr %r.534, ptr %dc.20
  %t.535 = load ptr, ptr %dc.20
  %r.537 = call i1 @kx_str_eq(ptr %t.535, ptr @.str.63)
  br i1 %r.537, label %if.then.538, label %if.merge.539
if.then.538:
  %t.540 = load i32, ptr %depth.19
  %t.541 = add i32 %t.540, 1
  store i32 %t.541, ptr %depth.19
  %t.542 = load ptr, ptr %text.18
  %t.543 = load ptr, ptr %dc.20
  %r.545 = call ptr @kx_str_cat(ptr %t.542, ptr %t.543)
  store ptr %r.545, ptr %text.18
  %t.546 = load i32, ptr %pos.1
  %t.547 = add i32 %t.546, 1
  store i32 %t.547, ptr %pos.1
  %t.548 = load i32, ptr %col.3
  %t.549 = add i32 %t.548, 1
  store i32 %t.549, ptr %col.3
  br label %w.cond.524
dead.550:
  br label %if.merge.539
if.merge.539:
  %t.551 = load ptr, ptr %dc.20
  %r.553 = call i1 @kx_str_eq(ptr %t.551, ptr @.str.64)
  br i1 %r.553, label %if.then.554, label %if.merge.555
if.then.554:
  %t.556 = load i32, ptr %depth.19
  %t.557 = icmp sgt i32 %t.556, 0
  br i1 %t.557, label %if.then.558, label %if.merge.559
if.then.558:
  %t.560 = load i32, ptr %depth.19
  %t.561 = sub i32 %t.560, 1
  store i32 %t.561, ptr %depth.19
  br label %if.merge.559
if.merge.559:
  %t.562 = load ptr, ptr %text.18
  %t.563 = load ptr, ptr %dc.20
  %r.565 = call ptr @kx_str_cat(ptr %t.562, ptr %t.563)
  store ptr %r.565, ptr %text.18
  %t.566 = load i32, ptr %pos.1
  %t.567 = add i32 %t.566, 1
  store i32 %t.567, ptr %pos.1
  %t.568 = load i32, ptr %col.3
  %t.569 = add i32 %t.568, 1
  store i32 %t.569, ptr %col.3
  br label %w.cond.524
dead.570:
  br label %if.merge.555
if.merge.555:
  %t.571 = load ptr, ptr %dc.20
  %r.573 = call i1 @kx_str_eq(ptr %t.571, ptr @.str.65)
  %t.574 = load i32, ptr %pos.1
  %t.575 = add i32 %t.574, 1
  %t.576 = load i64, ptr %n.4
  %ext.577 = sext i32 %t.575 to i64
  %t.578 = icmp slt i64 %ext.577, %t.576
  %t.579 = and i1 %r.573, %t.578
  br i1 %t.579, label %if.then.580, label %if.merge.581
if.then.580:
  %t.582 = load ptr, ptr %text.18
  %t.583 = load ptr, ptr %dc.20
  %r.585 = call ptr @kx_str_cat(ptr %t.582, ptr %t.583)
  store ptr %r.585, ptr %text.18
  %t.586 = load i32, ptr %pos.1
  %t.587 = add i32 %t.586, 1
  store i32 %t.587, ptr %pos.1
  %t.588 = load i32, ptr %col.3
  %t.589 = add i32 %t.588, 1
  store i32 %t.589, ptr %col.3
  %t.590 = load ptr, ptr %text.18
  %t.591 = load ptr, ptr %src.addr
  %t.592 = load i32, ptr %pos.1
  %cast.593 = sext i32 %t.592 to i64
  %r.594 = call ptr @CharAt(ptr %t.591, i64 %cast.593)
  %r.596 = call ptr @kx_str_cat(ptr %t.590, ptr %r.594)
  store ptr %r.596, ptr %text.18
  %t.597 = load i32, ptr %pos.1
  %t.598 = add i32 %t.597, 1
  store i32 %t.598, ptr %pos.1
  %t.599 = load i32, ptr %col.3
  %t.600 = add i32 %t.599, 1
  store i32 %t.600, ptr %col.3
  br label %w.cond.524
dead.601:
  br label %if.merge.581
if.merge.581:
  %t.602 = load ptr, ptr %dc.20
  %r.604 = call i1 @kx_str_eq(ptr %t.602, ptr @.str.62)
  %t.605 = load i32, ptr %depth.19
  %t.606 = icmp eq i32 %t.605, 0
  %t.607 = and i1 %r.604, %t.606
  br i1 %t.607, label %if.then.608, label %if.merge.609
if.then.608:
  br label %w.end.526
dead.610:
  br label %if.merge.609
if.merge.609:
  %t.611 = load ptr, ptr %dc.20
  %r.613 = call i1 @kx_str_eq(ptr %t.611, ptr @.str.62)
  %t.614 = load i32, ptr %depth.19
  %t.615 = icmp sgt i32 %t.614, 0
  %t.616 = and i1 %r.613, %t.615
  br i1 %t.616, label %if.then.617, label %if.merge.618
if.then.617:
  %t.619 = load ptr, ptr %text.18
  %t.620 = load ptr, ptr %dc.20
  %r.622 = call ptr @kx_str_cat(ptr %t.619, ptr %t.620)
  store ptr %r.622, ptr %text.18
  %t.623 = load i32, ptr %pos.1
  %t.624 = add i32 %t.623, 1
  store i32 %t.624, ptr %pos.1
  %t.625 = load i32, ptr %col.3
  %t.626 = add i32 %t.625, 1
  store i32 %t.626, ptr %col.3
  br label %w.cond.627
w.cond.627:
  %t.630 = load i32, ptr %pos.1
  %t.631 = load i64, ptr %n.4
  %ext.632 = sext i32 %t.630 to i64
  %t.633 = icmp slt i64 %ext.632, %t.631
  br i1 %t.633, label %w.body.628, label %w.end.629
w.body.628:
  %t.634 = load ptr, ptr %src.addr
  %t.635 = load i32, ptr %pos.1
  %cast.636 = sext i32 %t.635 to i64
  %r.637 = call ptr @CharAt(ptr %t.634, i64 %cast.636)
  %q.21 = alloca ptr
  store ptr %r.637, ptr %q.21
  %t.638 = load ptr, ptr %text.18
  %t.639 = load ptr, ptr %q.21
  %r.641 = call ptr @kx_str_cat(ptr %t.638, ptr %t.639)
  store ptr %r.641, ptr %text.18
  %t.642 = load i32, ptr %pos.1
  %t.643 = add i32 %t.642, 1
  store i32 %t.643, ptr %pos.1
  %t.644 = load i32, ptr %col.3
  %t.645 = add i32 %t.644, 1
  store i32 %t.645, ptr %col.3
  %t.646 = load ptr, ptr %q.21
  %r.648 = call i1 @kx_str_eq(ptr %t.646, ptr @.str.65)
  %t.649 = load i32, ptr %pos.1
  %t.650 = load i64, ptr %n.4
  %ext.651 = sext i32 %t.649 to i64
  %t.652 = icmp slt i64 %ext.651, %t.650
  %t.653 = and i1 %r.648, %t.652
  br i1 %t.653, label %if.then.654, label %if.merge.655
if.then.654:
  %t.656 = load ptr, ptr %text.18
  %t.657 = load ptr, ptr %src.addr
  %t.658 = load i32, ptr %pos.1
  %cast.659 = sext i32 %t.658 to i64
  %r.660 = call ptr @CharAt(ptr %t.657, i64 %cast.659)
  %r.662 = call ptr @kx_str_cat(ptr %t.656, ptr %r.660)
  store ptr %r.662, ptr %text.18
  %t.663 = load i32, ptr %pos.1
  %t.664 = add i32 %t.663, 1
  store i32 %t.664, ptr %pos.1
  %t.665 = load i32, ptr %col.3
  %t.666 = add i32 %t.665, 1
  store i32 %t.666, ptr %col.3
  br label %w.cond.627
dead.667:
  br label %if.merge.655
if.merge.655:
  %t.668 = load ptr, ptr %q.21
  %r.670 = call i1 @kx_str_eq(ptr %t.668, ptr @.str.62)
  br i1 %r.670, label %if.then.671, label %if.merge.672
if.then.671:
  br label %w.end.629
dead.673:
  br label %if.merge.672
if.merge.672:
  br label %w.cond.627
w.end.629:
  br label %w.cond.524
dead.674:
  br label %if.merge.618
if.merge.618:
  %t.675 = load ptr, ptr %text.18
  %t.676 = load ptr, ptr %dc.20
  %r.678 = call ptr @kx_str_cat(ptr %t.675, ptr %t.676)
  store ptr %r.678, ptr %text.18
  %t.679 = load i32, ptr %pos.1
  %t.680 = add i32 %t.679, 1
  store i32 %t.680, ptr %pos.1
  %t.681 = load i32, ptr %col.3
  %t.682 = add i32 %t.681, 1
  store i32 %t.682, ptr %col.3
  br label %w.cond.524
w.end.526:
  %t.683 = load i32, ptr %pos.1
  %t.684 = add i32 %t.683, 1
  store i32 %t.684, ptr %pos.1
  %t.685 = load i32, ptr %col.3
  %t.686 = add i32 %t.685, 1
  store i32 %t.686, ptr %col.3
  %t.687 = load i64, ptr %tokens.0
  %r.688 = call i64 @kx_struct_new(i32 4)
  %ext.689 = ptrtoint ptr @.str.66 to i64
  call void @kx_struct_set(i64 %r.688, i32 0, i64 %ext.689)
  %t.690 = load ptr, ptr %text.18
  %ext.691 = ptrtoint ptr %t.690 to i64
  call void @kx_struct_set(i64 %r.688, i32 1, i64 %ext.691)
  %t.692 = load i32, ptr %startLine.17
  %ext.693 = sext i32 %t.692 to i64
  call void @kx_struct_set(i64 %r.688, i32 2, i64 %ext.693)
  %t.694 = load i32, ptr %startCol.16
  %ext.695 = sext i32 %t.694 to i64
  call void @kx_struct_set(i64 %r.688, i32 3, i64 %ext.695)
  call void @kx_list_add(i64 %t.687, i64 %r.688)
  br label %w.cond.76
dead.696:
  br label %if.merge.517
if.merge.517:
  %t.697 = load ptr, ptr %c.5
  %r.699 = call i1 @kx_str_eq(ptr %t.697, ptr @.str.62)
  br i1 %r.699, label %if.then.700, label %if.merge.701
if.then.700:
  %t.702 = load i32, ptr %col.3
  %startCol.22 = alloca i32
  store i32 %t.702, ptr %startCol.22
  %t.703 = load i32, ptr %line.2
  %startLine.23 = alloca i32
  store i32 %t.703, ptr %startLine.23
  %t.704 = load i32, ptr %pos.1
  %t.705 = add i32 %t.704, 1
  store i32 %t.705, ptr %pos.1
  %t.706 = load i32, ptr %col.3
  %t.707 = add i32 %t.706, 1
  store i32 %t.707, ptr %col.3
  %text.24 = alloca ptr
  store ptr @.str.12, ptr %text.24
  br label %w.cond.708
w.cond.708:
  %t.711 = load i32, ptr %pos.1
  %t.712 = load i64, ptr %n.4
  %ext.713 = sext i32 %t.711 to i64
  %t.714 = icmp slt i64 %ext.713, %t.712
  %t.715 = load ptr, ptr %src.addr
  %t.716 = load i32, ptr %pos.1
  %cast.717 = sext i32 %t.716 to i64
  %r.718 = call ptr @CharAt(ptr %t.715, i64 %cast.717)
  %r.720 = call i1 @kx_str_eq(ptr %r.718, ptr @.str.62)
  %t.721 = and i1 %t.714, %r.720
  br i1 %t.721, label %w.body.709, label %w.end.710
w.body.709:
  %t.722 = load ptr, ptr %src.addr
  %t.723 = load i32, ptr %pos.1
  %cast.724 = sext i32 %t.723 to i64
  %r.725 = call ptr @CharAt(ptr %t.722, i64 %cast.724)
  %r.727 = call i1 @kx_str_eq(ptr %r.725, ptr @.str.65)
  %t.728 = load i32, ptr %pos.1
  %t.729 = add i32 %t.728, 1
  %t.730 = load i64, ptr %n.4
  %ext.731 = sext i32 %t.729 to i64
  %t.732 = icmp slt i64 %ext.731, %t.730
  %t.733 = and i1 %r.727, %t.732
  br i1 %t.733, label %if.then.734, label %if.else.736
if.then.734:
  %t.737 = load ptr, ptr %src.addr
  %t.738 = load i32, ptr %pos.1
  %t.739 = add i32 %t.738, 1
  %cast.740 = sext i32 %t.739 to i64
  %r.741 = call ptr @CharAt(ptr %t.737, i64 %cast.740)
  %esc.25 = alloca ptr
  store ptr %r.741, ptr %esc.25
  %t.742 = load ptr, ptr %esc.25
  %r.744 = call i1 @kx_str_eq(ptr %t.742, ptr @.str.67)
  br i1 %r.744, label %if.then.745, label %if.else.747
if.then.745:
  %t.748 = load ptr, ptr %text.24
  %r.750 = call ptr @kx_str_cat(ptr %t.748, ptr @.str.10)
  store ptr %r.750, ptr %text.24
  br label %if.merge.746
if.else.747:
  %t.751 = load ptr, ptr %esc.25
  %r.753 = call i1 @kx_str_eq(ptr %t.751, ptr @.str.68)
  br i1 %r.753, label %if.then.754, label %if.else.756
if.then.754:
  %t.757 = load ptr, ptr %text.24
  %r.759 = call ptr @kx_str_cat(ptr %t.757, ptr @.str.9)
  store ptr %r.759, ptr %text.24
  br label %if.merge.755
if.else.756:
  %t.760 = load ptr, ptr %esc.25
  %r.762 = call i1 @kx_str_eq(ptr %t.760, ptr @.str.69)
  br i1 %r.762, label %if.then.763, label %if.else.765
if.then.763:
  %t.766 = load ptr, ptr %text.24
  %r.768 = call ptr @kx_str_cat(ptr %t.766, ptr @.str.11)
  store ptr %r.768, ptr %text.24
  br label %if.merge.764
if.else.765:
  %t.769 = load ptr, ptr %esc.25
  %r.771 = call i1 @kx_str_eq(ptr %t.769, ptr @.str.65)
  br i1 %r.771, label %if.then.772, label %if.else.774
if.then.772:
  %t.775 = load ptr, ptr %text.24
  %r.777 = call ptr @kx_str_cat(ptr %t.775, ptr @.str.65)
  store ptr %r.777, ptr %text.24
  br label %if.merge.773
if.else.774:
  %t.778 = load ptr, ptr %esc.25
  %r.780 = call i1 @kx_str_eq(ptr %t.778, ptr @.str.62)
  br i1 %r.780, label %if.then.781, label %if.else.783
if.then.781:
  %t.784 = load ptr, ptr %text.24
  %r.786 = call ptr @kx_str_cat(ptr %t.784, ptr @.str.62)
  store ptr %r.786, ptr %text.24
  br label %if.merge.782
if.else.783:
  %t.787 = load ptr, ptr %esc.25
  %r.789 = call i1 @kx_str_eq(ptr %t.787, ptr @.str.70)
  br i1 %r.789, label %if.then.790, label %if.else.792
if.then.790:
  %t.793 = load ptr, ptr %text.24
  %r.795 = call ptr @kx_str_cat(ptr %t.793, ptr @.str.70)
  store ptr %r.795, ptr %text.24
  br label %if.merge.791
if.else.792:
  %t.796 = load ptr, ptr %text.24
  %r.798 = call ptr @kx_str_cat(ptr %t.796, ptr @.str.65)
  store ptr %r.798, ptr %text.24
  %t.799 = load ptr, ptr %text.24
  %t.800 = load ptr, ptr %esc.25
  %r.802 = call ptr @kx_str_cat(ptr %t.799, ptr %t.800)
  store ptr %r.802, ptr %text.24
  br label %if.merge.791
if.merge.791:
  br label %if.merge.782
if.merge.782:
  br label %if.merge.773
if.merge.773:
  br label %if.merge.764
if.merge.764:
  br label %if.merge.755
if.merge.755:
  br label %if.merge.746
if.merge.746:
  %t.803 = load i32, ptr %pos.1
  %t.804 = add i32 %t.803, 2
  store i32 %t.804, ptr %pos.1
  %t.805 = load i32, ptr %col.3
  %t.806 = add i32 %t.805, 2
  store i32 %t.806, ptr %col.3
  br label %if.merge.735
if.else.736:
  %t.807 = load ptr, ptr %text.24
  %t.808 = load ptr, ptr %src.addr
  %t.809 = load i32, ptr %pos.1
  %cast.810 = sext i32 %t.809 to i64
  %r.811 = call ptr @CharAt(ptr %t.808, i64 %cast.810)
  %r.813 = call ptr @kx_str_cat(ptr %t.807, ptr %r.811)
  store ptr %r.813, ptr %text.24
  %t.814 = load i32, ptr %pos.1
  %t.815 = add i32 %t.814, 1
  store i32 %t.815, ptr %pos.1
  %t.816 = load i32, ptr %col.3
  %t.817 = add i32 %t.816, 1
  store i32 %t.817, ptr %col.3
  br label %if.merge.735
if.merge.735:
  br label %w.cond.708
w.end.710:
  %t.818 = load i32, ptr %pos.1
  %t.819 = add i32 %t.818, 1
  store i32 %t.819, ptr %pos.1
  %t.820 = load i32, ptr %col.3
  %t.821 = add i32 %t.820, 1
  store i32 %t.821, ptr %col.3
  %t.822 = load i64, ptr %tokens.0
  %r.823 = call i64 @kx_struct_new(i32 4)
  %ext.824 = ptrtoint ptr @.str.30 to i64
  call void @kx_struct_set(i64 %r.823, i32 0, i64 %ext.824)
  %t.825 = load ptr, ptr %text.24
  %ext.826 = ptrtoint ptr %t.825 to i64
  call void @kx_struct_set(i64 %r.823, i32 1, i64 %ext.826)
  %t.827 = load i32, ptr %startLine.23
  %ext.828 = sext i32 %t.827 to i64
  call void @kx_struct_set(i64 %r.823, i32 2, i64 %ext.828)
  %t.829 = load i32, ptr %startCol.22
  %ext.830 = sext i32 %t.829 to i64
  call void @kx_struct_set(i64 %r.823, i32 3, i64 %ext.830)
  call void @kx_list_add(i64 %t.822, i64 %r.823)
  br label %w.cond.76
dead.831:
  br label %if.merge.701
if.merge.701:
  %t.832 = load ptr, ptr %src.addr
  %t.833 = load i32, ptr %pos.1
  %ext.834 = sext i32 %t.833 to i64
  %ext.835 = sext i32 2 to i64
  %r.836 = call ptr @kx_str_substr(ptr %t.832, i64 %ext.834, i64 %ext.835)
  %two.26 = alloca ptr
  store ptr %r.836, ptr %two.26
  %t.837 = load ptr, ptr %two.26
  %r.839 = call i1 @kx_str_eq(ptr %t.837, ptr @.str.71)
  %t.840 = load ptr, ptr %two.26
  %r.842 = call i1 @kx_str_eq(ptr %t.840, ptr @.str.72)
  %t.843 = or i1 %r.839, %r.842
  %t.844 = load ptr, ptr %two.26
  %r.846 = call i1 @kx_str_eq(ptr %t.844, ptr @.str.73)
  %t.847 = or i1 %t.843, %r.846
  %t.848 = load ptr, ptr %two.26
  %r.850 = call i1 @kx_str_eq(ptr %t.848, ptr @.str.74)
  %t.851 = or i1 %t.847, %r.850
  %t.852 = load ptr, ptr %two.26
  %r.854 = call i1 @kx_str_eq(ptr %t.852, ptr @.str.75)
  %t.855 = or i1 %t.851, %r.854
  %t.856 = load ptr, ptr %two.26
  %r.858 = call i1 @kx_str_eq(ptr %t.856, ptr @.str.76)
  %t.859 = or i1 %t.855, %r.858
  %t.860 = load ptr, ptr %two.26
  %r.862 = call i1 @kx_str_eq(ptr %t.860, ptr @.str.77)
  %t.863 = or i1 %t.859, %r.862
  %t.864 = load ptr, ptr %two.26
  %r.866 = call i1 @kx_str_eq(ptr %t.864, ptr @.str.78)
  %t.867 = or i1 %t.863, %r.866
  %t.868 = load ptr, ptr %two.26
  %r.870 = call i1 @kx_str_eq(ptr %t.868, ptr @.str.79)
  %t.871 = or i1 %t.867, %r.870
  %t.872 = load ptr, ptr %two.26
  %r.874 = call i1 @kx_str_eq(ptr %t.872, ptr @.str.80)
  %t.875 = or i1 %t.871, %r.874
  %t.876 = load ptr, ptr %two.26
  %r.878 = call i1 @kx_str_eq(ptr %t.876, ptr @.str.81)
  %t.879 = or i1 %t.875, %r.878
  %t.880 = load ptr, ptr %two.26
  %r.882 = call i1 @kx_str_eq(ptr %t.880, ptr @.str.82)
  %t.883 = or i1 %t.879, %r.882
  %t.884 = load ptr, ptr %two.26
  %r.886 = call i1 @kx_str_eq(ptr %t.884, ptr @.str.83)
  %t.887 = or i1 %t.883, %r.886
  br i1 %t.887, label %if.then.888, label %if.merge.889
if.then.888:
  %t.890 = load i64, ptr %tokens.0
  %r.891 = call i64 @kx_struct_new(i32 4)
  %ext.892 = ptrtoint ptr @.str.84 to i64
  call void @kx_struct_set(i64 %r.891, i32 0, i64 %ext.892)
  %t.893 = load ptr, ptr %two.26
  %ext.894 = ptrtoint ptr %t.893 to i64
  call void @kx_struct_set(i64 %r.891, i32 1, i64 %ext.894)
  %t.895 = load i32, ptr %line.2
  %ext.896 = sext i32 %t.895 to i64
  call void @kx_struct_set(i64 %r.891, i32 2, i64 %ext.896)
  %t.897 = load i32, ptr %col.3
  %ext.898 = sext i32 %t.897 to i64
  call void @kx_struct_set(i64 %r.891, i32 3, i64 %ext.898)
  call void @kx_list_add(i64 %t.890, i64 %r.891)
  %t.899 = load i32, ptr %pos.1
  %t.900 = add i32 %t.899, 2
  store i32 %t.900, ptr %pos.1
  %t.901 = load i32, ptr %col.3
  %t.902 = add i32 %t.901, 2
  store i32 %t.902, ptr %col.3
  br label %w.cond.76
dead.903:
  br label %if.merge.889
if.merge.889:
  %t.904 = load i64, ptr %tokens.0
  %r.905 = call i64 @kx_struct_new(i32 4)
  %ext.906 = ptrtoint ptr @.str.85 to i64
  call void @kx_struct_set(i64 %r.905, i32 0, i64 %ext.906)
  %t.907 = load ptr, ptr %c.5
  %ext.908 = ptrtoint ptr %t.907 to i64
  call void @kx_struct_set(i64 %r.905, i32 1, i64 %ext.908)
  %t.909 = load i32, ptr %line.2
  %ext.910 = sext i32 %t.909 to i64
  call void @kx_struct_set(i64 %r.905, i32 2, i64 %ext.910)
  %t.911 = load i32, ptr %col.3
  %ext.912 = sext i32 %t.911 to i64
  call void @kx_struct_set(i64 %r.905, i32 3, i64 %ext.912)
  call void @kx_list_add(i64 %t.904, i64 %r.905)
  %t.913 = load i32, ptr %pos.1
  %t.914 = add i32 %t.913, 1
  store i32 %t.914, ptr %pos.1
  %t.915 = load i32, ptr %col.3
  %t.916 = add i32 %t.915, 1
  store i32 %t.916, ptr %col.3
  br label %w.cond.76
w.end.78:
  %t.917 = load i64, ptr %tokens.0
  %r.918 = call i64 @kx_struct_new(i32 4)
  %ext.919 = ptrtoint ptr @.str.86 to i64
  call void @kx_struct_set(i64 %r.918, i32 0, i64 %ext.919)
  %ext.920 = ptrtoint ptr @.str.12 to i64
  call void @kx_struct_set(i64 %r.918, i32 1, i64 %ext.920)
  %t.921 = load i32, ptr %line.2
  %ext.922 = sext i32 %t.921 to i64
  call void @kx_struct_set(i64 %r.918, i32 2, i64 %ext.922)
  %t.923 = load i32, ptr %col.3
  %ext.924 = sext i32 %t.923 to i64
  call void @kx_struct_set(i64 %r.918, i32 3, i64 %ext.924)
  call void @kx_list_add(i64 %t.917, i64 %r.918)
  %t.925 = load i64, ptr %tokens.0
  ret i64 %t.925
dead.926:
  ret i64 0
}

define i64 @NewNode(i64 %arena, ptr %kind, ptr %value, i64 %line, i64 %col) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %kind.addr = alloca ptr
  store ptr %kind, ptr %kind.addr
  %value.addr = alloca ptr
  store ptr %value, ptr %value.addr
  %line.addr = alloca i64
  store i64 %line, ptr %line.addr
  %col.addr = alloca i64
  store i64 %col, ptr %col.addr
  %t.927 = load i64, ptr %arena.addr
  %r.928 = call i64 @kx_struct_new(i32 5)
  %t.929 = load ptr, ptr %kind.addr
  %ext.930 = ptrtoint ptr %t.929 to i64
  call void @kx_struct_set(i64 %r.928, i32 0, i64 %ext.930)
  %t.931 = load ptr, ptr %value.addr
  %ext.932 = ptrtoint ptr %t.931 to i64
  call void @kx_struct_set(i64 %r.928, i32 1, i64 %ext.932)
  %t.933 = load i64, ptr %line.addr
  call void @kx_struct_set(i64 %r.928, i32 2, i64 %t.933)
  %t.934 = load i64, ptr %col.addr
  call void @kx_struct_set(i64 %r.928, i32 3, i64 %t.934)
  %r.935 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.928, i32 4, i64 %r.935)
  call void @kx_list_add(i64 %t.927, i64 %r.928)
  %t.936 = load i64, ptr %arena.addr
  %r.937 = call i64 @kx_list_size(i64 %t.936)
  %ext.938 = sext i32 1 to i64
  %t.939 = sub i64 %r.937, %ext.938
  ret i64 %t.939
dead.940:
  ret i64 0
}

define i64 @Node(i64 %arena, i64 %i) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %i.addr = alloca i64
  store i64 %i, ptr %i.addr
  %t.941 = load i64, ptr %arena.addr
  %t.942 = load i64, ptr %i.addr
  %r.943 = call i64 @kx_list_get(i64 %t.941, i64 %t.942)
  ret i64 %r.943
dead.944:
  ret i64 0
}

define ptr @TrimFloat(i64 %s) {
entry:
  %s.addr = alloca i64
  store i64 %s, ptr %s.addr
  %t.945 = load i64, ptr %s.addr
  %out.27 = alloca i64
  store i64 %t.945, ptr %out.27
  br label %w.cond.946
w.cond.946:
  %t.949 = load i64, ptr %out.27
  %ext.950 = sext i32 0 to i64
  %t.951 = icmp sgt i64 %t.949, %ext.950
  %t.952 = load i64, ptr %out.27
  %ext.953 = inttoptr i64 %t.952 to ptr
  %r.954 = call i1 @kx_str_ends_with(ptr %ext.953, ptr @.str.1)
  %t.955 = and i1 %t.951, %r.954
  br i1 %t.955, label %w.body.947, label %w.end.948
w.body.947:
  %t.956 = load i64, ptr %out.27
  %ext.957 = inttoptr i64 %t.956 to ptr
  %ext.958 = sext i32 0 to i64
  %t.959 = load i64, ptr %out.27
  %ext.960 = sext i32 1 to i64
  %t.961 = sub i64 %t.959, %ext.960
  %r.962 = call ptr @kx_str_substr(ptr %ext.957, i64 %ext.958, i64 %t.961)
  %ptrtoint.963 = ptrtoint ptr %r.962 to i64
  store i64 %ptrtoint.963, ptr %out.27
  br label %w.cond.946
w.end.948:
  %t.964 = load i64, ptr %out.27
  %ext.965 = sext i32 0 to i64
  %t.966 = icmp sgt i64 %t.964, %ext.965
  %t.967 = load i64, ptr %out.27
  %ext.968 = inttoptr i64 %t.967 to ptr
  %r.969 = call i1 @kx_str_ends_with(ptr %ext.968, ptr @.str.60)
  %t.970 = and i1 %t.966, %r.969
  br i1 %t.970, label %if.then.971, label %if.merge.972
if.then.971:
  %t.973 = load i64, ptr %out.27
  %ext.974 = inttoptr i64 %t.973 to ptr
  %ext.975 = sext i32 0 to i64
  %t.976 = load i64, ptr %out.27
  %ext.977 = sext i32 1 to i64
  %t.978 = sub i64 %t.976, %ext.977
  %r.979 = call ptr @kx_str_substr(ptr %ext.974, i64 %ext.975, i64 %t.978)
  %ptrtoint.980 = ptrtoint ptr %r.979 to i64
  store i64 %ptrtoint.980, ptr %out.27
  br label %if.merge.972
if.merge.972:
  %t.981 = load i64, ptr %out.27
  %ext.983 = inttoptr i64 %t.981 to ptr
  %r.984 = call i1 @kx_str_eq(ptr %ext.983, ptr @.str.87)
  br i1 %r.984, label %if.then.985, label %if.merge.986
if.then.985:
  %ptrtoint.987 = ptrtoint ptr @.str.88 to i64
  store i64 %ptrtoint.987, ptr %out.27
  br label %if.merge.986
if.merge.986:
  %t.988 = load i64, ptr %out.27
  %ext.990 = inttoptr i64 %t.988 to ptr
  %r.991 = call i1 @kx_str_eq(ptr %ext.990, ptr @.str.12)
  br i1 %r.991, label %if.then.992, label %if.merge.993
if.then.992:
  %ptrtoint.994 = ptrtoint ptr @.str.1 to i64
  store i64 %ptrtoint.994, ptr %out.27
  br label %if.merge.993
if.merge.993:
  %t.995 = load i64, ptr %out.27
  %ext.996 = inttoptr i64 %t.995 to ptr
  ret ptr %ext.996
dead.997:
  ret ptr null
}

define void @AddChild(i64 %arena, i64 %parent, i64 %child) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %parent.addr = alloca i64
  store i64 %parent, ptr %parent.addr
  %child.addr = alloca i64
  store i64 %child, ptr %child.addr
  %t.998 = load i64, ptr %arena.addr
  %t.999 = load i64, ptr %parent.addr
  %r.1000 = call i64 @kx_list_get(i64 %t.998, i64 %t.999)
  %children.28 = alloca i64
  store i64 %r.1000, ptr %children.28
  %t.1001 = load i64, ptr %children.28
  %t.1002 = load i64, ptr %child.addr
  call void @kx_list_add(i64 %t.1001, i64 %t.1002)
  ret void
}

define i64 @Peek(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1003 = load i64, ptr %tokens.addr
  %t.1004 = load i64, ptr %pos.addr
  %ext.1006 = sext i32 0 to i64
  %r.1005 = call i64 @kx_list_get(i64 %t.1004, i64 %ext.1006)
  %r.1007 = call i64 @kx_list_get(i64 %t.1003, i64 %r.1005)
  ret i64 %r.1007
dead.1008:
  ret i64 0
}

define ptr @CurKind(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1009 = load i64, ptr %tokens.addr
  %t.1010 = load i64, ptr %pos.addr
  %r.1011 = call i64 @Peek(i64 %t.1009, i64 %t.1010)
  %r.1012 = call i64 @kx_struct_get(i64 %r.1011, i32 0)
  %field.1013 = inttoptr i64 %r.1012 to ptr
  ret ptr %field.1013
dead.1014:
  ret ptr null
}

define ptr @CurText(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1015 = load i64, ptr %tokens.addr
  %t.1016 = load i64, ptr %pos.addr
  %r.1017 = call i64 @Peek(i64 %t.1015, i64 %t.1016)
  %r.1018 = call i64 @kx_struct_get(i64 %r.1017, i32 1)
  %field.1019 = inttoptr i64 %r.1018 to ptr
  ret ptr %field.1019
dead.1020:
  ret ptr null
}

define i64 @CurLine(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1021 = load i64, ptr %tokens.addr
  %t.1022 = load i64, ptr %pos.addr
  %r.1023 = call i64 @Peek(i64 %t.1021, i64 %t.1022)
  %r.1024 = call i64 @kx_struct_get(i64 %r.1023, i32 2)
  ret i64 %r.1024
dead.1025:
  ret i64 0
}

define i64 @CurCol(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1026 = load i64, ptr %tokens.addr
  %t.1027 = load i64, ptr %pos.addr
  %r.1028 = call i64 @Peek(i64 %t.1026, i64 %t.1027)
  %r.1029 = call i64 @kx_struct_get(i64 %r.1028, i32 3)
  ret i64 %r.1029
dead.1030:
  ret i64 0
}

define i64 @AtEnd(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1031 = load i64, ptr %tokens.addr
  %t.1032 = load i64, ptr %pos.addr
  %r.1033 = call ptr @CurKind(i64 %t.1031, i64 %t.1032)
  %r.1035 = call i1 @kx_str_eq(ptr %r.1033, ptr @.str.86)
  %ext.1036 = zext i1 %r.1035 to i64
  ret i64 %ext.1036
dead.1037:
  ret i64 0
}

define void @Advance(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1038 = load i64, ptr %pos.addr
  %t.1039 = load i64, ptr %pos.addr
  %ext.1041 = sext i32 0 to i64
  %r.1040 = call i64 @kx_list_get(i64 %t.1039, i64 %ext.1041)
  %ext.1042 = sext i32 1 to i64
  %t.1043 = add i64 %r.1040, %ext.1042
  %ext.1044 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.1038, i64 %ext.1044, i64 %t.1043)
  ret void
}

define i64 @IsKw(i64 %tokens, i64 %pos, ptr %w) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %w.addr = alloca ptr
  store ptr %w, ptr %w.addr
  %t.1045 = load i64, ptr %tokens.addr
  %t.1046 = load i64, ptr %pos.addr
  %r.1047 = call i64 @Peek(i64 %t.1045, i64 %t.1046)
  %t.29 = alloca i64
  store i64 %r.1047, ptr %t.29
  %t.1048 = load i64, ptr %t.29
  %ext.1050 = inttoptr i64 %t.1048 to ptr
  %r.1051 = call i1 @kx_str_eq(ptr %ext.1050, ptr @.str.59)
  %t.1052 = load i64, ptr %t.29
  %t.1053 = load ptr, ptr %w.addr
  %ext.1055 = inttoptr i64 %t.1052 to ptr
  %r.1056 = call i1 @kx_str_eq(ptr %ext.1055, ptr %t.1053)
  %t.1057 = and i1 %r.1051, %r.1056
  %ext.1058 = zext i1 %t.1057 to i64
  ret i64 %ext.1058
dead.1059:
  ret i64 0
}

define i64 @IsPunct(i64 %tokens, i64 %pos, ptr %p) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %p.addr = alloca ptr
  store ptr %p, ptr %p.addr
  %t.1060 = load i64, ptr %tokens.addr
  %t.1061 = load i64, ptr %pos.addr
  %r.1062 = call i64 @Peek(i64 %t.1060, i64 %t.1061)
  %t.30 = alloca i64
  store i64 %r.1062, ptr %t.30
  %t.1063 = load i64, ptr %t.30
  %ext.1065 = inttoptr i64 %t.1063 to ptr
  %r.1066 = call i1 @kx_str_eq(ptr %ext.1065, ptr @.str.85)
  %t.1067 = load i64, ptr %t.30
  %t.1068 = load ptr, ptr %p.addr
  %ext.1070 = inttoptr i64 %t.1067 to ptr
  %r.1071 = call i1 @kx_str_eq(ptr %ext.1070, ptr %t.1068)
  %t.1072 = and i1 %r.1066, %r.1071
  %ext.1073 = zext i1 %t.1072 to i64
  ret i64 %ext.1073
dead.1074:
  ret i64 0
}

define i64 @IsOp(i64 %tokens, i64 %pos, ptr %o) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %o.addr = alloca ptr
  store ptr %o, ptr %o.addr
  %t.1075 = load i64, ptr %tokens.addr
  %t.1076 = load i64, ptr %pos.addr
  %r.1077 = call i64 @Peek(i64 %t.1075, i64 %t.1076)
  %t.31 = alloca i64
  store i64 %r.1077, ptr %t.31
  %t.1078 = load i64, ptr %t.31
  %ext.1080 = inttoptr i64 %t.1078 to ptr
  %r.1081 = call i1 @kx_str_eq(ptr %ext.1080, ptr @.str.84)
  %t.1082 = load i64, ptr %t.31
  %t.1083 = load ptr, ptr %o.addr
  %ext.1085 = inttoptr i64 %t.1082 to ptr
  %r.1086 = call i1 @kx_str_eq(ptr %ext.1085, ptr %t.1083)
  %t.1087 = and i1 %r.1081, %r.1086
  %ext.1088 = zext i1 %t.1087 to i64
  ret i64 %ext.1088
dead.1089:
  ret i64 0
}

define i64 @IsNameTok(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1090 = load i64, ptr %tokens.addr
  %t.1091 = load i64, ptr %pos.addr
  %r.1092 = call i64 @Peek(i64 %t.1090, i64 %t.1091)
  %t.32 = alloca i64
  store i64 %r.1092, ptr %t.32
  %t.1093 = load i64, ptr %t.32
  %ext.1095 = inttoptr i64 %t.1093 to ptr
  %r.1096 = call i1 @kx_str_eq(ptr %ext.1095, ptr @.str.15)
  %t.1097 = load i64, ptr %t.32
  %ext.1099 = inttoptr i64 %t.1097 to ptr
  %r.1100 = call i1 @kx_str_eq(ptr %ext.1099, ptr @.str.59)
  %t.1101 = or i1 %r.1096, %r.1100
  %ext.1102 = zext i1 %t.1101 to i64
  ret i64 %ext.1102
dead.1103:
  ret i64 0
}

define i64 @MatchKw(i64 %tokens, i64 %pos, ptr %w) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %w.addr = alloca ptr
  store ptr %w, ptr %w.addr
  %t.1104 = load i64, ptr %tokens.addr
  %t.1105 = load i64, ptr %pos.addr
  %t.1106 = load ptr, ptr %w.addr
  %r.1107 = call i64 @IsKw(i64 %t.1104, i64 %t.1105, ptr %t.1106)
  %ext.1108 = icmp ne i64 %r.1107, 0
  br i1 %ext.1108, label %if.then.1109, label %if.merge.1110
if.then.1109:
  %t.1111 = load i64, ptr %tokens.addr
  %t.1112 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1111, i64 %t.1112)
  %ext.1114 = zext i1 true to i64
  ret i64 %ext.1114
dead.1115:
  br label %if.merge.1110
if.merge.1110:
  %ext.1116 = zext i1 false to i64
  ret i64 %ext.1116
dead.1117:
  ret i64 0
}

define i64 @MatchPunct(i64 %tokens, i64 %pos, ptr %p) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %p.addr = alloca ptr
  store ptr %p, ptr %p.addr
  %t.1118 = load i64, ptr %tokens.addr
  %t.1119 = load i64, ptr %pos.addr
  %t.1120 = load ptr, ptr %p.addr
  %r.1121 = call i64 @IsPunct(i64 %t.1118, i64 %t.1119, ptr %t.1120)
  %ext.1122 = icmp ne i64 %r.1121, 0
  br i1 %ext.1122, label %if.then.1123, label %if.merge.1124
if.then.1123:
  %t.1125 = load i64, ptr %tokens.addr
  %t.1126 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1125, i64 %t.1126)
  %ext.1128 = zext i1 true to i64
  ret i64 %ext.1128
dead.1129:
  br label %if.merge.1124
if.merge.1124:
  %ext.1130 = zext i1 false to i64
  ret i64 %ext.1130
dead.1131:
  ret i64 0
}

define i64 @MatchOp(i64 %tokens, i64 %pos, ptr %o) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %o.addr = alloca ptr
  store ptr %o, ptr %o.addr
  %t.1132 = load i64, ptr %tokens.addr
  %t.1133 = load i64, ptr %pos.addr
  %t.1134 = load ptr, ptr %o.addr
  %r.1135 = call i64 @IsOp(i64 %t.1132, i64 %t.1133, ptr %t.1134)
  %ext.1136 = icmp ne i64 %r.1135, 0
  br i1 %ext.1136, label %if.then.1137, label %if.merge.1138
if.then.1137:
  %t.1139 = load i64, ptr %tokens.addr
  %t.1140 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1139, i64 %t.1140)
  %ext.1142 = zext i1 true to i64
  ret i64 %ext.1142
dead.1143:
  br label %if.merge.1138
if.merge.1138:
  %ext.1144 = zext i1 false to i64
  ret i64 %ext.1144
dead.1145:
  ret i64 0
}

define i64 @ExpectPunct(i64 %tokens, i64 %pos, ptr %p, i64 %errors, ptr %what) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %p.addr = alloca ptr
  store ptr %p, ptr %p.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %what.addr = alloca ptr
  store ptr %what, ptr %what.addr
  %t.1146 = load i64, ptr %tokens.addr
  %t.1147 = load i64, ptr %pos.addr
  %t.1148 = load ptr, ptr %p.addr
  %r.1149 = call i64 @MatchPunct(i64 %t.1146, i64 %t.1147, ptr %t.1148)
  %ext.1151 = icmp ne i64 %r.1149, 0
  %t.1150 = xor i1 %ext.1151, true
  br i1 %t.1150, label %if.then.1152, label %if.merge.1153
if.then.1152:
  %t.1154 = load i64, ptr %errors.addr
  %r.1155 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.1156 = load i64, ptr %tokens.addr
  %t.1157 = load i64, ptr %pos.addr
  %r.1158 = call i64 @CurLine(i64 %t.1156, i64 %t.1157)
  %r.1159 = call ptr @kx_int_str(i64 %r.1158)
  %r.1160 = call ptr @kx_str_cat(ptr %r.1155, ptr %r.1159)
  %r.1161 = call ptr @kx_str_cat(ptr %r.1160, ptr @.str.89)
  %t.1162 = load i64, ptr %tokens.addr
  %t.1163 = load i64, ptr %pos.addr
  %r.1164 = call i64 @CurCol(i64 %t.1162, i64 %t.1163)
  %r.1165 = call ptr @kx_int_str(i64 %r.1164)
  %r.1166 = call ptr @kx_str_cat(ptr %r.1161, ptr %r.1165)
  %r.1167 = call ptr @kx_str_cat(ptr %r.1166, ptr @.str.90)
  %t.1168 = load ptr, ptr %what.addr
  %r.1169 = call ptr @kx_str_cat(ptr %r.1167, ptr %t.1168)
  %r.1170 = call ptr @kx_str_cat(ptr %r.1169, ptr @.str.12)
  %ext.1171 = ptrtoint ptr %r.1170 to i64
  call void @kx_list_add(i64 %t.1154, i64 %ext.1171)
  %ext.1172 = zext i1 false to i64
  ret i64 %ext.1172
dead.1173:
  br label %if.merge.1153
if.merge.1153:
  %ext.1174 = zext i1 true to i64
  ret i64 %ext.1174
dead.1175:
  ret i64 0
}

define i64 @ExpectName(i64 %tokens, i64 %pos, i64 %errors, ptr %what) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %what.addr = alloca ptr
  store ptr %what, ptr %what.addr
  %t.1176 = load i64, ptr %tokens.addr
  %t.1177 = load i64, ptr %pos.addr
  %r.1178 = call i64 @IsNameTok(i64 %t.1176, i64 %t.1177)
  %ext.1179 = icmp ne i64 %r.1178, 0
  br i1 %ext.1179, label %if.then.1180, label %if.merge.1181
if.then.1180:
  %t.1182 = load i64, ptr %tokens.addr
  %t.1183 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1182, i64 %t.1183)
  %ext.1185 = zext i1 true to i64
  ret i64 %ext.1185
dead.1186:
  br label %if.merge.1181
if.merge.1181:
  %t.1187 = load i64, ptr %errors.addr
  %r.1188 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.1189 = load i64, ptr %tokens.addr
  %t.1190 = load i64, ptr %pos.addr
  %r.1191 = call i64 @CurLine(i64 %t.1189, i64 %t.1190)
  %r.1192 = call ptr @kx_int_str(i64 %r.1191)
  %r.1193 = call ptr @kx_str_cat(ptr %r.1188, ptr %r.1192)
  %r.1194 = call ptr @kx_str_cat(ptr %r.1193, ptr @.str.89)
  %t.1195 = load i64, ptr %tokens.addr
  %t.1196 = load i64, ptr %pos.addr
  %r.1197 = call i64 @CurCol(i64 %t.1195, i64 %t.1196)
  %r.1198 = call ptr @kx_int_str(i64 %r.1197)
  %r.1199 = call ptr @kx_str_cat(ptr %r.1194, ptr %r.1198)
  %r.1200 = call ptr @kx_str_cat(ptr %r.1199, ptr @.str.90)
  %t.1201 = load ptr, ptr %what.addr
  %r.1202 = call ptr @kx_str_cat(ptr %r.1200, ptr %t.1201)
  %r.1203 = call ptr @kx_str_cat(ptr %r.1202, ptr @.str.12)
  %ext.1204 = ptrtoint ptr %r.1203 to i64
  call void @kx_list_add(i64 %t.1187, i64 %ext.1204)
  %ext.1205 = zext i1 false to i64
  ret i64 %ext.1205
dead.1206:
  ret i64 0
}

define i64 @PrevText(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.1207 = load i64, ptr %tokens.addr
  %t.1208 = load i64, ptr %pos.addr
  %ext.1210 = sext i32 0 to i64
  %r.1209 = call i64 @kx_list_get(i64 %t.1208, i64 %ext.1210)
  %ext.1211 = sext i32 1 to i64
  %t.1212 = sub i64 %r.1209, %ext.1211
  %r.1213 = call i64 @kx_list_get(i64 %t.1207, i64 %t.1212)
  ret i64 %r.1213
dead.1214:
  ret i64 0
}

define i64 @ParsePrimary(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.1215 = load i64, ptr %tokens.addr
  %t.1216 = load i64, ptr %pos.addr
  %r.1217 = call i64 @Peek(i64 %t.1215, i64 %t.1216)
  %t.33 = alloca i64
  store i64 %r.1217, ptr %t.33
  %t.1218 = load i64, ptr %arena.addr
  %t.1219 = load i64, ptr %t.33
  %t.1220 = load i64, ptr %t.33
  %r.1221 = call i64 @NewNode(i64 %t.1218, ptr @.str.91, ptr @.str.12, i64 %t.1219, i64 %t.1220)
  %loc.34 = alloca i64
  store i64 %r.1221, ptr %loc.34
  %t.1222 = load i64, ptr %t.33
  %ext.1224 = inttoptr i64 %t.1222 to ptr
  %r.1225 = call i1 @kx_str_eq(ptr %ext.1224, ptr @.str.24)
  br i1 %r.1225, label %if.then.1226, label %if.merge.1227
if.then.1226:
  %t.1228 = load i64, ptr %tokens.addr
  %t.1229 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1228, i64 %t.1229)
  %t.1231 = load i64, ptr %arena.addr
  %t.1232 = load i64, ptr %t.33
  %cast.1233 = inttoptr i64 %t.1232 to ptr
  %t.1234 = load i64, ptr %t.33
  %t.1235 = load i64, ptr %t.33
  %r.1236 = call i64 @NewNode(i64 %t.1231, ptr @.str.24, ptr %cast.1233, i64 %t.1234, i64 %t.1235)
  ret i64 %r.1236
dead.1237:
  br label %if.merge.1227
if.merge.1227:
  %t.1238 = load i64, ptr %t.33
  %ext.1240 = inttoptr i64 %t.1238 to ptr
  %r.1241 = call i1 @kx_str_eq(ptr %ext.1240, ptr @.str.26)
  br i1 %r.1241, label %if.then.1242, label %if.merge.1243
if.then.1242:
  %t.1244 = load i64, ptr %tokens.addr
  %t.1245 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1244, i64 %t.1245)
  %t.1247 = load i64, ptr %arena.addr
  %t.1248 = load i64, ptr %t.33
  %cast.1249 = inttoptr i64 %t.1248 to ptr
  %t.1250 = load i64, ptr %t.33
  %t.1251 = load i64, ptr %t.33
  %r.1252 = call i64 @NewNode(i64 %t.1247, ptr @.str.26, ptr %cast.1249, i64 %t.1250, i64 %t.1251)
  ret i64 %r.1252
dead.1253:
  br label %if.merge.1243
if.merge.1243:
  %t.1254 = load i64, ptr %t.33
  %ext.1256 = inttoptr i64 %t.1254 to ptr
  %r.1257 = call i1 @kx_str_eq(ptr %ext.1256, ptr @.str.30)
  br i1 %r.1257, label %if.then.1258, label %if.merge.1259
if.then.1258:
  %t.1260 = load i64, ptr %tokens.addr
  %t.1261 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1260, i64 %t.1261)
  %t.1263 = load i64, ptr %arena.addr
  %t.1264 = load i64, ptr %t.33
  %cast.1265 = inttoptr i64 %t.1264 to ptr
  %t.1266 = load i64, ptr %t.33
  %t.1267 = load i64, ptr %t.33
  %r.1268 = call i64 @NewNode(i64 %t.1263, ptr @.str.30, ptr %cast.1265, i64 %t.1266, i64 %t.1267)
  ret i64 %r.1268
dead.1269:
  br label %if.merge.1259
if.merge.1259:
  %t.1270 = load i64, ptr %t.33
  %ext.1272 = inttoptr i64 %t.1270 to ptr
  %r.1273 = call i1 @kx_str_eq(ptr %ext.1272, ptr @.str.66)
  br i1 %r.1273, label %if.then.1274, label %if.merge.1275
if.then.1274:
  %t.1276 = load i64, ptr %tokens.addr
  %t.1277 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1276, i64 %t.1277)
  %t.1279 = load i64, ptr %arena.addr
  %t.1280 = load i64, ptr %t.33
  %cast.1281 = inttoptr i64 %t.1280 to ptr
  %t.1282 = load i64, ptr %t.33
  %t.1283 = load i64, ptr %t.33
  %r.1284 = call i64 @ParseInterpolated(i64 %t.1279, ptr %cast.1281, i64 %t.1282, i64 %t.1283)
  ret i64 %r.1284
dead.1285:
  br label %if.merge.1275
if.merge.1275:
  %t.1286 = load i64, ptr %t.33
  %ext.1288 = inttoptr i64 %t.1286 to ptr
  %r.1289 = call i1 @kx_str_eq(ptr %ext.1288, ptr @.str.59)
  %t.1290 = load i64, ptr %t.33
  %ext.1292 = inttoptr i64 %t.1290 to ptr
  %r.1293 = call i1 @kx_str_eq(ptr %ext.1292, ptr @.str.50)
  %t.1294 = and i1 %r.1289, %r.1293
  br i1 %t.1294, label %if.then.1295, label %if.merge.1296
if.then.1295:
  %t.1297 = load i64, ptr %tokens.addr
  %t.1298 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1297, i64 %t.1298)
  %t.1300 = load i64, ptr %arena.addr
  %t.1301 = load i64, ptr %t.33
  %t.1302 = load i64, ptr %t.33
  %r.1303 = call i64 @NewNode(i64 %t.1300, ptr @.str.28, ptr @.str.50, i64 %t.1301, i64 %t.1302)
  ret i64 %r.1303
dead.1304:
  br label %if.merge.1296
if.merge.1296:
  %t.1305 = load i64, ptr %t.33
  %ext.1307 = inttoptr i64 %t.1305 to ptr
  %r.1308 = call i1 @kx_str_eq(ptr %ext.1307, ptr @.str.59)
  %t.1309 = load i64, ptr %t.33
  %ext.1311 = inttoptr i64 %t.1309 to ptr
  %r.1312 = call i1 @kx_str_eq(ptr %ext.1311, ptr @.str.51)
  %t.1313 = and i1 %r.1308, %r.1312
  br i1 %t.1313, label %if.then.1314, label %if.merge.1315
if.then.1314:
  %t.1316 = load i64, ptr %tokens.addr
  %t.1317 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1316, i64 %t.1317)
  %t.1319 = load i64, ptr %arena.addr
  %t.1320 = load i64, ptr %t.33
  %t.1321 = load i64, ptr %t.33
  %r.1322 = call i64 @NewNode(i64 %t.1319, ptr @.str.28, ptr @.str.51, i64 %t.1320, i64 %t.1321)
  ret i64 %r.1322
dead.1323:
  br label %if.merge.1315
if.merge.1315:
  %t.1324 = load i64, ptr %t.33
  %ext.1326 = inttoptr i64 %t.1324 to ptr
  %r.1327 = call i1 @kx_str_eq(ptr %ext.1326, ptr @.str.59)
  %t.1328 = load i64, ptr %t.33
  %ext.1330 = inttoptr i64 %t.1328 to ptr
  %r.1331 = call i1 @kx_str_eq(ptr %ext.1330, ptr @.str.44)
  %t.1332 = and i1 %r.1327, %r.1331
  br i1 %t.1332, label %if.then.1333, label %if.merge.1334
if.then.1333:
  %t.1335 = load i64, ptr %tokens.addr
  %t.1336 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1335, i64 %t.1336)
  %t.1338 = load i64, ptr %arena.addr
  %t.1339 = load i64, ptr %t.33
  %t.1340 = load i64, ptr %t.33
  %r.1341 = call i64 @NewNode(i64 %t.1338, ptr @.str.92, ptr @.str.44, i64 %t.1339, i64 %t.1340)
  ret i64 %r.1341
dead.1342:
  br label %if.merge.1334
if.merge.1334:
  %t.1343 = load i64, ptr %t.33
  %ext.1345 = inttoptr i64 %t.1343 to ptr
  %r.1346 = call i1 @kx_str_eq(ptr %ext.1345, ptr @.str.59)
  %t.1347 = load i64, ptr %t.33
  %ext.1349 = inttoptr i64 %t.1347 to ptr
  %r.1350 = call i1 @kx_str_eq(ptr %ext.1349, ptr @.str.40)
  %t.1351 = and i1 %r.1346, %r.1350
  br i1 %t.1351, label %if.then.1352, label %if.merge.1353
if.then.1352:
  %t.1354 = load i64, ptr %tokens.addr
  %t.1355 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1354, i64 %t.1355)
  %t.1357 = load i64, ptr %tokens.addr
  %t.1358 = load i64, ptr %pos.addr
  %t.1359 = load i64, ptr %arena.addr
  %t.1360 = load i64, ptr %errors.addr
  %r.1361 = call i64 @ParseSpawn(i64 %t.1357, i64 %t.1358, i64 %t.1359, i64 %t.1360)
  ret i64 %r.1361
dead.1362:
  br label %if.merge.1353
if.merge.1353:
  %t.1363 = load i64, ptr %t.33
  %ext.1365 = inttoptr i64 %t.1363 to ptr
  %r.1366 = call i1 @kx_str_eq(ptr %ext.1365, ptr @.str.15)
  br i1 %r.1366, label %if.then.1367, label %if.merge.1368
if.then.1367:
  %t.1369 = load i64, ptr %tokens.addr
  %t.1370 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1369, i64 %t.1370)
  %t.1372 = load i64, ptr %tokens.addr
  %t.1373 = load i64, ptr %pos.addr
  %r.1374 = call i64 @IsPunct(i64 %t.1372, i64 %t.1373, ptr @.str.63)
  %ext.1375 = icmp ne i64 %r.1374, 0
  br i1 %ext.1375, label %if.then.1376, label %if.merge.1377
if.then.1376:
  %t.1378 = load i64, ptr %tokens.addr
  %t.1379 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1378, i64 %t.1379)
  %t.1381 = load i64, ptr %arena.addr
  %t.1382 = load i64, ptr %t.33
  %cast.1383 = inttoptr i64 %t.1382 to ptr
  %t.1384 = load i64, ptr %t.33
  %t.1385 = load i64, ptr %t.33
  %r.1386 = call i64 @NewNode(i64 %t.1381, ptr @.str.93, ptr %cast.1383, i64 %t.1384, i64 %t.1385)
  %node.35 = alloca i64
  store i64 %r.1386, ptr %node.35
  br label %w.cond.1387
w.cond.1387:
  %t.1390 = load i64, ptr %tokens.addr
  %t.1391 = load i64, ptr %pos.addr
  %r.1392 = call i64 @IsPunct(i64 %t.1390, i64 %t.1391, ptr @.str.64)
  %ext.1394 = icmp ne i64 %r.1392, 0
  %t.1393 = xor i1 %ext.1394, true
  %t.1395 = load i64, ptr %tokens.addr
  %t.1396 = load i64, ptr %pos.addr
  %r.1397 = call i64 @AtEnd(i64 %t.1395, i64 %t.1396)
  %ext.1399 = icmp ne i64 %r.1397, 0
  %t.1398 = xor i1 %ext.1399, true
  %t.1400 = and i1 %t.1393, %t.1398
  br i1 %t.1400, label %w.body.1388, label %w.end.1389
w.body.1388:
  %t.1401 = load i64, ptr %tokens.addr
  %t.1402 = load i64, ptr %pos.addr
  %r.1403 = call i64 @IsNameTok(i64 %t.1401, i64 %t.1402)
  %ext.1405 = icmp ne i64 %r.1403, 0
  %t.1404 = xor i1 %ext.1405, true
  br i1 %t.1404, label %if.then.1406, label %if.merge.1407
if.then.1406:
  br label %w.end.1389
dead.1408:
  br label %if.merge.1407
if.merge.1407:
  %t.1409 = load i64, ptr %tokens.addr
  %t.1410 = load i64, ptr %pos.addr
  %r.1411 = call ptr @CurText(i64 %t.1409, i64 %t.1410)
  %fname.36 = alloca ptr
  store ptr %r.1411, ptr %fname.36
  %t.1412 = load i64, ptr %tokens.addr
  %t.1413 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1412, i64 %t.1413)
  %t.1415 = load i64, ptr %tokens.addr
  %t.1416 = load i64, ptr %pos.addr
  %t.1417 = load i64, ptr %errors.addr
  %r.1418 = call i64 @ExpectPunct(i64 %t.1415, i64 %t.1416, ptr @.str.94, i64 %t.1417, ptr @.str.95)
  %ext.1420 = icmp ne i64 %r.1418, 0
  %t.1419 = xor i1 %ext.1420, true
  br i1 %t.1419, label %if.then.1421, label %if.merge.1422
if.then.1421:
  br label %w.end.1389
dead.1423:
  br label %if.merge.1422
if.merge.1422:
  %t.1424 = load i64, ptr %arena.addr
  %t.1425 = load ptr, ptr %fname.36
  %t.1426 = load i64, ptr %t.33
  %t.1427 = load i64, ptr %t.33
  %r.1428 = call i64 @NewNode(i64 %t.1424, ptr @.str.96, ptr %t.1425, i64 %t.1426, i64 %t.1427)
  %initNode.37 = alloca i64
  store i64 %r.1428, ptr %initNode.37
  %t.1429 = load i64, ptr %arena.addr
  %t.1430 = load i64, ptr %initNode.37
  %t.1431 = load i64, ptr %tokens.addr
  %t.1432 = load i64, ptr %pos.addr
  %t.1433 = load i64, ptr %arena.addr
  %t.1434 = load i64, ptr %errors.addr
  %r.1435 = call i64 @ParseExpression(i64 %t.1431, i64 %t.1432, i64 %t.1433, i64 %t.1434)
  call void @AddChild(i64 %t.1429, i64 %t.1430, i64 %r.1435)
  %t.1437 = load i64, ptr %arena.addr
  %t.1438 = load i64, ptr %node.35
  %t.1439 = load i64, ptr %initNode.37
  call void @AddChild(i64 %t.1437, i64 %t.1438, i64 %t.1439)
  %t.1441 = load i64, ptr %tokens.addr
  %t.1442 = load i64, ptr %pos.addr
  %r.1443 = call i64 @MatchPunct(i64 %t.1441, i64 %t.1442, ptr @.str.97)
  %ext.1445 = icmp ne i64 %r.1443, 0
  %t.1444 = xor i1 %ext.1445, true
  br i1 %t.1444, label %if.then.1446, label %if.merge.1447
if.then.1446:
  br label %w.end.1389
dead.1448:
  br label %if.merge.1447
if.merge.1447:
  br label %w.cond.1387
w.end.1389:
  %t.1449 = load i64, ptr %tokens.addr
  %t.1450 = load i64, ptr %pos.addr
  %t.1451 = load i64, ptr %errors.addr
  %r.1452 = call i64 @ExpectPunct(i64 %t.1449, i64 %t.1450, ptr @.str.64, i64 %t.1451, ptr @.str.98)
  %t.1453 = load i64, ptr %node.35
  ret i64 %t.1453
dead.1454:
  br label %if.merge.1377
if.merge.1377:
  %t.1455 = load i64, ptr %tokens.addr
  %t.1456 = load i64, ptr %pos.addr
  %r.1457 = call i64 @IsPunct(i64 %t.1455, i64 %t.1456, ptr @.str.99)
  %ext.1458 = icmp ne i64 %r.1457, 0
  br i1 %ext.1458, label %if.then.1459, label %if.merge.1460
if.then.1459:
  %t.1461 = load i64, ptr %tokens.addr
  %t.1462 = load i64, ptr %pos.addr
  %t.1463 = load i64, ptr %arena.addr
  %t.1464 = load i64, ptr %errors.addr
  %t.1465 = load i64, ptr %arena.addr
  %t.1466 = load i64, ptr %t.33
  %cast.1467 = inttoptr i64 %t.1466 to ptr
  %t.1468 = load i64, ptr %t.33
  %t.1469 = load i64, ptr %t.33
  %r.1470 = call i64 @NewNode(i64 %t.1465, ptr @.str.92, ptr %cast.1467, i64 %t.1468, i64 %t.1469)
  %r.1471 = call i64 @kx_list_new(i32 0)
  %r.1472 = call i64 @ParseCall(i64 %t.1461, i64 %t.1462, i64 %t.1463, i64 %t.1464, i64 %r.1470, i64 %r.1471)
  ret i64 %r.1472
dead.1473:
  br label %if.merge.1460
if.merge.1460:
  %t.1474 = load i64, ptr %arena.addr
  %t.1475 = load i64, ptr %t.33
  %cast.1476 = inttoptr i64 %t.1475 to ptr
  %t.1477 = load i64, ptr %t.33
  %t.1478 = load i64, ptr %t.33
  %r.1479 = call i64 @NewNode(i64 %t.1474, ptr @.str.92, ptr %cast.1476, i64 %t.1477, i64 %t.1478)
  ret i64 %r.1479
dead.1480:
  br label %if.merge.1368
if.merge.1368:
  %t.1481 = load i64, ptr %tokens.addr
  %t.1482 = load i64, ptr %pos.addr
  %r.1483 = call i64 @IsPunct(i64 %t.1481, i64 %t.1482, ptr @.str.99)
  %ext.1484 = icmp ne i64 %r.1483, 0
  br i1 %ext.1484, label %if.then.1485, label %if.merge.1486
if.then.1485:
  %t.1487 = load i64, ptr %tokens.addr
  %t.1488 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1487, i64 %t.1488)
  %t.1490 = load i64, ptr %tokens.addr
  %t.1491 = load i64, ptr %pos.addr
  %t.1492 = load i64, ptr %arena.addr
  %t.1493 = load i64, ptr %errors.addr
  %r.1494 = call i64 @ParseExpression(i64 %t.1490, i64 %t.1491, i64 %t.1492, i64 %t.1493)
  %inner.38 = alloca i64
  store i64 %r.1494, ptr %inner.38
  %t.1495 = load i64, ptr %tokens.addr
  %t.1496 = load i64, ptr %pos.addr
  %t.1497 = load i64, ptr %errors.addr
  %r.1498 = call i64 @ExpectPunct(i64 %t.1495, i64 %t.1496, ptr @.str.100, i64 %t.1497, ptr @.str.101)
  %t.1499 = load i64, ptr %inner.38
  ret i64 %t.1499
dead.1500:
  br label %if.merge.1486
if.merge.1486:
  %t.1501 = load i64, ptr %errors.addr
  %r.1502 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.1503 = load i64, ptr %t.33
  %r.1504 = call ptr @kx_int_str(i64 %t.1503)
  %r.1505 = call ptr @kx_str_cat(ptr %r.1502, ptr %r.1504)
  %r.1506 = call ptr @kx_str_cat(ptr %r.1505, ptr @.str.89)
  %t.1507 = load i64, ptr %t.33
  %r.1508 = call ptr @kx_int_str(i64 %t.1507)
  %r.1509 = call ptr @kx_str_cat(ptr %r.1506, ptr %r.1508)
  %r.1510 = call ptr @kx_str_cat(ptr %r.1509, ptr @.str.102)
  %ext.1511 = ptrtoint ptr %r.1510 to i64
  call void @kx_list_add(i64 %t.1501, i64 %ext.1511)
  %t.1512 = load i64, ptr %tokens.addr
  %t.1513 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1512, i64 %t.1513)
  %t.1515 = load i64, ptr %arena.addr
  %t.1516 = load i64, ptr %t.33
  %t.1517 = load i64, ptr %t.33
  %r.1518 = call i64 @NewNode(i64 %t.1515, ptr @.str.24, ptr @.str.1, i64 %t.1516, i64 %t.1517)
  ret i64 %r.1518
dead.1519:
  ret i64 0
}

define i64 @ParseCall(i64 %tokens, i64 %pos, i64 %arena, i64 %errors, i64 %callee, i64 %typeArgs) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %callee.addr = alloca i64
  store i64 %callee, ptr %callee.addr
  %typeArgs.addr = alloca i64
  store i64 %typeArgs, ptr %typeArgs.addr
  %t.1520 = load i64, ptr %arena.addr
  %t.1521 = load i64, ptr %tokens.addr
  %t.1522 = load i64, ptr %pos.addr
  %r.1523 = call i64 @CurLine(i64 %t.1521, i64 %t.1522)
  %t.1524 = load i64, ptr %tokens.addr
  %t.1525 = load i64, ptr %pos.addr
  %r.1526 = call i64 @CurCol(i64 %t.1524, i64 %t.1525)
  %r.1527 = call i64 @NewNode(i64 %t.1520, ptr @.str.103, ptr @.str.12, i64 %r.1523, i64 %r.1526)
  %node.39 = alloca i64
  store i64 %r.1527, ptr %node.39
  %t.1528 = load i64, ptr %arena.addr
  %t.1529 = load i64, ptr %node.39
  %t.1530 = load i64, ptr %callee.addr
  call void @AddChild(i64 %t.1528, i64 %t.1529, i64 %t.1530)
  %_tai.40 = alloca i32
  store i32 0, ptr %_tai.40
  br label %for.cond.1532
for.cond.1532:
  %t.1536 = load i32, ptr %_tai.40
  %t.1537 = load i64, ptr %typeArgs.addr
  %r.1538 = call i64 @kx_list_size(i64 %t.1537)
  %ext.1539 = sext i32 %t.1536 to i64
  %t.1540 = icmp slt i64 %ext.1539, %r.1538
  br i1 %t.1540, label %for.body.1533, label %for.end.1535
for.body.1533:
  %t.1541 = load i64, ptr %typeArgs.addr
  %t.1542 = load i32, ptr %_tai.40
  %ext.1544 = sext i32 %t.1542 to i64
  %r.1543 = call i64 @kx_list_get(i64 %t.1541, i64 %ext.1544)
  %ta.41 = alloca i64
  store i64 %r.1543, ptr %ta.41
  %t.1545 = load i64, ptr %arena.addr
  %t.1546 = load i64, ptr %ta.41
  %cast.1547 = inttoptr i64 %t.1546 to ptr
  %cast.1548 = sext i32 0 to i64
  %cast.1549 = sext i32 0 to i64
  %r.1550 = call i64 @NewNode(i64 %t.1545, ptr @.str.104, ptr %cast.1547, i64 %cast.1548, i64 %cast.1549)
  %taNode.42 = alloca i64
  store i64 %r.1550, ptr %taNode.42
  %t.1551 = load i64, ptr %arena.addr
  %t.1552 = load i64, ptr %node.39
  %t.1553 = load i64, ptr %taNode.42
  call void @AddChild(i64 %t.1551, i64 %t.1552, i64 %t.1553)
  br label %for.inc.1534
for.inc.1534:
  %t.1555 = load i32, ptr %_tai.40
  %t.1556 = add i32 %t.1555, 1
  store i32 %t.1556, ptr %_tai.40
  br label %for.cond.1532
for.end.1535:
  %t.1557 = load i64, ptr %tokens.addr
  %t.1558 = load i64, ptr %pos.addr
  %t.1559 = load i64, ptr %errors.addr
  %r.1560 = call i64 @ExpectPunct(i64 %t.1557, i64 %t.1558, ptr @.str.99, i64 %t.1559, ptr @.str.105)
  %ext.1562 = icmp ne i64 %r.1560, 0
  %t.1561 = xor i1 %ext.1562, true
  br i1 %t.1561, label %if.then.1563, label %if.merge.1564
if.then.1563:
  %t.1565 = load i64, ptr %node.39
  ret i64 %t.1565
dead.1566:
  br label %if.merge.1564
if.merge.1564:
  br label %w.cond.1567
w.cond.1567:
  %t.1570 = load i64, ptr %tokens.addr
  %t.1571 = load i64, ptr %pos.addr
  %r.1572 = call i64 @IsPunct(i64 %t.1570, i64 %t.1571, ptr @.str.100)
  %ext.1574 = icmp ne i64 %r.1572, 0
  %t.1573 = xor i1 %ext.1574, true
  %t.1575 = load i64, ptr %tokens.addr
  %t.1576 = load i64, ptr %pos.addr
  %r.1577 = call i64 @AtEnd(i64 %t.1575, i64 %t.1576)
  %ext.1579 = icmp ne i64 %r.1577, 0
  %t.1578 = xor i1 %ext.1579, true
  %t.1580 = and i1 %t.1573, %t.1578
  br i1 %t.1580, label %w.body.1568, label %w.end.1569
w.body.1568:
  %t.1581 = load i64, ptr %arena.addr
  %t.1582 = load i64, ptr %tokens.addr
  %t.1583 = load i64, ptr %pos.addr
  %r.1584 = call i64 @CurLine(i64 %t.1582, i64 %t.1583)
  %t.1585 = load i64, ptr %tokens.addr
  %t.1586 = load i64, ptr %pos.addr
  %r.1587 = call i64 @CurCol(i64 %t.1585, i64 %t.1586)
  %r.1588 = call i64 @NewNode(i64 %t.1581, ptr @.str.106, ptr @.str.12, i64 %r.1584, i64 %r.1587)
  %argNode.43 = alloca i64
  store i64 %r.1588, ptr %argNode.43
  %t.1589 = load i64, ptr %tokens.addr
  %t.1590 = load i64, ptr %pos.addr
  %r.1591 = call i64 @IsNameTok(i64 %t.1589, i64 %t.1590)
  %ext.1592 = icmp ne i64 %r.1591, 0
  br i1 %ext.1592, label %if.then.1593, label %if.merge.1594
if.then.1593:
  %t.1595 = load i64, ptr %tokens.addr
  %t.1596 = load i64, ptr %pos.addr
  %r.1597 = call i64 @Peek(i64 %t.1595, i64 %t.1596)
  %maybeName.44 = alloca i64
  store i64 %r.1597, ptr %maybeName.44
  %t.1598 = load i64, ptr %tokens.addr
  %t.1599 = load i64, ptr %pos.addr
  %ext.1601 = sext i32 0 to i64
  %r.1600 = call i64 @kx_list_get(i64 %t.1599, i64 %ext.1601)
  %ext.1602 = sext i32 1 to i64
  %t.1603 = add i64 %r.1600, %ext.1602
  %r.1604 = call i64 @kx_list_get(i64 %t.1598, i64 %t.1603)
  %next.45 = alloca i64
  store i64 %r.1604, ptr %next.45
  %t.1605 = load i64, ptr %next.45
  %ext.1607 = inttoptr i64 %t.1605 to ptr
  %r.1608 = call i1 @kx_str_eq(ptr %ext.1607, ptr @.str.85)
  %t.1609 = load i64, ptr %next.45
  %ext.1611 = inttoptr i64 %t.1609 to ptr
  %r.1612 = call i1 @kx_str_eq(ptr %ext.1611, ptr @.str.89)
  %t.1613 = and i1 %r.1608, %r.1612
  br i1 %t.1613, label %if.then.1614, label %if.merge.1615
if.then.1614:
  %t.1616 = load i64, ptr %tokens.addr
  %t.1617 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1616, i64 %t.1617)
  %t.1619 = load i64, ptr %tokens.addr
  %t.1620 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1619, i64 %t.1620)
  %t.1622 = load i64, ptr %arena.addr
  %t.1623 = load i64, ptr %maybeName.44
  %cast.1624 = inttoptr i64 %t.1623 to ptr
  %t.1625 = load i64, ptr %maybeName.44
  %t.1626 = load i64, ptr %maybeName.44
  %r.1627 = call i64 @NewNode(i64 %t.1622, ptr @.str.107, ptr %cast.1624, i64 %t.1625, i64 %t.1626)
  %nameNode.46 = alloca i64
  store i64 %r.1627, ptr %nameNode.46
  %t.1628 = load i64, ptr %arena.addr
  %t.1629 = load i64, ptr %argNode.43
  %t.1630 = load i64, ptr %nameNode.46
  call void @AddChild(i64 %t.1628, i64 %t.1629, i64 %t.1630)
  br label %if.merge.1615
if.merge.1615:
  br label %if.merge.1594
if.merge.1594:
  %t.1632 = load i64, ptr %arena.addr
  %t.1633 = load i64, ptr %argNode.43
  %t.1634 = load i64, ptr %tokens.addr
  %t.1635 = load i64, ptr %pos.addr
  %t.1636 = load i64, ptr %arena.addr
  %t.1637 = load i64, ptr %errors.addr
  %r.1638 = call i64 @ParseExpression(i64 %t.1634, i64 %t.1635, i64 %t.1636, i64 %t.1637)
  call void @AddChild(i64 %t.1632, i64 %t.1633, i64 %r.1638)
  %t.1640 = load i64, ptr %arena.addr
  %t.1641 = load i64, ptr %node.39
  %t.1642 = load i64, ptr %argNode.43
  call void @AddChild(i64 %t.1640, i64 %t.1641, i64 %t.1642)
  %t.1644 = load i64, ptr %tokens.addr
  %t.1645 = load i64, ptr %pos.addr
  %r.1646 = call i64 @MatchPunct(i64 %t.1644, i64 %t.1645, ptr @.str.97)
  %ext.1648 = icmp ne i64 %r.1646, 0
  %t.1647 = xor i1 %ext.1648, true
  br i1 %t.1647, label %if.then.1649, label %if.merge.1650
if.then.1649:
  br label %w.end.1569
dead.1651:
  br label %if.merge.1650
if.merge.1650:
  br label %w.cond.1567
w.end.1569:
  %t.1652 = load i64, ptr %tokens.addr
  %t.1653 = load i64, ptr %pos.addr
  %t.1654 = load i64, ptr %errors.addr
  %r.1655 = call i64 @ExpectPunct(i64 %t.1652, i64 %t.1653, ptr @.str.100, i64 %t.1654, ptr @.str.101)
  %t.1656 = load i64, ptr %node.39
  ret i64 %t.1656
dead.1657:
  ret i64 0
}

define i64 @ParseTypeArgs(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %r.1658 = call i64 @kx_list_new(i32 0)
  %out.47 = alloca i64
  store i64 %r.1658, ptr %out.47
  %t.1659 = load i64, ptr %tokens.addr
  %t.1660 = load i64, ptr %pos.addr
  %r.1661 = call i64 @IsPunct(i64 %t.1659, i64 %t.1660, ptr @.str.108)
  %ext.1663 = icmp ne i64 %r.1661, 0
  %t.1662 = xor i1 %ext.1663, true
  br i1 %t.1662, label %if.then.1664, label %if.merge.1665
if.then.1664:
  %t.1666 = load i64, ptr %out.47
  ret i64 %t.1666
dead.1667:
  br label %if.merge.1665
if.merge.1665:
  %t.1668 = load i64, ptr %pos.addr
  %ext.1670 = sext i32 0 to i64
  %r.1669 = call i64 @kx_list_get(i64 %t.1668, i64 %ext.1670)
  %save.48 = alloca i64
  store i64 %r.1669, ptr %save.48
  %t.1671 = load i64, ptr %tokens.addr
  %t.1672 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1671, i64 %t.1672)
  br label %w.cond.1674
w.cond.1674:
  %t.1677 = load i64, ptr %tokens.addr
  %t.1678 = load i64, ptr %pos.addr
  %r.1679 = call i64 @IsNameTok(i64 %t.1677, i64 %t.1678)
  %t.1680 = load i64, ptr %tokens.addr
  %t.1681 = load i64, ptr %pos.addr
  %r.1682 = call i64 @IsPunct(i64 %t.1680, i64 %t.1681, ptr @.str.109)
  %ext.1684 = icmp ne i64 %r.1682, 0
  %t.1683 = xor i1 %ext.1684, true
  %ext.1686 = icmp ne i64 %r.1679, 0
  %t.1685 = and i1 %ext.1686, %t.1683
  br i1 %t.1685, label %w.body.1675, label %w.end.1676
w.body.1675:
  %t.1687 = load i64, ptr %out.47
  %t.1688 = load i64, ptr %tokens.addr
  %t.1689 = load i64, ptr %pos.addr
  %r.1690 = call ptr @CurText(i64 %t.1688, i64 %t.1689)
  %ext.1691 = ptrtoint ptr %r.1690 to i64
  call void @kx_list_add(i64 %t.1687, i64 %ext.1691)
  %t.1692 = load i64, ptr %tokens.addr
  %t.1693 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1692, i64 %t.1693)
  %t.1695 = load i64, ptr %tokens.addr
  %t.1696 = load i64, ptr %pos.addr
  %r.1697 = call i64 @MatchPunct(i64 %t.1695, i64 %t.1696, ptr @.str.97)
  %ext.1699 = icmp ne i64 %r.1697, 0
  %t.1698 = xor i1 %ext.1699, true
  br i1 %t.1698, label %if.then.1700, label %if.merge.1701
if.then.1700:
  br label %w.end.1676
dead.1702:
  br label %if.merge.1701
if.merge.1701:
  br label %w.cond.1674
w.end.1676:
  %t.1703 = load i64, ptr %tokens.addr
  %t.1704 = load i64, ptr %pos.addr
  %r.1705 = call i64 @MatchPunct(i64 %t.1703, i64 %t.1704, ptr @.str.109)
  %ext.1707 = icmp ne i64 %r.1705, 0
  %t.1706 = xor i1 %ext.1707, true
  br i1 %t.1706, label %if.then.1708, label %if.merge.1709
if.then.1708:
  %t.1710 = load i64, ptr %pos.addr
  %t.1711 = load i64, ptr %save.48
  %ext.1712 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.1710, i64 %ext.1712, i64 %t.1711)
  %r.1713 = call i64 @kx_list_new(i32 0)
  ret i64 %r.1713
dead.1714:
  br label %if.merge.1709
if.merge.1709:
  %t.1715 = load i64, ptr %out.47
  ret i64 %t.1715
dead.1716:
  ret i64 0
}

define i64 @ParsePostfix(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.1717 = load i64, ptr %tokens.addr
  %t.1718 = load i64, ptr %pos.addr
  %t.1719 = load i64, ptr %arena.addr
  %t.1720 = load i64, ptr %errors.addr
  %r.1721 = call i64 @ParsePrimary(i64 %t.1717, i64 %t.1718, i64 %t.1719, i64 %t.1720)
  %e.49 = alloca i64
  store i64 %r.1721, ptr %e.49
  br label %for.cond.1722
for.cond.1722:
  br label %for.body.1723
for.body.1723:
  %t.1726 = load i64, ptr %tokens.addr
  %t.1727 = load i64, ptr %pos.addr
  %r.1728 = call i64 @MatchPunct(i64 %t.1726, i64 %t.1727, ptr @.str.60)
  %ext.1729 = icmp ne i64 %r.1728, 0
  br i1 %ext.1729, label %if.then.1730, label %if.merge.1731
if.then.1730:
  %t.1732 = load i64, ptr %tokens.addr
  %t.1733 = load i64, ptr %pos.addr
  %r.1734 = call i64 @IsNameTok(i64 %t.1732, i64 %t.1733)
  %ext.1736 = icmp ne i64 %r.1734, 0
  %t.1735 = xor i1 %ext.1736, true
  br i1 %t.1735, label %if.then.1737, label %if.merge.1738
if.then.1737:
  %t.1739 = load i64, ptr %errors.addr
  %r.1740 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.1741 = load i64, ptr %tokens.addr
  %t.1742 = load i64, ptr %pos.addr
  %r.1743 = call i64 @CurLine(i64 %t.1741, i64 %t.1742)
  %r.1744 = call ptr @kx_int_str(i64 %r.1743)
  %r.1745 = call ptr @kx_str_cat(ptr %r.1740, ptr %r.1744)
  %r.1746 = call ptr @kx_str_cat(ptr %r.1745, ptr @.str.89)
  %t.1747 = load i64, ptr %tokens.addr
  %t.1748 = load i64, ptr %pos.addr
  %r.1749 = call i64 @CurCol(i64 %t.1747, i64 %t.1748)
  %r.1750 = call ptr @kx_int_str(i64 %r.1749)
  %r.1751 = call ptr @kx_str_cat(ptr %r.1746, ptr %r.1750)
  %r.1752 = call ptr @kx_str_cat(ptr %r.1751, ptr @.str.110)
  %ext.1753 = ptrtoint ptr %r.1752 to i64
  call void @kx_list_add(i64 %t.1739, i64 %ext.1753)
  %t.1754 = load i64, ptr %e.49
  ret i64 %t.1754
dead.1755:
  br label %if.merge.1738
if.merge.1738:
  %t.1756 = load i64, ptr %arena.addr
  %t.1757 = load i64, ptr %tokens.addr
  %t.1758 = load i64, ptr %pos.addr
  %r.1759 = call ptr @CurText(i64 %t.1757, i64 %t.1758)
  %t.1760 = load i64, ptr %tokens.addr
  %t.1761 = load i64, ptr %pos.addr
  %r.1762 = call i64 @CurLine(i64 %t.1760, i64 %t.1761)
  %t.1763 = load i64, ptr %tokens.addr
  %t.1764 = load i64, ptr %pos.addr
  %r.1765 = call i64 @CurCol(i64 %t.1763, i64 %t.1764)
  %r.1766 = call i64 @NewNode(i64 %t.1756, ptr @.str.111, ptr %r.1759, i64 %r.1762, i64 %r.1765)
  %m.50 = alloca i64
  store i64 %r.1766, ptr %m.50
  %t.1767 = load i64, ptr %tokens.addr
  %t.1768 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1767, i64 %t.1768)
  %t.1770 = load i64, ptr %arena.addr
  %t.1771 = load i64, ptr %m.50
  %t.1772 = load i64, ptr %e.49
  call void @AddChild(i64 %t.1770, i64 %t.1771, i64 %t.1772)
  %t.1774 = load i64, ptr %m.50
  store i64 %t.1774, ptr %e.49
  br label %for.inc.1724
dead.1775:
  br label %if.merge.1731
if.merge.1731:
  %t.1776 = load i64, ptr %tokens.addr
  %t.1777 = load i64, ptr %pos.addr
  %r.1778 = call i64 @IsPunct(i64 %t.1776, i64 %t.1777, ptr @.str.108)
  %ext.1779 = icmp ne i64 %r.1778, 0
  br i1 %ext.1779, label %if.then.1780, label %if.merge.1781
if.then.1780:
  %t.1782 = load i64, ptr %pos.addr
  %ext.1784 = sext i32 0 to i64
  %r.1783 = call i64 @kx_list_get(i64 %t.1782, i64 %ext.1784)
  %savePos.51 = alloca i64
  store i64 %r.1783, ptr %savePos.51
  %t.1785 = load i64, ptr %tokens.addr
  %t.1786 = load i64, ptr %pos.addr
  %r.1787 = call i64 @ParseTypeArgs(i64 %t.1785, i64 %t.1786)
  %typeArgs.52 = alloca i64
  store i64 %r.1787, ptr %typeArgs.52
  %t.1788 = load i64, ptr %typeArgs.52
  %r.1789 = call i64 @kx_list_size(i64 %t.1788)
  %ext.1790 = sext i32 0 to i64
  %t.1791 = icmp sgt i64 %r.1789, %ext.1790
  %t.1792 = load i64, ptr %tokens.addr
  %t.1793 = load i64, ptr %pos.addr
  %r.1794 = call i64 @IsPunct(i64 %t.1792, i64 %t.1793, ptr @.str.99)
  %ext.1796 = icmp ne i64 %r.1794, 0
  %t.1795 = and i1 %t.1791, %ext.1796
  br i1 %t.1795, label %if.then.1797, label %if.merge.1798
if.then.1797:
  %t.1799 = load i64, ptr %tokens.addr
  %t.1800 = load i64, ptr %pos.addr
  %t.1801 = load i64, ptr %arena.addr
  %t.1802 = load i64, ptr %errors.addr
  %t.1803 = load i64, ptr %e.49
  %t.1804 = load i64, ptr %typeArgs.52
  %r.1805 = call i64 @ParseCall(i64 %t.1799, i64 %t.1800, i64 %t.1801, i64 %t.1802, i64 %t.1803, i64 %t.1804)
  store i64 %r.1805, ptr %e.49
  br label %for.inc.1724
dead.1806:
  br label %if.merge.1798
if.merge.1798:
  %t.1807 = load i64, ptr %pos.addr
  %t.1808 = load i64, ptr %savePos.51
  %ext.1809 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.1807, i64 %ext.1809, i64 %t.1808)
  %t.1810 = load i64, ptr %e.49
  ret i64 %t.1810
dead.1811:
  br label %if.merge.1781
if.merge.1781:
  %t.1812 = load i64, ptr %tokens.addr
  %t.1813 = load i64, ptr %pos.addr
  %r.1814 = call i64 @IsPunct(i64 %t.1812, i64 %t.1813, ptr @.str.99)
  %ext.1815 = icmp ne i64 %r.1814, 0
  br i1 %ext.1815, label %if.then.1816, label %if.merge.1817
if.then.1816:
  %t.1818 = load i64, ptr %tokens.addr
  %t.1819 = load i64, ptr %pos.addr
  %t.1820 = load i64, ptr %arena.addr
  %t.1821 = load i64, ptr %errors.addr
  %t.1822 = load i64, ptr %e.49
  %r.1823 = call i64 @kx_list_new(i32 0)
  %r.1824 = call i64 @ParseCall(i64 %t.1818, i64 %t.1819, i64 %t.1820, i64 %t.1821, i64 %t.1822, i64 %r.1823)
  store i64 %r.1824, ptr %e.49
  br label %for.inc.1724
dead.1825:
  br label %if.merge.1817
if.merge.1817:
  %t.1826 = load i64, ptr %tokens.addr
  %t.1827 = load i64, ptr %pos.addr
  %r.1828 = call i64 @IsKw(i64 %t.1826, i64 %t.1827, ptr @.str.52)
  %ext.1829 = icmp ne i64 %r.1828, 0
  br i1 %ext.1829, label %if.then.1830, label %if.merge.1831
if.then.1830:
  %t.1832 = load i64, ptr %tokens.addr
  %t.1833 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1832, i64 %t.1833)
  %t.1835 = load i64, ptr %arena.addr
  %t.1836 = load i64, ptr %tokens.addr
  %t.1837 = load i64, ptr %pos.addr
  %r.1838 = call i64 @CurLine(i64 %t.1836, i64 %t.1837)
  %t.1839 = load i64, ptr %tokens.addr
  %t.1840 = load i64, ptr %pos.addr
  %r.1841 = call i64 @CurCol(i64 %t.1839, i64 %t.1840)
  %r.1842 = call i64 @NewNode(i64 %t.1835, ptr @.str.52, ptr @.str.12, i64 %r.1838, i64 %r.1841)
  %isNode.53 = alloca i64
  store i64 %r.1842, ptr %isNode.53
  %t.1843 = load i64, ptr %arena.addr
  %t.1844 = load i64, ptr %isNode.53
  %t.1845 = load i64, ptr %e.49
  call void @AddChild(i64 %t.1843, i64 %t.1844, i64 %t.1845)
  %t.1847 = load i64, ptr %tokens.addr
  %t.1848 = load i64, ptr %pos.addr
  %r.1849 = call i64 @IsNameTok(i64 %t.1847, i64 %t.1848)
  %ext.1850 = icmp ne i64 %r.1849, 0
  br i1 %ext.1850, label %if.then.1851, label %if.merge.1852
if.then.1851:
  %t.1853 = load i64, ptr %arena.addr
  %t.1854 = load i64, ptr %tokens.addr
  %t.1855 = load i64, ptr %pos.addr
  %r.1856 = call ptr @CurText(i64 %t.1854, i64 %t.1855)
  %t.1857 = load i64, ptr %tokens.addr
  %t.1858 = load i64, ptr %pos.addr
  %r.1859 = call i64 @CurLine(i64 %t.1857, i64 %t.1858)
  %t.1860 = load i64, ptr %tokens.addr
  %t.1861 = load i64, ptr %pos.addr
  %r.1862 = call i64 @CurCol(i64 %t.1860, i64 %t.1861)
  %r.1863 = call i64 @NewNode(i64 %t.1853, ptr @.str.112, ptr %r.1856, i64 %r.1859, i64 %r.1862)
  %typeNode.54 = alloca i64
  store i64 %r.1863, ptr %typeNode.54
  %t.1864 = load i64, ptr %tokens.addr
  %t.1865 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1864, i64 %t.1865)
  %t.1867 = load i64, ptr %arena.addr
  %t.1868 = load i64, ptr %isNode.53
  %t.1869 = load i64, ptr %typeNode.54
  call void @AddChild(i64 %t.1867, i64 %t.1868, i64 %t.1869)
  br label %if.merge.1852
if.merge.1852:
  %t.1871 = load i64, ptr %tokens.addr
  %t.1872 = load i64, ptr %pos.addr
  %r.1873 = call i64 @IsNameTok(i64 %t.1871, i64 %t.1872)
  %ext.1874 = icmp ne i64 %r.1873, 0
  br i1 %ext.1874, label %if.then.1875, label %if.merge.1876
if.then.1875:
  %t.1877 = load i64, ptr %arena.addr
  %t.1878 = load i64, ptr %tokens.addr
  %t.1879 = load i64, ptr %pos.addr
  %r.1880 = call ptr @CurText(i64 %t.1878, i64 %t.1879)
  %t.1881 = load i64, ptr %tokens.addr
  %t.1882 = load i64, ptr %pos.addr
  %r.1883 = call i64 @CurLine(i64 %t.1881, i64 %t.1882)
  %t.1884 = load i64, ptr %tokens.addr
  %t.1885 = load i64, ptr %pos.addr
  %r.1886 = call i64 @CurCol(i64 %t.1884, i64 %t.1885)
  %r.1887 = call i64 @NewNode(i64 %t.1877, ptr @.str.113, ptr %r.1880, i64 %r.1883, i64 %r.1886)
  %varNode.55 = alloca i64
  store i64 %r.1887, ptr %varNode.55
  %t.1888 = load i64, ptr %tokens.addr
  %t.1889 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1888, i64 %t.1889)
  %t.1891 = load i64, ptr %arena.addr
  %t.1892 = load i64, ptr %isNode.53
  %t.1893 = load i64, ptr %varNode.55
  call void @AddChild(i64 %t.1891, i64 %t.1892, i64 %t.1893)
  br label %if.merge.1876
if.merge.1876:
  %t.1895 = load i64, ptr %isNode.53
  store i64 %t.1895, ptr %e.49
  br label %for.inc.1724
dead.1896:
  br label %if.merge.1831
if.merge.1831:
  %t.1897 = load i64, ptr %tokens.addr
  %t.1898 = load i64, ptr %pos.addr
  %r.1899 = call i64 @IsOp(i64 %t.1897, i64 %t.1898, ptr @.str.82)
  %t.1900 = load i64, ptr %tokens.addr
  %t.1901 = load i64, ptr %pos.addr
  %r.1902 = call i64 @IsOp(i64 %t.1900, i64 %t.1901, ptr @.str.83)
  %ext.1904 = icmp ne i64 %r.1899, 0
  %ext.1905 = icmp ne i64 %r.1902, 0
  %t.1903 = or i1 %ext.1904, %ext.1905
  br i1 %t.1903, label %if.then.1906, label %if.merge.1907
if.then.1906:
  %t.1908 = load i64, ptr %tokens.addr
  %t.1909 = load i64, ptr %pos.addr
  %r.1910 = call ptr @CurText(i64 %t.1908, i64 %t.1909)
  %uOp.56 = alloca ptr
  store ptr %r.1910, ptr %uOp.56
  %t.1911 = load i64, ptr %tokens.addr
  %t.1912 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1911, i64 %t.1912)
  %t.1914 = load i64, ptr %arena.addr
  %t.1915 = load ptr, ptr %uOp.56
  %r.1917 = call i1 @kx_str_eq(ptr %t.1915, ptr @.str.82)
  br i1 %r.1917, label %tern.then.1918, label %tern.else.1919
tern.then.1918:
  br label %tern.merge.1920
tern.else.1919:
  br label %tern.merge.1920
tern.merge.1920:
  %phi.1921 = phi ptr [@.str.115, %tern.then.1918], [@.str.116, %tern.else.1919]
  %t.1922 = load i64, ptr %tokens.addr
  %t.1923 = load i64, ptr %pos.addr
  %r.1924 = call i64 @CurLine(i64 %t.1922, i64 %t.1923)
  %t.1925 = load i64, ptr %tokens.addr
  %t.1926 = load i64, ptr %pos.addr
  %r.1927 = call i64 @CurCol(i64 %t.1925, i64 %t.1926)
  %r.1928 = call i64 @NewNode(i64 %t.1914, ptr @.str.114, ptr %phi.1921, i64 %r.1924, i64 %r.1927)
  %u.57 = alloca i64
  store i64 %r.1928, ptr %u.57
  %t.1929 = load i64, ptr %arena.addr
  %t.1930 = load i64, ptr %u.57
  %t.1931 = load i64, ptr %e.49
  call void @AddChild(i64 %t.1929, i64 %t.1930, i64 %t.1931)
  %t.1933 = load i64, ptr %u.57
  store i64 %t.1933, ptr %e.49
  br label %for.inc.1724
dead.1934:
  br label %if.merge.1907
if.merge.1907:
  %t.1935 = load i64, ptr %e.49
  ret i64 %t.1935
dead.1936:
  br label %for.inc.1724
for.inc.1724:
  br label %for.cond.1722
for.end.1725:
  ret i64 0
}

define i64 @ParseBinaryFrom(i64 %e, i64 %tokens, i64 %pos, i64 %arena, i64 %errors, i64 %opText) {
entry:
  %e.addr = alloca i64
  store i64 %e, ptr %e.addr
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %opText.addr = alloca i64
  store i64 %opText, ptr %opText.addr
  %t.1937 = load i64, ptr %tokens.addr
  %t.1938 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1937, i64 %t.1938)
  %t.1940 = load i64, ptr %arena.addr
  %t.1941 = load i64, ptr %opText.addr
  %cast.1942 = inttoptr i64 %t.1941 to ptr
  %t.1943 = load i64, ptr %tokens.addr
  %t.1944 = load i64, ptr %pos.addr
  %r.1945 = call i64 @CurLine(i64 %t.1943, i64 %t.1944)
  %t.1946 = load i64, ptr %tokens.addr
  %t.1947 = load i64, ptr %pos.addr
  %r.1948 = call i64 @CurCol(i64 %t.1946, i64 %t.1947)
  %r.1949 = call i64 @NewNode(i64 %t.1940, ptr @.str.117, ptr %cast.1942, i64 %r.1945, i64 %r.1948)
  %node.58 = alloca i64
  store i64 %r.1949, ptr %node.58
  %t.1950 = load i64, ptr %arena.addr
  %t.1951 = load i64, ptr %node.58
  %t.1952 = load i64, ptr %e.addr
  call void @AddChild(i64 %t.1950, i64 %t.1951, i64 %t.1952)
  %t.1954 = load i64, ptr %arena.addr
  %t.1955 = load i64, ptr %node.58
  %t.1956 = load i64, ptr %tokens.addr
  %t.1957 = load i64, ptr %pos.addr
  %t.1958 = load i64, ptr %arena.addr
  %t.1959 = load i64, ptr %errors.addr
  %r.1960 = call i64 @ParseUnary(i64 %t.1956, i64 %t.1957, i64 %t.1958, i64 %t.1959)
  call void @AddChild(i64 %t.1954, i64 %t.1955, i64 %r.1960)
  %t.1962 = load i64, ptr %node.58
  ret i64 %t.1962
dead.1963:
  ret i64 0
}

define i64 @ParseUnary(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.1964 = load i64, ptr %tokens.addr
  %t.1965 = load i64, ptr %pos.addr
  %r.1966 = call i64 @IsKw(i64 %t.1964, i64 %t.1965, ptr @.str.53)
  %ext.1967 = icmp ne i64 %r.1966, 0
  br i1 %ext.1967, label %if.then.1968, label %if.merge.1969
if.then.1968:
  %t.1970 = load i64, ptr %tokens.addr
  %t.1971 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1970, i64 %t.1971)
  %t.1973 = load i64, ptr %arena.addr
  %t.1974 = load i64, ptr %tokens.addr
  %t.1975 = load i64, ptr %pos.addr
  %r.1976 = call i64 @CurLine(i64 %t.1974, i64 %t.1975)
  %t.1977 = load i64, ptr %tokens.addr
  %t.1978 = load i64, ptr %pos.addr
  %r.1979 = call i64 @CurCol(i64 %t.1977, i64 %t.1978)
  %r.1980 = call i64 @NewNode(i64 %t.1973, ptr @.str.114, ptr @.str.53, i64 %r.1976, i64 %r.1979)
  %u.59 = alloca i64
  store i64 %r.1980, ptr %u.59
  %t.1981 = load i64, ptr %arena.addr
  %t.1982 = load i64, ptr %u.59
  %t.1983 = load i64, ptr %tokens.addr
  %t.1984 = load i64, ptr %pos.addr
  %t.1985 = load i64, ptr %arena.addr
  %t.1986 = load i64, ptr %errors.addr
  %r.1987 = call i64 @ParseUnary(i64 %t.1983, i64 %t.1984, i64 %t.1985, i64 %t.1986)
  call void @AddChild(i64 %t.1981, i64 %t.1982, i64 %r.1987)
  %t.1989 = load i64, ptr %u.59
  ret i64 %t.1989
dead.1990:
  br label %if.merge.1969
if.merge.1969:
  %t.1991 = load i64, ptr %tokens.addr
  %t.1992 = load i64, ptr %pos.addr
  %r.1993 = call i64 @IsPunct(i64 %t.1991, i64 %t.1992, ptr @.str.118)
  %ext.1994 = icmp ne i64 %r.1993, 0
  br i1 %ext.1994, label %if.then.1995, label %if.merge.1996
if.then.1995:
  %t.1997 = load i64, ptr %tokens.addr
  %t.1998 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.1997, i64 %t.1998)
  %t.2000 = load i64, ptr %arena.addr
  %t.2001 = load i64, ptr %tokens.addr
  %t.2002 = load i64, ptr %pos.addr
  %r.2003 = call i64 @CurLine(i64 %t.2001, i64 %t.2002)
  %t.2004 = load i64, ptr %tokens.addr
  %t.2005 = load i64, ptr %pos.addr
  %r.2006 = call i64 @CurCol(i64 %t.2004, i64 %t.2005)
  %r.2007 = call i64 @NewNode(i64 %t.2000, ptr @.str.114, ptr @.str.119, i64 %r.2003, i64 %r.2006)
  %u.60 = alloca i64
  store i64 %r.2007, ptr %u.60
  %t.2008 = load i64, ptr %arena.addr
  %t.2009 = load i64, ptr %u.60
  %t.2010 = load i64, ptr %tokens.addr
  %t.2011 = load i64, ptr %pos.addr
  %t.2012 = load i64, ptr %arena.addr
  %t.2013 = load i64, ptr %errors.addr
  %r.2014 = call i64 @ParseUnary(i64 %t.2010, i64 %t.2011, i64 %t.2012, i64 %t.2013)
  call void @AddChild(i64 %t.2008, i64 %t.2009, i64 %r.2014)
  %t.2016 = load i64, ptr %u.60
  ret i64 %t.2016
dead.2017:
  br label %if.merge.1996
if.merge.1996:
  %t.2018 = load i64, ptr %tokens.addr
  %t.2019 = load i64, ptr %pos.addr
  %r.2020 = call i64 @IsPunct(i64 %t.2018, i64 %t.2019, ptr @.str.87)
  %ext.2021 = icmp ne i64 %r.2020, 0
  br i1 %ext.2021, label %if.then.2022, label %if.merge.2023
if.then.2022:
  %t.2024 = load i64, ptr %tokens.addr
  %t.2025 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2024, i64 %t.2025)
  %t.2027 = load i64, ptr %arena.addr
  %t.2028 = load i64, ptr %tokens.addr
  %t.2029 = load i64, ptr %pos.addr
  %r.2030 = call i64 @CurLine(i64 %t.2028, i64 %t.2029)
  %t.2031 = load i64, ptr %tokens.addr
  %t.2032 = load i64, ptr %pos.addr
  %r.2033 = call i64 @CurCol(i64 %t.2031, i64 %t.2032)
  %r.2034 = call i64 @NewNode(i64 %t.2027, ptr @.str.114, ptr @.str.120, i64 %r.2030, i64 %r.2033)
  %u.61 = alloca i64
  store i64 %r.2034, ptr %u.61
  %t.2035 = load i64, ptr %arena.addr
  %t.2036 = load i64, ptr %u.61
  %t.2037 = load i64, ptr %tokens.addr
  %t.2038 = load i64, ptr %pos.addr
  %t.2039 = load i64, ptr %arena.addr
  %t.2040 = load i64, ptr %errors.addr
  %r.2041 = call i64 @ParseUnary(i64 %t.2037, i64 %t.2038, i64 %t.2039, i64 %t.2040)
  call void @AddChild(i64 %t.2035, i64 %t.2036, i64 %r.2041)
  %t.2043 = load i64, ptr %u.61
  ret i64 %t.2043
dead.2044:
  br label %if.merge.2023
if.merge.2023:
  %t.2045 = load i64, ptr %tokens.addr
  %t.2046 = load i64, ptr %pos.addr
  %t.2047 = load i64, ptr %arena.addr
  %t.2048 = load i64, ptr %errors.addr
  %r.2049 = call i64 @ParsePostfix(i64 %t.2045, i64 %t.2046, i64 %t.2047, i64 %t.2048)
  ret i64 %r.2049
dead.2050:
  ret i64 0
}

define i64 @ParseMultiplicative(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2051 = load i64, ptr %tokens.addr
  %t.2052 = load i64, ptr %pos.addr
  %t.2053 = load i64, ptr %arena.addr
  %t.2054 = load i64, ptr %errors.addr
  %r.2055 = call i64 @ParseUnary(i64 %t.2051, i64 %t.2052, i64 %t.2053, i64 %t.2054)
  %lhs.62 = alloca i64
  store i64 %r.2055, ptr %lhs.62
  br label %for.cond.2056
for.cond.2056:
  br label %for.body.2057
for.body.2057:
  %op.63 = alloca ptr
  store ptr @.str.12, ptr %op.63
  %t.2060 = load i64, ptr %tokens.addr
  %t.2061 = load i64, ptr %pos.addr
  %r.2062 = call i64 @IsPunct(i64 %t.2060, i64 %t.2061, ptr @.str.14)
  %ext.2063 = icmp ne i64 %r.2062, 0
  br i1 %ext.2063, label %if.then.2064, label %if.else.2066
if.then.2064:
  store ptr @.str.121, ptr %op.63
  br label %if.merge.2065
if.else.2066:
  %t.2067 = load i64, ptr %tokens.addr
  %t.2068 = load i64, ptr %pos.addr
  %r.2069 = call i64 @IsPunct(i64 %t.2067, i64 %t.2068, ptr @.str.13)
  %ext.2070 = icmp ne i64 %r.2069, 0
  br i1 %ext.2070, label %if.then.2071, label %if.else.2073
if.then.2071:
  store ptr @.str.122, ptr %op.63
  br label %if.merge.2072
if.else.2073:
  %t.2074 = load i64, ptr %tokens.addr
  %t.2075 = load i64, ptr %pos.addr
  %r.2076 = call i64 @IsPunct(i64 %t.2074, i64 %t.2075, ptr @.str.123)
  %ext.2077 = icmp ne i64 %r.2076, 0
  br i1 %ext.2077, label %if.then.2078, label %if.else.2080
if.then.2078:
  store ptr @.str.124, ptr %op.63
  br label %if.merge.2079
if.else.2080:
  %t.2081 = load i64, ptr %lhs.62
  ret i64 %t.2081
dead.2082:
  br label %if.merge.2079
if.merge.2079:
  br label %if.merge.2072
if.merge.2072:
  br label %if.merge.2065
if.merge.2065:
  %t.2083 = load i64, ptr %tokens.addr
  %t.2084 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2083, i64 %t.2084)
  %t.2086 = load i64, ptr %arena.addr
  %t.2087 = load ptr, ptr %op.63
  %t.2088 = load i64, ptr %tokens.addr
  %t.2089 = load i64, ptr %pos.addr
  %r.2090 = call i64 @CurLine(i64 %t.2088, i64 %t.2089)
  %t.2091 = load i64, ptr %tokens.addr
  %t.2092 = load i64, ptr %pos.addr
  %r.2093 = call i64 @CurCol(i64 %t.2091, i64 %t.2092)
  %r.2094 = call i64 @NewNode(i64 %t.2086, ptr @.str.117, ptr %t.2087, i64 %r.2090, i64 %r.2093)
  %node.64 = alloca i64
  store i64 %r.2094, ptr %node.64
  %t.2095 = load i64, ptr %arena.addr
  %t.2096 = load i64, ptr %node.64
  %t.2097 = load i64, ptr %lhs.62
  call void @AddChild(i64 %t.2095, i64 %t.2096, i64 %t.2097)
  %t.2099 = load i64, ptr %arena.addr
  %t.2100 = load i64, ptr %node.64
  %t.2101 = load i64, ptr %tokens.addr
  %t.2102 = load i64, ptr %pos.addr
  %t.2103 = load i64, ptr %arena.addr
  %t.2104 = load i64, ptr %errors.addr
  %r.2105 = call i64 @ParseUnary(i64 %t.2101, i64 %t.2102, i64 %t.2103, i64 %t.2104)
  call void @AddChild(i64 %t.2099, i64 %t.2100, i64 %r.2105)
  %t.2107 = load i64, ptr %node.64
  store i64 %t.2107, ptr %lhs.62
  br label %for.inc.2058
for.inc.2058:
  br label %for.cond.2056
for.end.2059:
  ret i64 0
}

define i64 @ParseAdditive(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2108 = load i64, ptr %tokens.addr
  %t.2109 = load i64, ptr %pos.addr
  %t.2110 = load i64, ptr %arena.addr
  %t.2111 = load i64, ptr %errors.addr
  %r.2112 = call i64 @ParseMultiplicative(i64 %t.2108, i64 %t.2109, i64 %t.2110, i64 %t.2111)
  %lhs.65 = alloca i64
  store i64 %r.2112, ptr %lhs.65
  br label %for.cond.2113
for.cond.2113:
  br label %for.body.2114
for.body.2114:
  %op.66 = alloca ptr
  store ptr @.str.12, ptr %op.66
  %t.2117 = load i64, ptr %tokens.addr
  %t.2118 = load i64, ptr %pos.addr
  %r.2119 = call i64 @IsPunct(i64 %t.2117, i64 %t.2118, ptr @.str.125)
  %ext.2120 = icmp ne i64 %r.2119, 0
  br i1 %ext.2120, label %if.then.2121, label %if.else.2123
if.then.2121:
  store ptr @.str.126, ptr %op.66
  br label %if.merge.2122
if.else.2123:
  %t.2124 = load i64, ptr %tokens.addr
  %t.2125 = load i64, ptr %pos.addr
  %r.2126 = call i64 @IsPunct(i64 %t.2124, i64 %t.2125, ptr @.str.87)
  %ext.2127 = icmp ne i64 %r.2126, 0
  br i1 %ext.2127, label %if.then.2128, label %if.else.2130
if.then.2128:
  store ptr @.str.127, ptr %op.66
  br label %if.merge.2129
if.else.2130:
  %t.2131 = load i64, ptr %lhs.65
  ret i64 %t.2131
dead.2132:
  br label %if.merge.2129
if.merge.2129:
  br label %if.merge.2122
if.merge.2122:
  %t.2133 = load i64, ptr %tokens.addr
  %t.2134 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2133, i64 %t.2134)
  %t.2136 = load i64, ptr %arena.addr
  %t.2137 = load ptr, ptr %op.66
  %t.2138 = load i64, ptr %tokens.addr
  %t.2139 = load i64, ptr %pos.addr
  %r.2140 = call i64 @CurLine(i64 %t.2138, i64 %t.2139)
  %t.2141 = load i64, ptr %tokens.addr
  %t.2142 = load i64, ptr %pos.addr
  %r.2143 = call i64 @CurCol(i64 %t.2141, i64 %t.2142)
  %r.2144 = call i64 @NewNode(i64 %t.2136, ptr @.str.117, ptr %t.2137, i64 %r.2140, i64 %r.2143)
  %node.67 = alloca i64
  store i64 %r.2144, ptr %node.67
  %t.2145 = load i64, ptr %arena.addr
  %t.2146 = load i64, ptr %node.67
  %t.2147 = load i64, ptr %lhs.65
  call void @AddChild(i64 %t.2145, i64 %t.2146, i64 %t.2147)
  %t.2149 = load i64, ptr %arena.addr
  %t.2150 = load i64, ptr %node.67
  %t.2151 = load i64, ptr %tokens.addr
  %t.2152 = load i64, ptr %pos.addr
  %t.2153 = load i64, ptr %arena.addr
  %t.2154 = load i64, ptr %errors.addr
  %r.2155 = call i64 @ParseMultiplicative(i64 %t.2151, i64 %t.2152, i64 %t.2153, i64 %t.2154)
  call void @AddChild(i64 %t.2149, i64 %t.2150, i64 %r.2155)
  %t.2157 = load i64, ptr %node.67
  store i64 %t.2157, ptr %lhs.65
  br label %for.inc.2115
for.inc.2115:
  br label %for.cond.2113
for.end.2116:
  ret i64 0
}

define i64 @ParseRelational(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2158 = load i64, ptr %tokens.addr
  %t.2159 = load i64, ptr %pos.addr
  %t.2160 = load i64, ptr %arena.addr
  %t.2161 = load i64, ptr %errors.addr
  %r.2162 = call i64 @ParseAdditive(i64 %t.2158, i64 %t.2159, i64 %t.2160, i64 %t.2161)
  %lhs.68 = alloca i64
  store i64 %r.2162, ptr %lhs.68
  br label %for.cond.2163
for.cond.2163:
  br label %for.body.2164
for.body.2164:
  %op.69 = alloca ptr
  store ptr @.str.12, ptr %op.69
  %t.2167 = load i64, ptr %tokens.addr
  %t.2168 = load i64, ptr %pos.addr
  %r.2169 = call i64 @IsPunct(i64 %t.2167, i64 %t.2168, ptr @.str.108)
  %ext.2170 = icmp ne i64 %r.2169, 0
  br i1 %ext.2170, label %if.then.2171, label %if.else.2173
if.then.2171:
  store ptr @.str.128, ptr %op.69
  br label %if.merge.2172
if.else.2173:
  %t.2174 = load i64, ptr %tokens.addr
  %t.2175 = load i64, ptr %pos.addr
  %r.2176 = call i64 @IsPunct(i64 %t.2174, i64 %t.2175, ptr @.str.109)
  %ext.2177 = icmp ne i64 %r.2176, 0
  br i1 %ext.2177, label %if.then.2178, label %if.else.2180
if.then.2178:
  store ptr @.str.129, ptr %op.69
  br label %if.merge.2179
if.else.2180:
  %t.2181 = load i64, ptr %tokens.addr
  %t.2182 = load i64, ptr %pos.addr
  %r.2183 = call i64 @IsOp(i64 %t.2181, i64 %t.2182, ptr @.str.73)
  %ext.2184 = icmp ne i64 %r.2183, 0
  br i1 %ext.2184, label %if.then.2185, label %if.else.2187
if.then.2185:
  store ptr @.str.130, ptr %op.69
  br label %if.merge.2186
if.else.2187:
  %t.2188 = load i64, ptr %tokens.addr
  %t.2189 = load i64, ptr %pos.addr
  %r.2190 = call i64 @IsOp(i64 %t.2188, i64 %t.2189, ptr @.str.74)
  %ext.2191 = icmp ne i64 %r.2190, 0
  br i1 %ext.2191, label %if.then.2192, label %if.else.2194
if.then.2192:
  store ptr @.str.131, ptr %op.69
  br label %if.merge.2193
if.else.2194:
  %t.2195 = load i64, ptr %lhs.68
  ret i64 %t.2195
dead.2196:
  br label %if.merge.2193
if.merge.2193:
  br label %if.merge.2186
if.merge.2186:
  br label %if.merge.2179
if.merge.2179:
  br label %if.merge.2172
if.merge.2172:
  %t.2197 = load i64, ptr %tokens.addr
  %t.2198 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2197, i64 %t.2198)
  %t.2200 = load i64, ptr %arena.addr
  %t.2201 = load ptr, ptr %op.69
  %t.2202 = load i64, ptr %tokens.addr
  %t.2203 = load i64, ptr %pos.addr
  %r.2204 = call i64 @CurLine(i64 %t.2202, i64 %t.2203)
  %t.2205 = load i64, ptr %tokens.addr
  %t.2206 = load i64, ptr %pos.addr
  %r.2207 = call i64 @CurCol(i64 %t.2205, i64 %t.2206)
  %r.2208 = call i64 @NewNode(i64 %t.2200, ptr @.str.117, ptr %t.2201, i64 %r.2204, i64 %r.2207)
  %node.70 = alloca i64
  store i64 %r.2208, ptr %node.70
  %t.2209 = load i64, ptr %arena.addr
  %t.2210 = load i64, ptr %node.70
  %t.2211 = load i64, ptr %lhs.68
  call void @AddChild(i64 %t.2209, i64 %t.2210, i64 %t.2211)
  %t.2213 = load i64, ptr %arena.addr
  %t.2214 = load i64, ptr %node.70
  %t.2215 = load i64, ptr %tokens.addr
  %t.2216 = load i64, ptr %pos.addr
  %t.2217 = load i64, ptr %arena.addr
  %t.2218 = load i64, ptr %errors.addr
  %r.2219 = call i64 @ParseAdditive(i64 %t.2215, i64 %t.2216, i64 %t.2217, i64 %t.2218)
  call void @AddChild(i64 %t.2213, i64 %t.2214, i64 %r.2219)
  %t.2221 = load i64, ptr %node.70
  store i64 %t.2221, ptr %lhs.68
  br label %for.inc.2165
for.inc.2165:
  br label %for.cond.2163
for.end.2166:
  ret i64 0
}

define i64 @ParseEquality(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2222 = load i64, ptr %tokens.addr
  %t.2223 = load i64, ptr %pos.addr
  %t.2224 = load i64, ptr %arena.addr
  %t.2225 = load i64, ptr %errors.addr
  %r.2226 = call i64 @ParseRelational(i64 %t.2222, i64 %t.2223, i64 %t.2224, i64 %t.2225)
  %lhs.71 = alloca i64
  store i64 %r.2226, ptr %lhs.71
  br label %for.cond.2227
for.cond.2227:
  br label %for.body.2228
for.body.2228:
  %op.72 = alloca ptr
  store ptr @.str.12, ptr %op.72
  %t.2231 = load i64, ptr %tokens.addr
  %t.2232 = load i64, ptr %pos.addr
  %r.2233 = call i64 @IsOp(i64 %t.2231, i64 %t.2232, ptr @.str.71)
  %ext.2234 = icmp ne i64 %r.2233, 0
  br i1 %ext.2234, label %if.then.2235, label %if.else.2237
if.then.2235:
  store ptr @.str.132, ptr %op.72
  br label %if.merge.2236
if.else.2237:
  %t.2238 = load i64, ptr %tokens.addr
  %t.2239 = load i64, ptr %pos.addr
  %r.2240 = call i64 @IsOp(i64 %t.2238, i64 %t.2239, ptr @.str.72)
  %ext.2241 = icmp ne i64 %r.2240, 0
  br i1 %ext.2241, label %if.then.2242, label %if.else.2244
if.then.2242:
  store ptr @.str.133, ptr %op.72
  br label %if.merge.2243
if.else.2244:
  %t.2245 = load i64, ptr %lhs.71
  ret i64 %t.2245
dead.2246:
  br label %if.merge.2243
if.merge.2243:
  br label %if.merge.2236
if.merge.2236:
  %t.2247 = load i64, ptr %tokens.addr
  %t.2248 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2247, i64 %t.2248)
  %t.2250 = load i64, ptr %arena.addr
  %t.2251 = load ptr, ptr %op.72
  %t.2252 = load i64, ptr %tokens.addr
  %t.2253 = load i64, ptr %pos.addr
  %r.2254 = call i64 @CurLine(i64 %t.2252, i64 %t.2253)
  %t.2255 = load i64, ptr %tokens.addr
  %t.2256 = load i64, ptr %pos.addr
  %r.2257 = call i64 @CurCol(i64 %t.2255, i64 %t.2256)
  %r.2258 = call i64 @NewNode(i64 %t.2250, ptr @.str.117, ptr %t.2251, i64 %r.2254, i64 %r.2257)
  %node.73 = alloca i64
  store i64 %r.2258, ptr %node.73
  %t.2259 = load i64, ptr %arena.addr
  %t.2260 = load i64, ptr %node.73
  %t.2261 = load i64, ptr %lhs.71
  call void @AddChild(i64 %t.2259, i64 %t.2260, i64 %t.2261)
  %t.2263 = load i64, ptr %arena.addr
  %t.2264 = load i64, ptr %node.73
  %t.2265 = load i64, ptr %tokens.addr
  %t.2266 = load i64, ptr %pos.addr
  %t.2267 = load i64, ptr %arena.addr
  %t.2268 = load i64, ptr %errors.addr
  %r.2269 = call i64 @ParseRelational(i64 %t.2265, i64 %t.2266, i64 %t.2267, i64 %t.2268)
  call void @AddChild(i64 %t.2263, i64 %t.2264, i64 %r.2269)
  %t.2271 = load i64, ptr %node.73
  store i64 %t.2271, ptr %lhs.71
  br label %for.inc.2229
for.inc.2229:
  br label %for.cond.2227
for.end.2230:
  ret i64 0
}

define i64 @ParseLogicalAnd(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2272 = load i64, ptr %tokens.addr
  %t.2273 = load i64, ptr %pos.addr
  %t.2274 = load i64, ptr %arena.addr
  %t.2275 = load i64, ptr %errors.addr
  %r.2276 = call i64 @ParseEquality(i64 %t.2272, i64 %t.2273, i64 %t.2274, i64 %t.2275)
  %lhs.74 = alloca i64
  store i64 %r.2276, ptr %lhs.74
  br label %for.cond.2277
for.cond.2277:
  br label %for.body.2278
for.body.2278:
  %t.2281 = load i64, ptr %tokens.addr
  %t.2282 = load i64, ptr %pos.addr
  %r.2283 = call i64 @IsOp(i64 %t.2281, i64 %t.2282, ptr @.str.75)
  %ext.2285 = icmp ne i64 %r.2283, 0
  %t.2284 = xor i1 %ext.2285, true
  br i1 %t.2284, label %if.then.2286, label %if.merge.2287
if.then.2286:
  %t.2288 = load i64, ptr %lhs.74
  ret i64 %t.2288
dead.2289:
  br label %if.merge.2287
if.merge.2287:
  %t.2290 = load i64, ptr %tokens.addr
  %t.2291 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2290, i64 %t.2291)
  %t.2293 = load i64, ptr %arena.addr
  %t.2294 = load i64, ptr %tokens.addr
  %t.2295 = load i64, ptr %pos.addr
  %r.2296 = call i64 @CurLine(i64 %t.2294, i64 %t.2295)
  %t.2297 = load i64, ptr %tokens.addr
  %t.2298 = load i64, ptr %pos.addr
  %r.2299 = call i64 @CurCol(i64 %t.2297, i64 %t.2298)
  %r.2300 = call i64 @NewNode(i64 %t.2293, ptr @.str.117, ptr @.str.134, i64 %r.2296, i64 %r.2299)
  %node.75 = alloca i64
  store i64 %r.2300, ptr %node.75
  %t.2301 = load i64, ptr %arena.addr
  %t.2302 = load i64, ptr %node.75
  %t.2303 = load i64, ptr %lhs.74
  call void @AddChild(i64 %t.2301, i64 %t.2302, i64 %t.2303)
  %t.2305 = load i64, ptr %arena.addr
  %t.2306 = load i64, ptr %node.75
  %t.2307 = load i64, ptr %tokens.addr
  %t.2308 = load i64, ptr %pos.addr
  %t.2309 = load i64, ptr %arena.addr
  %t.2310 = load i64, ptr %errors.addr
  %r.2311 = call i64 @ParseEquality(i64 %t.2307, i64 %t.2308, i64 %t.2309, i64 %t.2310)
  call void @AddChild(i64 %t.2305, i64 %t.2306, i64 %r.2311)
  %t.2313 = load i64, ptr %node.75
  store i64 %t.2313, ptr %lhs.74
  br label %for.inc.2279
for.inc.2279:
  br label %for.cond.2277
for.end.2280:
  ret i64 0
}

define i64 @ParseLogicalOr(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2314 = load i64, ptr %tokens.addr
  %t.2315 = load i64, ptr %pos.addr
  %t.2316 = load i64, ptr %arena.addr
  %t.2317 = load i64, ptr %errors.addr
  %r.2318 = call i64 @ParseLogicalAnd(i64 %t.2314, i64 %t.2315, i64 %t.2316, i64 %t.2317)
  %lhs.76 = alloca i64
  store i64 %r.2318, ptr %lhs.76
  br label %for.cond.2319
for.cond.2319:
  br label %for.body.2320
for.body.2320:
  %t.2323 = load i64, ptr %tokens.addr
  %t.2324 = load i64, ptr %pos.addr
  %r.2325 = call i64 @IsOp(i64 %t.2323, i64 %t.2324, ptr @.str.76)
  %ext.2327 = icmp ne i64 %r.2325, 0
  %t.2326 = xor i1 %ext.2327, true
  br i1 %t.2326, label %if.then.2328, label %if.merge.2329
if.then.2328:
  %t.2330 = load i64, ptr %lhs.76
  ret i64 %t.2330
dead.2331:
  br label %if.merge.2329
if.merge.2329:
  %t.2332 = load i64, ptr %tokens.addr
  %t.2333 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2332, i64 %t.2333)
  %t.2335 = load i64, ptr %arena.addr
  %t.2336 = load i64, ptr %tokens.addr
  %t.2337 = load i64, ptr %pos.addr
  %r.2338 = call i64 @CurLine(i64 %t.2336, i64 %t.2337)
  %t.2339 = load i64, ptr %tokens.addr
  %t.2340 = load i64, ptr %pos.addr
  %r.2341 = call i64 @CurCol(i64 %t.2339, i64 %t.2340)
  %r.2342 = call i64 @NewNode(i64 %t.2335, ptr @.str.117, ptr @.str.135, i64 %r.2338, i64 %r.2341)
  %node.77 = alloca i64
  store i64 %r.2342, ptr %node.77
  %t.2343 = load i64, ptr %arena.addr
  %t.2344 = load i64, ptr %node.77
  %t.2345 = load i64, ptr %lhs.76
  call void @AddChild(i64 %t.2343, i64 %t.2344, i64 %t.2345)
  %t.2347 = load i64, ptr %arena.addr
  %t.2348 = load i64, ptr %node.77
  %t.2349 = load i64, ptr %tokens.addr
  %t.2350 = load i64, ptr %pos.addr
  %t.2351 = load i64, ptr %arena.addr
  %t.2352 = load i64, ptr %errors.addr
  %r.2353 = call i64 @ParseLogicalAnd(i64 %t.2349, i64 %t.2350, i64 %t.2351, i64 %t.2352)
  call void @AddChild(i64 %t.2347, i64 %t.2348, i64 %r.2353)
  %t.2355 = load i64, ptr %node.77
  store i64 %t.2355, ptr %lhs.76
  br label %for.inc.2321
for.inc.2321:
  br label %for.cond.2319
for.end.2322:
  ret i64 0
}

define i64 @ParseTernary(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2356 = load i64, ptr %tokens.addr
  %t.2357 = load i64, ptr %pos.addr
  %t.2358 = load i64, ptr %arena.addr
  %t.2359 = load i64, ptr %errors.addr
  %r.2360 = call i64 @ParseLogicalOr(i64 %t.2356, i64 %t.2357, i64 %t.2358, i64 %t.2359)
  %cond.78 = alloca i64
  store i64 %r.2360, ptr %cond.78
  %t.2361 = load i64, ptr %tokens.addr
  %t.2362 = load i64, ptr %pos.addr
  %r.2363 = call i64 @IsPunct(i64 %t.2361, i64 %t.2362, ptr @.str.136)
  %ext.2365 = icmp ne i64 %r.2363, 0
  %t.2364 = xor i1 %ext.2365, true
  br i1 %t.2364, label %if.then.2366, label %if.merge.2367
if.then.2366:
  %t.2368 = load i64, ptr %cond.78
  ret i64 %t.2368
dead.2369:
  br label %if.merge.2367
if.merge.2367:
  %t.2370 = load i64, ptr %tokens.addr
  %t.2371 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2370, i64 %t.2371)
  %t.2373 = load i64, ptr %arena.addr
  %t.2374 = load i64, ptr %tokens.addr
  %t.2375 = load i64, ptr %pos.addr
  %r.2376 = call i64 @CurLine(i64 %t.2374, i64 %t.2375)
  %t.2377 = load i64, ptr %tokens.addr
  %t.2378 = load i64, ptr %pos.addr
  %r.2379 = call i64 @CurCol(i64 %t.2377, i64 %t.2378)
  %r.2380 = call i64 @NewNode(i64 %t.2373, ptr @.str.137, ptr @.str.12, i64 %r.2376, i64 %r.2379)
  %node.79 = alloca i64
  store i64 %r.2380, ptr %node.79
  %t.2381 = load i64, ptr %arena.addr
  %t.2382 = load i64, ptr %node.79
  %t.2383 = load i64, ptr %cond.78
  call void @AddChild(i64 %t.2381, i64 %t.2382, i64 %t.2383)
  %t.2385 = load i64, ptr %arena.addr
  %t.2386 = load i64, ptr %node.79
  %t.2387 = load i64, ptr %tokens.addr
  %t.2388 = load i64, ptr %pos.addr
  %t.2389 = load i64, ptr %arena.addr
  %t.2390 = load i64, ptr %errors.addr
  %r.2391 = call i64 @ParseExpression(i64 %t.2387, i64 %t.2388, i64 %t.2389, i64 %t.2390)
  call void @AddChild(i64 %t.2385, i64 %t.2386, i64 %r.2391)
  %t.2393 = load i64, ptr %tokens.addr
  %t.2394 = load i64, ptr %pos.addr
  %t.2395 = load i64, ptr %errors.addr
  %r.2396 = call i64 @ExpectPunct(i64 %t.2393, i64 %t.2394, ptr @.str.89, i64 %t.2395, ptr @.str.138)
  %t.2397 = load i64, ptr %arena.addr
  %t.2398 = load i64, ptr %node.79
  %t.2399 = load i64, ptr %tokens.addr
  %t.2400 = load i64, ptr %pos.addr
  %t.2401 = load i64, ptr %arena.addr
  %t.2402 = load i64, ptr %errors.addr
  %r.2403 = call i64 @ParseTernary(i64 %t.2399, i64 %t.2400, i64 %t.2401, i64 %t.2402)
  call void @AddChild(i64 %t.2397, i64 %t.2398, i64 %r.2403)
  %t.2405 = load i64, ptr %node.79
  ret i64 %t.2405
dead.2406:
  ret i64 0
}

define ptr @ParseAssignOp(i64 %tokens, i64 %pos) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %t.2407 = load i64, ptr %tokens.addr
  %t.2408 = load i64, ptr %pos.addr
  %r.2409 = call i64 @MatchPunct(i64 %t.2407, i64 %t.2408, ptr @.str.94)
  %ext.2410 = icmp ne i64 %r.2409, 0
  br i1 %ext.2410, label %if.then.2411, label %if.merge.2412
if.then.2411:
  ret ptr @.str.139
dead.2413:
  br label %if.merge.2412
if.merge.2412:
  %t.2414 = load i64, ptr %tokens.addr
  %t.2415 = load i64, ptr %pos.addr
  %r.2416 = call i64 @MatchOp(i64 %t.2414, i64 %t.2415, ptr @.str.77)
  %ext.2417 = icmp ne i64 %r.2416, 0
  br i1 %ext.2417, label %if.then.2418, label %if.merge.2419
if.then.2418:
  ret ptr @.str.140
dead.2420:
  br label %if.merge.2419
if.merge.2419:
  %t.2421 = load i64, ptr %tokens.addr
  %t.2422 = load i64, ptr %pos.addr
  %r.2423 = call i64 @MatchOp(i64 %t.2421, i64 %t.2422, ptr @.str.78)
  %ext.2424 = icmp ne i64 %r.2423, 0
  br i1 %ext.2424, label %if.then.2425, label %if.merge.2426
if.then.2425:
  ret ptr @.str.141
dead.2427:
  br label %if.merge.2426
if.merge.2426:
  %t.2428 = load i64, ptr %tokens.addr
  %t.2429 = load i64, ptr %pos.addr
  %r.2430 = call i64 @MatchOp(i64 %t.2428, i64 %t.2429, ptr @.str.79)
  %ext.2431 = icmp ne i64 %r.2430, 0
  br i1 %ext.2431, label %if.then.2432, label %if.merge.2433
if.then.2432:
  ret ptr @.str.142
dead.2434:
  br label %if.merge.2433
if.merge.2433:
  %t.2435 = load i64, ptr %tokens.addr
  %t.2436 = load i64, ptr %pos.addr
  %r.2437 = call i64 @MatchOp(i64 %t.2435, i64 %t.2436, ptr @.str.80)
  %ext.2438 = icmp ne i64 %r.2437, 0
  br i1 %ext.2438, label %if.then.2439, label %if.merge.2440
if.then.2439:
  ret ptr @.str.143
dead.2441:
  br label %if.merge.2440
if.merge.2440:
  %t.2442 = load i64, ptr %tokens.addr
  %t.2443 = load i64, ptr %pos.addr
  %r.2444 = call i64 @MatchOp(i64 %t.2442, i64 %t.2443, ptr @.str.81)
  %ext.2445 = icmp ne i64 %r.2444, 0
  br i1 %ext.2445, label %if.then.2446, label %if.merge.2447
if.then.2446:
  ret ptr @.str.144
dead.2448:
  br label %if.merge.2447
if.merge.2447:
  ret ptr @.str.12
dead.2449:
  ret ptr null
}

define i64 @ParseExpression(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2450 = load i64, ptr %tokens.addr
  %t.2451 = load i64, ptr %pos.addr
  %t.2452 = load i64, ptr %arena.addr
  %t.2453 = load i64, ptr %errors.addr
  %r.2454 = call i64 @ParseTernary(i64 %t.2450, i64 %t.2451, i64 %t.2452, i64 %t.2453)
  %lhs.80 = alloca i64
  store i64 %r.2454, ptr %lhs.80
  %t.2455 = load i64, ptr %tokens.addr
  %t.2456 = load i64, ptr %pos.addr
  %r.2457 = call i64 @CurLine(i64 %t.2455, i64 %t.2456)
  %eqLine.81 = alloca i64
  store i64 %r.2457, ptr %eqLine.81
  %t.2458 = load i64, ptr %tokens.addr
  %t.2459 = load i64, ptr %pos.addr
  %r.2460 = call i64 @CurCol(i64 %t.2458, i64 %t.2459)
  %eqCol.82 = alloca i64
  store i64 %r.2460, ptr %eqCol.82
  %t.2461 = load i64, ptr %tokens.addr
  %t.2462 = load i64, ptr %pos.addr
  %r.2463 = call ptr @ParseAssignOp(i64 %t.2461, i64 %t.2462)
  %op.83 = alloca ptr
  store ptr %r.2463, ptr %op.83
  %t.2464 = load ptr, ptr %op.83
  %r.2466 = call i1 @kx_str_eq(ptr %t.2464, ptr @.str.12)
  br i1 %r.2466, label %if.then.2467, label %if.merge.2468
if.then.2467:
  %t.2469 = load i64, ptr %lhs.80
  ret i64 %t.2469
dead.2470:
  br label %if.merge.2468
if.merge.2468:
  %t.2471 = load i64, ptr %arena.addr
  %t.2472 = load ptr, ptr %op.83
  %t.2473 = load i64, ptr %eqLine.81
  %t.2474 = load i64, ptr %eqCol.82
  %r.2475 = call i64 @NewNode(i64 %t.2471, ptr @.str.139, ptr %t.2472, i64 %t.2473, i64 %t.2474)
  %node.84 = alloca i64
  store i64 %r.2475, ptr %node.84
  %t.2476 = load i64, ptr %arena.addr
  %t.2477 = load i64, ptr %node.84
  %t.2478 = load i64, ptr %lhs.80
  call void @AddChild(i64 %t.2476, i64 %t.2477, i64 %t.2478)
  %t.2480 = load i64, ptr %arena.addr
  %t.2481 = load i64, ptr %node.84
  %t.2482 = load i64, ptr %tokens.addr
  %t.2483 = load i64, ptr %pos.addr
  %t.2484 = load i64, ptr %arena.addr
  %t.2485 = load i64, ptr %errors.addr
  %r.2486 = call i64 @ParseExpression(i64 %t.2482, i64 %t.2483, i64 %t.2484, i64 %t.2485)
  call void @AddChild(i64 %t.2480, i64 %t.2481, i64 %r.2486)
  %t.2488 = load i64, ptr %node.84
  ret i64 %t.2488
dead.2489:
  ret i64 0
}

define i64 @ParseSpawn(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2490 = load i64, ptr %arena.addr
  %t.2491 = load i64, ptr %tokens.addr
  %t.2492 = load i64, ptr %pos.addr
  %r.2493 = call i64 @CurLine(i64 %t.2491, i64 %t.2492)
  %t.2494 = load i64, ptr %tokens.addr
  %t.2495 = load i64, ptr %pos.addr
  %r.2496 = call i64 @CurCol(i64 %t.2494, i64 %t.2495)
  %r.2497 = call i64 @NewNode(i64 %t.2490, ptr @.str.40, ptr @.str.12, i64 %r.2493, i64 %r.2496)
  %node.85 = alloca i64
  store i64 %r.2497, ptr %node.85
  %t.2498 = load i64, ptr %tokens.addr
  %t.2499 = load i64, ptr %pos.addr
  %t.2500 = load i64, ptr %errors.addr
  %r.2501 = call i64 @ExpectPunct(i64 %t.2498, i64 %t.2499, ptr @.str.63, i64 %t.2500, ptr @.str.145)
  %ext.2503 = icmp ne i64 %r.2501, 0
  %t.2502 = xor i1 %ext.2503, true
  br i1 %t.2502, label %if.then.2504, label %if.merge.2505
if.then.2504:
  %t.2506 = load i64, ptr %node.85
  ret i64 %t.2506
dead.2507:
  br label %if.merge.2505
if.merge.2505:
  br label %w.cond.2508
w.cond.2508:
  %t.2511 = load i64, ptr %tokens.addr
  %t.2512 = load i64, ptr %pos.addr
  %r.2513 = call i64 @IsPunct(i64 %t.2511, i64 %t.2512, ptr @.str.64)
  %ext.2515 = icmp ne i64 %r.2513, 0
  %t.2514 = xor i1 %ext.2515, true
  %t.2516 = load i64, ptr %tokens.addr
  %t.2517 = load i64, ptr %pos.addr
  %r.2518 = call i64 @AtEnd(i64 %t.2516, i64 %t.2517)
  %ext.2520 = icmp ne i64 %r.2518, 0
  %t.2519 = xor i1 %ext.2520, true
  %t.2521 = and i1 %t.2514, %t.2519
  br i1 %t.2521, label %w.body.2509, label %w.end.2510
w.body.2509:
  %t.2522 = load i64, ptr %tokens.addr
  %t.2523 = load i64, ptr %pos.addr
  %r.2524 = call i64 @IsKw(i64 %t.2522, i64 %t.2523, ptr @.str.48)
  %ext.2525 = icmp ne i64 %r.2524, 0
  br i1 %ext.2525, label %if.then.2526, label %if.else.2528
if.then.2526:
  %t.2529 = load i64, ptr %tokens.addr
  %t.2530 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2529, i64 %t.2530)
  %t.2532 = load i64, ptr %tokens.addr
  %t.2533 = load i64, ptr %pos.addr
  %t.2534 = load i64, ptr %errors.addr
  %r.2535 = call i64 @ExpectPunct(i64 %t.2532, i64 %t.2533, ptr @.str.146, i64 %t.2534, ptr @.str.147)
  %ext.2536 = icmp ne i64 %r.2535, 0
  br i1 %ext.2536, label %if.then.2537, label %if.merge.2538
if.then.2537:
  br label %w.cond.2539
w.cond.2539:
  %t.2542 = load i64, ptr %tokens.addr
  %t.2543 = load i64, ptr %pos.addr
  %r.2544 = call i64 @IsNameTok(i64 %t.2542, i64 %t.2543)
  %t.2545 = load i64, ptr %tokens.addr
  %t.2546 = load i64, ptr %pos.addr
  %r.2547 = call i64 @IsPunct(i64 %t.2545, i64 %t.2546, ptr @.str.148)
  %ext.2549 = icmp ne i64 %r.2547, 0
  %t.2548 = xor i1 %ext.2549, true
  %ext.2551 = icmp ne i64 %r.2544, 0
  %t.2550 = and i1 %ext.2551, %t.2548
  br i1 %t.2550, label %w.body.2540, label %w.end.2541
w.body.2540:
  %t.2552 = load i64, ptr %arena.addr
  %t.2553 = load i64, ptr %tokens.addr
  %t.2554 = load i64, ptr %pos.addr
  %r.2555 = call ptr @CurText(i64 %t.2553, i64 %t.2554)
  %t.2556 = load i64, ptr %tokens.addr
  %t.2557 = load i64, ptr %pos.addr
  %r.2558 = call i64 @CurLine(i64 %t.2556, i64 %t.2557)
  %t.2559 = load i64, ptr %tokens.addr
  %t.2560 = load i64, ptr %pos.addr
  %r.2561 = call i64 @CurCol(i64 %t.2559, i64 %t.2560)
  %r.2562 = call i64 @NewNode(i64 %t.2552, ptr @.str.149, ptr %r.2555, i64 %r.2558, i64 %r.2561)
  %tn.86 = alloca i64
  store i64 %r.2562, ptr %tn.86
  %t.2563 = load i64, ptr %tokens.addr
  %t.2564 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2563, i64 %t.2564)
  %t.2566 = load i64, ptr %arena.addr
  %t.2567 = load i64, ptr %node.85
  %t.2568 = load i64, ptr %tn.86
  call void @AddChild(i64 %t.2566, i64 %t.2567, i64 %t.2568)
  %t.2570 = load i64, ptr %tokens.addr
  %t.2571 = load i64, ptr %pos.addr
  %r.2572 = call i64 @MatchPunct(i64 %t.2570, i64 %t.2571, ptr @.str.97)
  %ext.2574 = icmp ne i64 %r.2572, 0
  %t.2573 = xor i1 %ext.2574, true
  br i1 %t.2573, label %if.then.2575, label %if.merge.2576
if.then.2575:
  br label %w.end.2541
dead.2577:
  br label %if.merge.2576
if.merge.2576:
  br label %w.cond.2539
w.end.2541:
  %t.2578 = load i64, ptr %tokens.addr
  %t.2579 = load i64, ptr %pos.addr
  %t.2580 = load i64, ptr %errors.addr
  %r.2581 = call i64 @ExpectPunct(i64 %t.2578, i64 %t.2579, ptr @.str.148, i64 %t.2580, ptr @.str.150)
  br label %if.merge.2538
if.merge.2538:
  br label %if.merge.2527
if.else.2528:
  %t.2582 = load i64, ptr %tokens.addr
  %t.2583 = load i64, ptr %pos.addr
  %t.2584 = load i64, ptr %arena.addr
  %t.2585 = load i64, ptr %errors.addr
  %r.2586 = call i64 @ParseComponentInit(i64 %t.2582, i64 %t.2583, i64 %t.2584, i64 %t.2585)
  %ci.87 = alloca i64
  store i64 %r.2586, ptr %ci.87
  %t.2587 = load i64, ptr %arena.addr
  %t.2588 = load i64, ptr %node.85
  %t.2589 = load i64, ptr %ci.87
  call void @AddChild(i64 %t.2587, i64 %t.2588, i64 %t.2589)
  br label %if.merge.2527
if.merge.2527:
  %t.2591 = load i64, ptr %tokens.addr
  %t.2592 = load i64, ptr %pos.addr
  %r.2593 = call i64 @MatchPunct(i64 %t.2591, i64 %t.2592, ptr @.str.97)
  %ext.2595 = icmp ne i64 %r.2593, 0
  %t.2594 = xor i1 %ext.2595, true
  br i1 %t.2594, label %if.then.2596, label %if.merge.2597
if.then.2596:
  br label %w.end.2510
dead.2598:
  br label %if.merge.2597
if.merge.2597:
  br label %w.cond.2508
w.end.2510:
  %t.2599 = load i64, ptr %tokens.addr
  %t.2600 = load i64, ptr %pos.addr
  %t.2601 = load i64, ptr %errors.addr
  %r.2602 = call i64 @ExpectPunct(i64 %t.2599, i64 %t.2600, ptr @.str.64, i64 %t.2601, ptr @.str.151)
  %t.2603 = load i64, ptr %node.85
  ret i64 %t.2603
dead.2604:
  ret i64 0
}

define i64 @ParseComponentInit(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2605 = load i64, ptr %arena.addr
  %t.2606 = load i64, ptr %tokens.addr
  %t.2607 = load i64, ptr %pos.addr
  %r.2608 = call i64 @CurLine(i64 %t.2606, i64 %t.2607)
  %t.2609 = load i64, ptr %tokens.addr
  %t.2610 = load i64, ptr %pos.addr
  %r.2611 = call i64 @CurCol(i64 %t.2609, i64 %t.2610)
  %r.2612 = call i64 @NewNode(i64 %t.2605, ptr @.str.152, ptr @.str.12, i64 %r.2608, i64 %r.2611)
  %node.88 = alloca i64
  store i64 %r.2612, ptr %node.88
  %t.2613 = load i64, ptr %tokens.addr
  %t.2614 = load i64, ptr %pos.addr
  %r.2615 = call i64 @IsNameTok(i64 %t.2613, i64 %t.2614)
  %ext.2616 = icmp ne i64 %r.2615, 0
  br i1 %ext.2616, label %if.then.2617, label %if.merge.2618
if.then.2617:
  %t.2619 = load i64, ptr %arena.addr
  %t.2620 = load i64, ptr %tokens.addr
  %t.2621 = load i64, ptr %pos.addr
  %r.2622 = call ptr @CurText(i64 %t.2620, i64 %t.2621)
  %t.2623 = load i64, ptr %tokens.addr
  %t.2624 = load i64, ptr %pos.addr
  %r.2625 = call i64 @CurLine(i64 %t.2623, i64 %t.2624)
  %t.2626 = load i64, ptr %tokens.addr
  %t.2627 = load i64, ptr %pos.addr
  %r.2628 = call i64 @CurCol(i64 %t.2626, i64 %t.2627)
  %r.2629 = call i64 @NewNode(i64 %t.2619, ptr @.str.153, ptr %r.2622, i64 %r.2625, i64 %r.2628)
  %tn.89 = alloca i64
  store i64 %r.2629, ptr %tn.89
  %t.2630 = load i64, ptr %tokens.addr
  %t.2631 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2630, i64 %t.2631)
  %t.2633 = load i64, ptr %arena.addr
  %t.2634 = load i64, ptr %node.88
  %t.2635 = load i64, ptr %tn.89
  call void @AddChild(i64 %t.2633, i64 %t.2634, i64 %t.2635)
  br label %if.merge.2618
if.merge.2618:
  %t.2637 = load i64, ptr %tokens.addr
  %t.2638 = load i64, ptr %pos.addr
  %t.2639 = load i64, ptr %errors.addr
  %r.2640 = call i64 @ExpectPunct(i64 %t.2637, i64 %t.2638, ptr @.str.63, i64 %t.2639, ptr @.str.154)
  %ext.2641 = icmp ne i64 %r.2640, 0
  br i1 %ext.2641, label %if.then.2642, label %if.merge.2643
if.then.2642:
  br label %w.cond.2644
w.cond.2644:
  %t.2647 = load i64, ptr %tokens.addr
  %t.2648 = load i64, ptr %pos.addr
  %r.2649 = call i64 @IsPunct(i64 %t.2647, i64 %t.2648, ptr @.str.64)
  %ext.2651 = icmp ne i64 %r.2649, 0
  %t.2650 = xor i1 %ext.2651, true
  %t.2652 = load i64, ptr %tokens.addr
  %t.2653 = load i64, ptr %pos.addr
  %r.2654 = call i64 @AtEnd(i64 %t.2652, i64 %t.2653)
  %ext.2656 = icmp ne i64 %r.2654, 0
  %t.2655 = xor i1 %ext.2656, true
  %t.2657 = and i1 %t.2650, %t.2655
  br i1 %t.2657, label %w.body.2645, label %w.end.2646
w.body.2645:
  %t.2658 = load i64, ptr %tokens.addr
  %t.2659 = load i64, ptr %pos.addr
  %r.2660 = call i64 @IsNameTok(i64 %t.2658, i64 %t.2659)
  %ext.2662 = icmp ne i64 %r.2660, 0
  %t.2661 = xor i1 %ext.2662, true
  br i1 %t.2661, label %if.then.2663, label %if.merge.2664
if.then.2663:
  br label %w.end.2646
dead.2665:
  br label %if.merge.2664
if.merge.2664:
  %t.2666 = load i64, ptr %tokens.addr
  %t.2667 = load i64, ptr %pos.addr
  %r.2668 = call ptr @CurText(i64 %t.2666, i64 %t.2667)
  %fname.90 = alloca ptr
  store ptr %r.2668, ptr %fname.90
  %t.2669 = load i64, ptr %tokens.addr
  %t.2670 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2669, i64 %t.2670)
  %t.2672 = load i64, ptr %tokens.addr
  %t.2673 = load i64, ptr %pos.addr
  %t.2674 = load i64, ptr %errors.addr
  %r.2675 = call i64 @ExpectPunct(i64 %t.2672, i64 %t.2673, ptr @.str.94, i64 %t.2674, ptr @.str.95)
  %ext.2677 = icmp ne i64 %r.2675, 0
  %t.2676 = xor i1 %ext.2677, true
  br i1 %t.2676, label %if.then.2678, label %if.merge.2679
if.then.2678:
  br label %w.end.2646
dead.2680:
  br label %if.merge.2679
if.merge.2679:
  %t.2681 = load i64, ptr %arena.addr
  %t.2682 = load ptr, ptr %fname.90
  %t.2683 = load i64, ptr %tokens.addr
  %t.2684 = load i64, ptr %pos.addr
  %r.2685 = call i64 @CurLine(i64 %t.2683, i64 %t.2684)
  %t.2686 = load i64, ptr %tokens.addr
  %t.2687 = load i64, ptr %pos.addr
  %r.2688 = call i64 @CurCol(i64 %t.2686, i64 %t.2687)
  %r.2689 = call i64 @NewNode(i64 %t.2681, ptr @.str.96, ptr %t.2682, i64 %r.2685, i64 %r.2688)
  %initNode.91 = alloca i64
  store i64 %r.2689, ptr %initNode.91
  %t.2690 = load i64, ptr %arena.addr
  %t.2691 = load i64, ptr %initNode.91
  %t.2692 = load i64, ptr %tokens.addr
  %t.2693 = load i64, ptr %pos.addr
  %t.2694 = load i64, ptr %arena.addr
  %t.2695 = load i64, ptr %errors.addr
  %r.2696 = call i64 @ParseExpression(i64 %t.2692, i64 %t.2693, i64 %t.2694, i64 %t.2695)
  call void @AddChild(i64 %t.2690, i64 %t.2691, i64 %r.2696)
  %t.2698 = load i64, ptr %arena.addr
  %t.2699 = load i64, ptr %node.88
  %t.2700 = load i64, ptr %initNode.91
  call void @AddChild(i64 %t.2698, i64 %t.2699, i64 %t.2700)
  %t.2702 = load i64, ptr %tokens.addr
  %t.2703 = load i64, ptr %pos.addr
  %r.2704 = call i64 @MatchPunct(i64 %t.2702, i64 %t.2703, ptr @.str.97)
  %ext.2706 = icmp ne i64 %r.2704, 0
  %t.2705 = xor i1 %ext.2706, true
  br i1 %t.2705, label %if.then.2707, label %if.merge.2708
if.then.2707:
  br label %w.end.2646
dead.2709:
  br label %if.merge.2708
if.merge.2708:
  br label %w.cond.2644
w.end.2646:
  %t.2710 = load i64, ptr %tokens.addr
  %t.2711 = load i64, ptr %pos.addr
  %t.2712 = load i64, ptr %errors.addr
  %r.2713 = call i64 @ExpectPunct(i64 %t.2710, i64 %t.2711, ptr @.str.64, i64 %t.2712, ptr @.str.98)
  br label %if.merge.2643
if.merge.2643:
  %t.2714 = load i64, ptr %node.88
  ret i64 %t.2714
dead.2715:
  ret i64 0
}

define i64 @ParseInterpolated(i64 %arena, ptr %content, i64 %line, i64 %col) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %content.addr = alloca ptr
  store ptr %content, ptr %content.addr
  %line.addr = alloca i64
  store i64 %line, ptr %line.addr
  %col.addr = alloca i64
  store i64 %col, ptr %col.addr
  %t.2716 = load i64, ptr %arena.addr
  %t.2717 = load i64, ptr %line.addr
  %t.2718 = load i64, ptr %col.addr
  %r.2719 = call i64 @NewNode(i64 %t.2716, ptr @.str.155, ptr @.str.12, i64 %t.2717, i64 %t.2718)
  %node.92 = alloca i64
  store i64 %r.2719, ptr %node.92
  %lit.93 = alloca ptr
  store ptr @.str.12, ptr %lit.93
  %i.94 = alloca i32
  store i32 0, ptr %i.94
  %t.2720 = load ptr, ptr %content.addr
  %r.2721 = call i64 @kx_str_len(ptr %t.2720)
  %n.95 = alloca i64
  store i64 %r.2721, ptr %n.95
  br label %w.cond.2722
w.cond.2722:
  %t.2725 = load i32, ptr %i.94
  %t.2726 = load i64, ptr %n.95
  %ext.2727 = sext i32 %t.2725 to i64
  %t.2728 = icmp slt i64 %ext.2727, %t.2726
  br i1 %t.2728, label %w.body.2723, label %w.end.2724
w.body.2723:
  %t.2729 = load ptr, ptr %content.addr
  %t.2730 = load i32, ptr %i.94
  %cast.2731 = sext i32 %t.2730 to i64
  %r.2732 = call ptr @CharAt(ptr %t.2729, i64 %cast.2731)
  %c.96 = alloca ptr
  store ptr %r.2732, ptr %c.96
  %t.2733 = load ptr, ptr %c.96
  %r.2735 = call i1 @kx_str_eq(ptr %t.2733, ptr @.str.63)
  br i1 %r.2735, label %if.then.2736, label %if.else.2738
if.then.2736:
  %t.2739 = load i64, ptr %arena.addr
  %t.2740 = load ptr, ptr %lit.93
  %t.2741 = load i64, ptr %line.addr
  %t.2742 = load i64, ptr %col.addr
  %r.2743 = call i64 @NewNode(i64 %t.2739, ptr @.str.156, ptr %t.2740, i64 %t.2741, i64 %t.2742)
  %ln.97 = alloca i64
  store i64 %r.2743, ptr %ln.97
  %t.2744 = load i64, ptr %arena.addr
  %t.2745 = load i64, ptr %node.92
  %t.2746 = load i64, ptr %ln.97
  call void @AddChild(i64 %t.2744, i64 %t.2745, i64 %t.2746)
  store ptr @.str.12, ptr %lit.93
  %depth.98 = alloca i32
  store i32 1, ptr %depth.98
  %t.2748 = load i32, ptr %i.94
  %t.2749 = add i32 %t.2748, 1
  %j.99 = alloca i32
  store i32 %t.2749, ptr %j.99
  %inner.100 = alloca ptr
  store ptr @.str.12, ptr %inner.100
  br label %w.cond.2750
w.cond.2750:
  %t.2753 = load i32, ptr %j.99
  %t.2754 = load i64, ptr %n.95
  %ext.2755 = sext i32 %t.2753 to i64
  %t.2756 = icmp slt i64 %ext.2755, %t.2754
  %t.2757 = load i32, ptr %depth.98
  %t.2758 = icmp sgt i32 %t.2757, 0
  %t.2759 = and i1 %t.2756, %t.2758
  br i1 %t.2759, label %w.body.2751, label %w.end.2752
w.body.2751:
  %t.2760 = load ptr, ptr %content.addr
  %t.2761 = load i32, ptr %j.99
  %cast.2762 = sext i32 %t.2761 to i64
  %r.2763 = call ptr @CharAt(ptr %t.2760, i64 %cast.2762)
  %d.101 = alloca ptr
  store ptr %r.2763, ptr %d.101
  %t.2764 = load ptr, ptr %d.101
  %r.2766 = call i1 @kx_str_eq(ptr %t.2764, ptr @.str.63)
  br i1 %r.2766, label %if.then.2767, label %if.else.2769
if.then.2767:
  %t.2770 = load i32, ptr %depth.98
  %t.2771 = add i32 %t.2770, 1
  store i32 %t.2771, ptr %depth.98
  br label %if.merge.2768
if.else.2769:
  %t.2772 = load ptr, ptr %d.101
  %r.2774 = call i1 @kx_str_eq(ptr %t.2772, ptr @.str.64)
  br i1 %r.2774, label %if.then.2775, label %if.merge.2776
if.then.2775:
  %t.2777 = load i32, ptr %depth.98
  %t.2778 = sub i32 %t.2777, 1
  store i32 %t.2778, ptr %depth.98
  br label %if.merge.2776
if.merge.2776:
  br label %if.merge.2768
if.merge.2768:
  %t.2779 = load i32, ptr %depth.98
  %t.2780 = icmp sgt i32 %t.2779, 0
  br i1 %t.2780, label %if.then.2781, label %if.merge.2782
if.then.2781:
  %t.2783 = load ptr, ptr %inner.100
  %t.2784 = load ptr, ptr %d.101
  %r.2786 = call ptr @kx_str_cat(ptr %t.2783, ptr %t.2784)
  store ptr %r.2786, ptr %inner.100
  br label %if.merge.2782
if.merge.2782:
  %t.2787 = load i32, ptr %j.99
  %t.2788 = add i32 %t.2787, 1
  store i32 %t.2788, ptr %j.99
  br label %w.cond.2750
w.end.2752:
  %t.2789 = load ptr, ptr %inner.100
  %r.2790 = call i64 @LexAll(ptr %t.2789)
  %sub.102 = alloca i64
  store i64 %r.2790, ptr %sub.102
  %r.2791 = call i64 @kx_list_new(i32 0)
  %sp.103 = alloca i64
  store i64 %r.2791, ptr %sp.103
  %t.2792 = load i64, ptr %sp.103
  %ext.2793 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.2792, i64 %ext.2793)
  %t.2794 = load i64, ptr %sub.102
  %t.2795 = load i64, ptr %sp.103
  %t.2796 = load i64, ptr %arena.addr
  %r.2797 = call i64 @kx_list_new(i32 0)
  %r.2798 = call i64 @ParseExpression(i64 %t.2794, i64 %t.2795, i64 %t.2796, i64 %r.2797)
  %expr.104 = alloca i64
  store i64 %r.2798, ptr %expr.104
  %t.2799 = load i64, ptr %arena.addr
  %t.2800 = load i64, ptr %line.addr
  %t.2801 = load i64, ptr %col.addr
  %r.2802 = call i64 @NewNode(i64 %t.2799, ptr @.str.157, ptr @.str.12, i64 %t.2800, i64 %t.2801)
  %en.105 = alloca i64
  store i64 %r.2802, ptr %en.105
  %t.2803 = load i64, ptr %arena.addr
  %t.2804 = load i64, ptr %en.105
  %t.2805 = load i64, ptr %expr.104
  call void @AddChild(i64 %t.2803, i64 %t.2804, i64 %t.2805)
  %t.2807 = load i64, ptr %arena.addr
  %t.2808 = load i64, ptr %node.92
  %t.2809 = load i64, ptr %en.105
  call void @AddChild(i64 %t.2807, i64 %t.2808, i64 %t.2809)
  %t.2811 = load i32, ptr %j.99
  store i32 %t.2811, ptr %i.94
  br label %if.merge.2737
if.else.2738:
  %t.2812 = load ptr, ptr %lit.93
  %t.2813 = load ptr, ptr %c.96
  %r.2815 = call ptr @kx_str_cat(ptr %t.2812, ptr %t.2813)
  store ptr %r.2815, ptr %lit.93
  %t.2816 = load i32, ptr %i.94
  %t.2817 = add i32 %t.2816, 1
  store i32 %t.2817, ptr %i.94
  br label %if.merge.2737
if.merge.2737:
  br label %w.cond.2722
w.end.2724:
  %t.2818 = load i64, ptr %arena.addr
  %t.2819 = load ptr, ptr %lit.93
  %t.2820 = load i64, ptr %line.addr
  %t.2821 = load i64, ptr %col.addr
  %r.2822 = call i64 @NewNode(i64 %t.2818, ptr @.str.156, ptr %t.2819, i64 %t.2820, i64 %t.2821)
  %ln.106 = alloca i64
  store i64 %r.2822, ptr %ln.106
  %t.2823 = load i64, ptr %arena.addr
  %t.2824 = load i64, ptr %node.92
  %t.2825 = load i64, ptr %ln.106
  call void @AddChild(i64 %t.2823, i64 %t.2824, i64 %t.2825)
  %t.2827 = load i64, ptr %node.92
  ret i64 %t.2827
dead.2828:
  ret i64 0
}

define i64 @ParseBlock(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2829 = load i64, ptr %arena.addr
  %t.2830 = load i64, ptr %tokens.addr
  %t.2831 = load i64, ptr %pos.addr
  %r.2832 = call i64 @CurLine(i64 %t.2830, i64 %t.2831)
  %t.2833 = load i64, ptr %tokens.addr
  %t.2834 = load i64, ptr %pos.addr
  %r.2835 = call i64 @CurCol(i64 %t.2833, i64 %t.2834)
  %r.2836 = call i64 @NewNode(i64 %t.2829, ptr @.str.158, ptr @.str.12, i64 %r.2832, i64 %r.2835)
  %node.107 = alloca i64
  store i64 %r.2836, ptr %node.107
  %t.2837 = load i64, ptr %tokens.addr
  %t.2838 = load i64, ptr %pos.addr
  %t.2839 = load i64, ptr %errors.addr
  %r.2840 = call i64 @ExpectPunct(i64 %t.2837, i64 %t.2838, ptr @.str.63, i64 %t.2839, ptr @.str.159)
  %ext.2842 = icmp ne i64 %r.2840, 0
  %t.2841 = xor i1 %ext.2842, true
  br i1 %t.2841, label %if.then.2843, label %if.merge.2844
if.then.2843:
  %t.2845 = load i64, ptr %node.107
  ret i64 %t.2845
dead.2846:
  br label %if.merge.2844
if.merge.2844:
  br label %w.cond.2847
w.cond.2847:
  %t.2850 = load i64, ptr %tokens.addr
  %t.2851 = load i64, ptr %pos.addr
  %r.2852 = call i64 @IsPunct(i64 %t.2850, i64 %t.2851, ptr @.str.64)
  %ext.2854 = icmp ne i64 %r.2852, 0
  %t.2853 = xor i1 %ext.2854, true
  %t.2855 = load i64, ptr %tokens.addr
  %t.2856 = load i64, ptr %pos.addr
  %r.2857 = call i64 @AtEnd(i64 %t.2855, i64 %t.2856)
  %ext.2859 = icmp ne i64 %r.2857, 0
  %t.2858 = xor i1 %ext.2859, true
  %t.2860 = and i1 %t.2853, %t.2858
  br i1 %t.2860, label %w.body.2848, label %w.end.2849
w.body.2848:
  %t.2861 = load i64, ptr %arena.addr
  %t.2862 = load i64, ptr %node.107
  %t.2863 = load i64, ptr %tokens.addr
  %t.2864 = load i64, ptr %pos.addr
  %t.2865 = load i64, ptr %arena.addr
  %t.2866 = load i64, ptr %errors.addr
  %r.2867 = call i64 @ParseStatement(i64 %t.2863, i64 %t.2864, i64 %t.2865, i64 %t.2866)
  call void @AddChild(i64 %t.2861, i64 %t.2862, i64 %r.2867)
  br label %w.cond.2847
w.end.2849:
  %t.2869 = load i64, ptr %tokens.addr
  %t.2870 = load i64, ptr %pos.addr
  %t.2871 = load i64, ptr %errors.addr
  %r.2872 = call i64 @ExpectPunct(i64 %t.2869, i64 %t.2870, ptr @.str.64, i64 %t.2871, ptr @.str.160)
  %t.2873 = load i64, ptr %node.107
  ret i64 %t.2873
dead.2874:
  ret i64 0
}

define i64 @ParseStatement(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.2875 = load i64, ptr %tokens.addr
  %t.2876 = load i64, ptr %pos.addr
  %r.2877 = call i64 @IsPunct(i64 %t.2875, i64 %t.2876, ptr @.str.63)
  %ext.2878 = icmp ne i64 %r.2877, 0
  br i1 %ext.2878, label %if.then.2879, label %if.merge.2880
if.then.2879:
  %t.2881 = load i64, ptr %tokens.addr
  %t.2882 = load i64, ptr %pos.addr
  %t.2883 = load i64, ptr %arena.addr
  %t.2884 = load i64, ptr %errors.addr
  %r.2885 = call i64 @ParseBlock(i64 %t.2881, i64 %t.2882, i64 %t.2883, i64 %t.2884)
  ret i64 %r.2885
dead.2886:
  br label %if.merge.2880
if.merge.2880:
  %t.2887 = load i64, ptr %tokens.addr
  %t.2888 = load i64, ptr %pos.addr
  %r.2889 = call i64 @IsKw(i64 %t.2887, i64 %t.2888, ptr @.str.22)
  %ext.2890 = icmp ne i64 %r.2889, 0
  br i1 %ext.2890, label %if.then.2891, label %if.merge.2892
if.then.2891:
  %t.2893 = load i64, ptr %arena.addr
  %t.2894 = load i64, ptr %tokens.addr
  %t.2895 = load i64, ptr %pos.addr
  %r.2896 = call i64 @CurLine(i64 %t.2894, i64 %t.2895)
  %t.2897 = load i64, ptr %tokens.addr
  %t.2898 = load i64, ptr %pos.addr
  %r.2899 = call i64 @CurCol(i64 %t.2897, i64 %t.2898)
  %r.2900 = call i64 @NewNode(i64 %t.2893, ptr @.str.161, ptr @.str.12, i64 %r.2896, i64 %r.2899)
  %node.108 = alloca i64
  store i64 %r.2900, ptr %node.108
  %t.2901 = load i64, ptr %tokens.addr
  %t.2902 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2901, i64 %t.2902)
  %t.2904 = load i64, ptr %tokens.addr
  %t.2905 = load i64, ptr %pos.addr
  %r.2906 = call i64 @IsNameTok(i64 %t.2904, i64 %t.2905)
  %ext.2907 = icmp ne i64 %r.2906, 0
  br i1 %ext.2907, label %if.then.2908, label %if.merge.2909
if.then.2908:
  %t.2910 = load i64, ptr %arena.addr
  %t.2911 = load i64, ptr %tokens.addr
  %t.2912 = load i64, ptr %pos.addr
  %r.2913 = call ptr @CurText(i64 %t.2911, i64 %t.2912)
  %t.2914 = load i64, ptr %tokens.addr
  %t.2915 = load i64, ptr %pos.addr
  %r.2916 = call i64 @CurLine(i64 %t.2914, i64 %t.2915)
  %t.2917 = load i64, ptr %tokens.addr
  %t.2918 = load i64, ptr %pos.addr
  %r.2919 = call i64 @CurCol(i64 %t.2917, i64 %t.2918)
  %r.2920 = call i64 @NewNode(i64 %t.2910, ptr @.str.162, ptr %r.2913, i64 %r.2916, i64 %r.2919)
  %vn.109 = alloca i64
  store i64 %r.2920, ptr %vn.109
  %t.2921 = load i64, ptr %tokens.addr
  %t.2922 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2921, i64 %t.2922)
  %t.2924 = load i64, ptr %arena.addr
  %t.2925 = load i64, ptr %node.108
  %t.2926 = load i64, ptr %vn.109
  call void @AddChild(i64 %t.2924, i64 %t.2925, i64 %t.2926)
  br label %if.merge.2909
if.merge.2909:
  %t.2928 = load i64, ptr %tokens.addr
  %t.2929 = load i64, ptr %pos.addr
  %t.2930 = load i64, ptr %errors.addr
  %r.2931 = call i64 @ExpectPunct(i64 %t.2928, i64 %t.2929, ptr @.str.94, i64 %t.2930, ptr @.str.163)
  %ext.2932 = icmp ne i64 %r.2931, 0
  br i1 %ext.2932, label %if.then.2933, label %if.merge.2934
if.then.2933:
  %t.2935 = load i64, ptr %arena.addr
  %t.2936 = load i64, ptr %node.108
  %t.2937 = load i64, ptr %tokens.addr
  %t.2938 = load i64, ptr %pos.addr
  %t.2939 = load i64, ptr %arena.addr
  %t.2940 = load i64, ptr %errors.addr
  %r.2941 = call i64 @ParseExpression(i64 %t.2937, i64 %t.2938, i64 %t.2939, i64 %t.2940)
  call void @AddChild(i64 %t.2935, i64 %t.2936, i64 %r.2941)
  br label %if.merge.2934
if.merge.2934:
  %t.2943 = load i64, ptr %tokens.addr
  %t.2944 = load i64, ptr %pos.addr
  %t.2945 = load i64, ptr %errors.addr
  %r.2946 = call i64 @ExpectPunct(i64 %t.2943, i64 %t.2944, ptr @.str.164, i64 %t.2945, ptr @.str.165)
  %t.2947 = load i64, ptr %node.108
  ret i64 %t.2947
dead.2948:
  br label %if.merge.2892
if.merge.2892:
  %t.2949 = load i64, ptr %tokens.addr
  %t.2950 = load i64, ptr %pos.addr
  %r.2951 = call i64 @IsKw(i64 %t.2949, i64 %t.2950, ptr @.str.31)
  %ext.2952 = icmp ne i64 %r.2951, 0
  br i1 %ext.2952, label %if.then.2953, label %if.merge.2954
if.then.2953:
  %t.2955 = load i64, ptr %arena.addr
  %t.2956 = load i64, ptr %tokens.addr
  %t.2957 = load i64, ptr %pos.addr
  %r.2958 = call i64 @CurLine(i64 %t.2956, i64 %t.2957)
  %t.2959 = load i64, ptr %tokens.addr
  %t.2960 = load i64, ptr %pos.addr
  %r.2961 = call i64 @CurCol(i64 %t.2959, i64 %t.2960)
  %r.2962 = call i64 @NewNode(i64 %t.2955, ptr @.str.31, ptr @.str.12, i64 %r.2958, i64 %r.2961)
  %node.110 = alloca i64
  store i64 %r.2962, ptr %node.110
  %t.2963 = load i64, ptr %tokens.addr
  %t.2964 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.2963, i64 %t.2964)
  %t.2966 = load i64, ptr %tokens.addr
  %t.2967 = load i64, ptr %pos.addr
  %t.2968 = load i64, ptr %errors.addr
  %r.2969 = call i64 @ExpectPunct(i64 %t.2966, i64 %t.2967, ptr @.str.99, i64 %t.2968, ptr @.str.166)
  %ext.2970 = icmp ne i64 %r.2969, 0
  br i1 %ext.2970, label %if.then.2971, label %if.merge.2972
if.then.2971:
  %t.2973 = load i64, ptr %arena.addr
  %t.2974 = load i64, ptr %node.110
  %t.2975 = load i64, ptr %tokens.addr
  %t.2976 = load i64, ptr %pos.addr
  %t.2977 = load i64, ptr %arena.addr
  %t.2978 = load i64, ptr %errors.addr
  %r.2979 = call i64 @ParseExpression(i64 %t.2975, i64 %t.2976, i64 %t.2977, i64 %t.2978)
  call void @AddChild(i64 %t.2973, i64 %t.2974, i64 %r.2979)
  %t.2981 = load i64, ptr %tokens.addr
  %t.2982 = load i64, ptr %pos.addr
  %t.2983 = load i64, ptr %errors.addr
  %r.2984 = call i64 @ExpectPunct(i64 %t.2981, i64 %t.2982, ptr @.str.100, i64 %t.2983, ptr @.str.167)
  br label %if.merge.2972
if.merge.2972:
  %t.2985 = load i64, ptr %arena.addr
  %t.2986 = load i64, ptr %node.110
  %t.2987 = load i64, ptr %tokens.addr
  %t.2988 = load i64, ptr %pos.addr
  %t.2989 = load i64, ptr %arena.addr
  %t.2990 = load i64, ptr %errors.addr
  %r.2991 = call i64 @ParseStatement(i64 %t.2987, i64 %t.2988, i64 %t.2989, i64 %t.2990)
  call void @AddChild(i64 %t.2985, i64 %t.2986, i64 %r.2991)
  %t.2993 = load i64, ptr %tokens.addr
  %t.2994 = load i64, ptr %pos.addr
  %r.2995 = call i64 @MatchKw(i64 %t.2993, i64 %t.2994, ptr @.str.32)
  %ext.2996 = icmp ne i64 %r.2995, 0
  br i1 %ext.2996, label %if.then.2997, label %if.merge.2998
if.then.2997:
  %t.2999 = load i64, ptr %arena.addr
  %t.3000 = load i64, ptr %node.110
  %t.3001 = load i64, ptr %tokens.addr
  %t.3002 = load i64, ptr %pos.addr
  %t.3003 = load i64, ptr %arena.addr
  %t.3004 = load i64, ptr %errors.addr
  %r.3005 = call i64 @ParseStatement(i64 %t.3001, i64 %t.3002, i64 %t.3003, i64 %t.3004)
  call void @AddChild(i64 %t.2999, i64 %t.3000, i64 %r.3005)
  br label %if.merge.2998
if.merge.2998:
  %t.3007 = load i64, ptr %node.110
  ret i64 %t.3007
dead.3008:
  br label %if.merge.2954
if.merge.2954:
  %t.3009 = load i64, ptr %tokens.addr
  %t.3010 = load i64, ptr %pos.addr
  %r.3011 = call i64 @IsKw(i64 %t.3009, i64 %t.3010, ptr @.str.33)
  %ext.3012 = icmp ne i64 %r.3011, 0
  br i1 %ext.3012, label %if.then.3013, label %if.merge.3014
if.then.3013:
  %t.3015 = load i64, ptr %arena.addr
  %t.3016 = load i64, ptr %tokens.addr
  %t.3017 = load i64, ptr %pos.addr
  %r.3018 = call i64 @CurLine(i64 %t.3016, i64 %t.3017)
  %t.3019 = load i64, ptr %tokens.addr
  %t.3020 = load i64, ptr %pos.addr
  %r.3021 = call i64 @CurCol(i64 %t.3019, i64 %t.3020)
  %r.3022 = call i64 @NewNode(i64 %t.3015, ptr @.str.33, ptr @.str.12, i64 %r.3018, i64 %r.3021)
  %node.111 = alloca i64
  store i64 %r.3022, ptr %node.111
  %t.3023 = load i64, ptr %tokens.addr
  %t.3024 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3023, i64 %t.3024)
  %t.3026 = load i64, ptr %tokens.addr
  %t.3027 = load i64, ptr %pos.addr
  %t.3028 = load i64, ptr %errors.addr
  %r.3029 = call i64 @ExpectPunct(i64 %t.3026, i64 %t.3027, ptr @.str.99, i64 %t.3028, ptr @.str.168)
  %ext.3030 = icmp ne i64 %r.3029, 0
  br i1 %ext.3030, label %if.then.3031, label %if.merge.3032
if.then.3031:
  %t.3033 = load i64, ptr %arena.addr
  %t.3034 = load i64, ptr %node.111
  %t.3035 = load i64, ptr %tokens.addr
  %t.3036 = load i64, ptr %pos.addr
  %t.3037 = load i64, ptr %arena.addr
  %t.3038 = load i64, ptr %errors.addr
  %r.3039 = call i64 @ParseExpression(i64 %t.3035, i64 %t.3036, i64 %t.3037, i64 %t.3038)
  call void @AddChild(i64 %t.3033, i64 %t.3034, i64 %r.3039)
  %t.3041 = load i64, ptr %tokens.addr
  %t.3042 = load i64, ptr %pos.addr
  %t.3043 = load i64, ptr %errors.addr
  %r.3044 = call i64 @ExpectPunct(i64 %t.3041, i64 %t.3042, ptr @.str.100, i64 %t.3043, ptr @.str.169)
  br label %if.merge.3032
if.merge.3032:
  %t.3045 = load i64, ptr %arena.addr
  %t.3046 = load i64, ptr %node.111
  %t.3047 = load i64, ptr %tokens.addr
  %t.3048 = load i64, ptr %pos.addr
  %t.3049 = load i64, ptr %arena.addr
  %t.3050 = load i64, ptr %errors.addr
  %r.3051 = call i64 @ParseStatement(i64 %t.3047, i64 %t.3048, i64 %t.3049, i64 %t.3050)
  call void @AddChild(i64 %t.3045, i64 %t.3046, i64 %r.3051)
  %t.3053 = load i64, ptr %node.111
  ret i64 %t.3053
dead.3054:
  br label %if.merge.3014
if.merge.3014:
  %t.3055 = load i64, ptr %tokens.addr
  %t.3056 = load i64, ptr %pos.addr
  %r.3057 = call i64 @IsKw(i64 %t.3055, i64 %t.3056, ptr @.str.34)
  %ext.3058 = icmp ne i64 %r.3057, 0
  br i1 %ext.3058, label %if.then.3059, label %if.merge.3060
if.then.3059:
  %t.3061 = load i64, ptr %arena.addr
  %t.3062 = load i64, ptr %tokens.addr
  %t.3063 = load i64, ptr %pos.addr
  %r.3064 = call i64 @CurLine(i64 %t.3062, i64 %t.3063)
  %t.3065 = load i64, ptr %tokens.addr
  %t.3066 = load i64, ptr %pos.addr
  %r.3067 = call i64 @CurCol(i64 %t.3065, i64 %t.3066)
  %r.3068 = call i64 @NewNode(i64 %t.3061, ptr @.str.34, ptr @.str.12, i64 %r.3064, i64 %r.3067)
  %node.112 = alloca i64
  store i64 %r.3068, ptr %node.112
  %t.3069 = load i64, ptr %tokens.addr
  %t.3070 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3069, i64 %t.3070)
  %t.3072 = load i64, ptr %tokens.addr
  %t.3073 = load i64, ptr %pos.addr
  %t.3074 = load i64, ptr %errors.addr
  %r.3075 = call i64 @ExpectPunct(i64 %t.3072, i64 %t.3073, ptr @.str.99, i64 %t.3074, ptr @.str.170)
  %ext.3077 = icmp ne i64 %r.3075, 0
  %t.3076 = xor i1 %ext.3077, true
  br i1 %t.3076, label %if.then.3078, label %if.merge.3079
if.then.3078:
  %t.3080 = load i64, ptr %node.112
  ret i64 %t.3080
dead.3081:
  br label %if.merge.3079
if.merge.3079:
  %t.3082 = load i64, ptr %tokens.addr
  %t.3083 = load i64, ptr %pos.addr
  %r.3084 = call i64 @IsPunct(i64 %t.3082, i64 %t.3083, ptr @.str.164)
  %ext.3086 = icmp ne i64 %r.3084, 0
  %t.3085 = xor i1 %ext.3086, true
  br i1 %t.3085, label %if.then.3087, label %if.merge.3088
if.then.3087:
  %t.3089 = load i64, ptr %tokens.addr
  %t.3090 = load i64, ptr %pos.addr
  %r.3091 = call i64 @IsKw(i64 %t.3089, i64 %t.3090, ptr @.str.22)
  %ext.3092 = icmp ne i64 %r.3091, 0
  br i1 %ext.3092, label %if.then.3093, label %if.else.3095
if.then.3093:
  %t.3096 = load i64, ptr %arena.addr
  %t.3097 = load i64, ptr %tokens.addr
  %t.3098 = load i64, ptr %pos.addr
  %r.3099 = call i64 @CurLine(i64 %t.3097, i64 %t.3098)
  %t.3100 = load i64, ptr %tokens.addr
  %t.3101 = load i64, ptr %pos.addr
  %r.3102 = call i64 @CurCol(i64 %t.3100, i64 %t.3101)
  %r.3103 = call i64 @NewNode(i64 %t.3096, ptr @.str.161, ptr @.str.12, i64 %r.3099, i64 %r.3102)
  %init.113 = alloca i64
  store i64 %r.3103, ptr %init.113
  %t.3104 = load i64, ptr %tokens.addr
  %t.3105 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3104, i64 %t.3105)
  %t.3107 = load i64, ptr %tokens.addr
  %t.3108 = load i64, ptr %pos.addr
  %r.3109 = call i64 @IsNameTok(i64 %t.3107, i64 %t.3108)
  %ext.3110 = icmp ne i64 %r.3109, 0
  br i1 %ext.3110, label %if.then.3111, label %if.merge.3112
if.then.3111:
  %t.3113 = load i64, ptr %arena.addr
  %t.3114 = load i64, ptr %tokens.addr
  %t.3115 = load i64, ptr %pos.addr
  %r.3116 = call ptr @CurText(i64 %t.3114, i64 %t.3115)
  %t.3117 = load i64, ptr %tokens.addr
  %t.3118 = load i64, ptr %pos.addr
  %r.3119 = call i64 @CurLine(i64 %t.3117, i64 %t.3118)
  %t.3120 = load i64, ptr %tokens.addr
  %t.3121 = load i64, ptr %pos.addr
  %r.3122 = call i64 @CurCol(i64 %t.3120, i64 %t.3121)
  %r.3123 = call i64 @NewNode(i64 %t.3113, ptr @.str.162, ptr %r.3116, i64 %r.3119, i64 %r.3122)
  %vn.114 = alloca i64
  store i64 %r.3123, ptr %vn.114
  %t.3124 = load i64, ptr %tokens.addr
  %t.3125 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3124, i64 %t.3125)
  %t.3127 = load i64, ptr %arena.addr
  %t.3128 = load i64, ptr %init.113
  %t.3129 = load i64, ptr %vn.114
  call void @AddChild(i64 %t.3127, i64 %t.3128, i64 %t.3129)
  br label %if.merge.3112
if.merge.3112:
  %t.3131 = load i64, ptr %tokens.addr
  %t.3132 = load i64, ptr %pos.addr
  %t.3133 = load i64, ptr %errors.addr
  %r.3134 = call i64 @ExpectPunct(i64 %t.3131, i64 %t.3132, ptr @.str.94, i64 %t.3133, ptr @.str.163)
  %ext.3135 = icmp ne i64 %r.3134, 0
  br i1 %ext.3135, label %if.then.3136, label %if.merge.3137
if.then.3136:
  %t.3138 = load i64, ptr %arena.addr
  %t.3139 = load i64, ptr %init.113
  %t.3140 = load i64, ptr %tokens.addr
  %t.3141 = load i64, ptr %pos.addr
  %t.3142 = load i64, ptr %arena.addr
  %t.3143 = load i64, ptr %errors.addr
  %r.3144 = call i64 @ParseExpression(i64 %t.3140, i64 %t.3141, i64 %t.3142, i64 %t.3143)
  call void @AddChild(i64 %t.3138, i64 %t.3139, i64 %r.3144)
  br label %if.merge.3137
if.merge.3137:
  %t.3146 = load i64, ptr %arena.addr
  %t.3147 = load i64, ptr %node.112
  %t.3148 = load i64, ptr %init.113
  call void @AddChild(i64 %t.3146, i64 %t.3147, i64 %t.3148)
  br label %if.merge.3094
if.else.3095:
  %t.3150 = load i64, ptr %arena.addr
  %t.3151 = load i64, ptr %node.112
  %t.3152 = load i64, ptr %tokens.addr
  %t.3153 = load i64, ptr %pos.addr
  %t.3154 = load i64, ptr %arena.addr
  %t.3155 = load i64, ptr %errors.addr
  %r.3156 = call i64 @ParseExpression(i64 %t.3152, i64 %t.3153, i64 %t.3154, i64 %t.3155)
  call void @AddChild(i64 %t.3150, i64 %t.3151, i64 %r.3156)
  br label %if.merge.3094
if.merge.3094:
  br label %if.merge.3088
if.merge.3088:
  %t.3158 = load i64, ptr %tokens.addr
  %t.3159 = load i64, ptr %pos.addr
  %t.3160 = load i64, ptr %errors.addr
  %r.3161 = call i64 @ExpectPunct(i64 %t.3158, i64 %t.3159, ptr @.str.164, i64 %t.3160, ptr @.str.171)
  %t.3162 = load i64, ptr %tokens.addr
  %t.3163 = load i64, ptr %pos.addr
  %r.3164 = call i64 @IsPunct(i64 %t.3162, i64 %t.3163, ptr @.str.164)
  %ext.3166 = icmp ne i64 %r.3164, 0
  %t.3165 = xor i1 %ext.3166, true
  br i1 %t.3165, label %if.then.3167, label %if.merge.3168
if.then.3167:
  %t.3169 = load i64, ptr %arena.addr
  %t.3170 = load i64, ptr %node.112
  %t.3171 = load i64, ptr %tokens.addr
  %t.3172 = load i64, ptr %pos.addr
  %t.3173 = load i64, ptr %arena.addr
  %t.3174 = load i64, ptr %errors.addr
  %r.3175 = call i64 @ParseExpression(i64 %t.3171, i64 %t.3172, i64 %t.3173, i64 %t.3174)
  call void @AddChild(i64 %t.3169, i64 %t.3170, i64 %r.3175)
  br label %if.merge.3168
if.merge.3168:
  %t.3177 = load i64, ptr %tokens.addr
  %t.3178 = load i64, ptr %pos.addr
  %t.3179 = load i64, ptr %errors.addr
  %r.3180 = call i64 @ExpectPunct(i64 %t.3177, i64 %t.3178, ptr @.str.164, i64 %t.3179, ptr @.str.172)
  %t.3181 = load i64, ptr %tokens.addr
  %t.3182 = load i64, ptr %pos.addr
  %r.3183 = call i64 @IsPunct(i64 %t.3181, i64 %t.3182, ptr @.str.100)
  %ext.3185 = icmp ne i64 %r.3183, 0
  %t.3184 = xor i1 %ext.3185, true
  br i1 %t.3184, label %if.then.3186, label %if.merge.3187
if.then.3186:
  %t.3188 = load i64, ptr %arena.addr
  %t.3189 = load i64, ptr %node.112
  %t.3190 = load i64, ptr %tokens.addr
  %t.3191 = load i64, ptr %pos.addr
  %t.3192 = load i64, ptr %arena.addr
  %t.3193 = load i64, ptr %errors.addr
  %r.3194 = call i64 @ParseExpression(i64 %t.3190, i64 %t.3191, i64 %t.3192, i64 %t.3193)
  call void @AddChild(i64 %t.3188, i64 %t.3189, i64 %r.3194)
  br label %if.merge.3187
if.merge.3187:
  %t.3196 = load i64, ptr %tokens.addr
  %t.3197 = load i64, ptr %pos.addr
  %t.3198 = load i64, ptr %errors.addr
  %r.3199 = call i64 @ExpectPunct(i64 %t.3196, i64 %t.3197, ptr @.str.100, i64 %t.3198, ptr @.str.173)
  %t.3200 = load i64, ptr %arena.addr
  %t.3201 = load i64, ptr %node.112
  %t.3202 = load i64, ptr %tokens.addr
  %t.3203 = load i64, ptr %pos.addr
  %t.3204 = load i64, ptr %arena.addr
  %t.3205 = load i64, ptr %errors.addr
  %r.3206 = call i64 @ParseStatement(i64 %t.3202, i64 %t.3203, i64 %t.3204, i64 %t.3205)
  call void @AddChild(i64 %t.3200, i64 %t.3201, i64 %r.3206)
  %t.3208 = load i64, ptr %node.112
  ret i64 %t.3208
dead.3209:
  br label %if.merge.3060
if.merge.3060:
  %t.3210 = load i64, ptr %tokens.addr
  %t.3211 = load i64, ptr %pos.addr
  %r.3212 = call i64 @IsKw(i64 %t.3210, i64 %t.3211, ptr @.str.35)
  %ext.3213 = icmp ne i64 %r.3212, 0
  br i1 %ext.3213, label %if.then.3214, label %if.merge.3215
if.then.3214:
  %t.3216 = load i64, ptr %arena.addr
  %t.3217 = load i64, ptr %tokens.addr
  %t.3218 = load i64, ptr %pos.addr
  %r.3219 = call i64 @CurLine(i64 %t.3217, i64 %t.3218)
  %t.3220 = load i64, ptr %tokens.addr
  %t.3221 = load i64, ptr %pos.addr
  %r.3222 = call i64 @CurCol(i64 %t.3220, i64 %t.3221)
  %r.3223 = call i64 @NewNode(i64 %t.3216, ptr @.str.35, ptr @.str.12, i64 %r.3219, i64 %r.3222)
  %node.115 = alloca i64
  store i64 %r.3223, ptr %node.115
  %t.3224 = load i64, ptr %tokens.addr
  %t.3225 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3224, i64 %t.3225)
  %t.3227 = load i64, ptr %tokens.addr
  %t.3228 = load i64, ptr %pos.addr
  %t.3229 = load i64, ptr %errors.addr
  %r.3230 = call i64 @ExpectPunct(i64 %t.3227, i64 %t.3228, ptr @.str.99, i64 %t.3229, ptr @.str.174)
  %ext.3231 = icmp ne i64 %r.3230, 0
  br i1 %ext.3231, label %if.then.3232, label %if.merge.3233
if.then.3232:
  %t.3234 = load i64, ptr %tokens.addr
  %t.3235 = load i64, ptr %pos.addr
  %r.3236 = call i64 @MatchKw(i64 %t.3234, i64 %t.3235, ptr @.str.22)
  %t.3237 = load i64, ptr %tokens.addr
  %t.3238 = load i64, ptr %pos.addr
  %r.3239 = call i64 @IsNameTok(i64 %t.3237, i64 %t.3238)
  %ext.3240 = icmp ne i64 %r.3239, 0
  br i1 %ext.3240, label %if.then.3241, label %if.merge.3242
if.then.3241:
  %t.3243 = load i64, ptr %arena.addr
  %t.3244 = load i64, ptr %tokens.addr
  %t.3245 = load i64, ptr %pos.addr
  %r.3246 = call ptr @CurText(i64 %t.3244, i64 %t.3245)
  %t.3247 = load i64, ptr %tokens.addr
  %t.3248 = load i64, ptr %pos.addr
  %r.3249 = call i64 @CurLine(i64 %t.3247, i64 %t.3248)
  %t.3250 = load i64, ptr %tokens.addr
  %t.3251 = load i64, ptr %pos.addr
  %r.3252 = call i64 @CurCol(i64 %t.3250, i64 %t.3251)
  %r.3253 = call i64 @NewNode(i64 %t.3243, ptr @.str.162, ptr %r.3246, i64 %r.3249, i64 %r.3252)
  %vn.116 = alloca i64
  store i64 %r.3253, ptr %vn.116
  %t.3254 = load i64, ptr %tokens.addr
  %t.3255 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3254, i64 %t.3255)
  %t.3257 = load i64, ptr %arena.addr
  %t.3258 = load i64, ptr %node.115
  %t.3259 = load i64, ptr %vn.116
  call void @AddChild(i64 %t.3257, i64 %t.3258, i64 %t.3259)
  br label %if.merge.3242
if.merge.3242:
  %t.3261 = load i64, ptr %tokens.addr
  %t.3262 = load i64, ptr %pos.addr
  %r.3263 = call i64 @MatchKw(i64 %t.3261, i64 %t.3262, ptr @.str.36)
  %ext.3265 = icmp ne i64 %r.3263, 0
  %t.3264 = xor i1 %ext.3265, true
  br i1 %t.3264, label %if.then.3266, label %if.merge.3267
if.then.3266:
  %t.3268 = load i64, ptr %errors.addr
  %r.3269 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.3270 = load i64, ptr %tokens.addr
  %t.3271 = load i64, ptr %pos.addr
  %r.3272 = call i64 @CurLine(i64 %t.3270, i64 %t.3271)
  %r.3273 = call ptr @kx_int_str(i64 %r.3272)
  %r.3274 = call ptr @kx_str_cat(ptr %r.3269, ptr %r.3273)
  %r.3275 = call ptr @kx_str_cat(ptr %r.3274, ptr @.str.89)
  %t.3276 = load i64, ptr %tokens.addr
  %t.3277 = load i64, ptr %pos.addr
  %r.3278 = call i64 @CurCol(i64 %t.3276, i64 %t.3277)
  %r.3279 = call ptr @kx_int_str(i64 %r.3278)
  %r.3280 = call ptr @kx_str_cat(ptr %r.3275, ptr %r.3279)
  %r.3281 = call ptr @kx_str_cat(ptr %r.3280, ptr @.str.175)
  %ext.3282 = ptrtoint ptr %r.3281 to i64
  call void @kx_list_add(i64 %t.3268, i64 %ext.3282)
  %t.3283 = load i64, ptr %node.115
  ret i64 %t.3283
dead.3284:
  br label %if.merge.3267
if.merge.3267:
  %t.3285 = load i64, ptr %arena.addr
  %t.3286 = load i64, ptr %node.115
  %t.3287 = load i64, ptr %tokens.addr
  %t.3288 = load i64, ptr %pos.addr
  %t.3289 = load i64, ptr %arena.addr
  %t.3290 = load i64, ptr %errors.addr
  %r.3291 = call i64 @ParseExpression(i64 %t.3287, i64 %t.3288, i64 %t.3289, i64 %t.3290)
  call void @AddChild(i64 %t.3285, i64 %t.3286, i64 %r.3291)
  %t.3293 = load i64, ptr %tokens.addr
  %t.3294 = load i64, ptr %pos.addr
  %t.3295 = load i64, ptr %errors.addr
  %r.3296 = call i64 @ExpectPunct(i64 %t.3293, i64 %t.3294, ptr @.str.100, i64 %t.3295, ptr @.str.176)
  br label %if.merge.3233
if.merge.3233:
  %t.3297 = load i64, ptr %arena.addr
  %t.3298 = load i64, ptr %node.115
  %t.3299 = load i64, ptr %tokens.addr
  %t.3300 = load i64, ptr %pos.addr
  %t.3301 = load i64, ptr %arena.addr
  %t.3302 = load i64, ptr %errors.addr
  %r.3303 = call i64 @ParseStatement(i64 %t.3299, i64 %t.3300, i64 %t.3301, i64 %t.3302)
  call void @AddChild(i64 %t.3297, i64 %t.3298, i64 %r.3303)
  %t.3305 = load i64, ptr %node.115
  ret i64 %t.3305
dead.3306:
  br label %if.merge.3215
if.merge.3215:
  %t.3307 = load i64, ptr %tokens.addr
  %t.3308 = load i64, ptr %pos.addr
  %r.3309 = call i64 @IsKw(i64 %t.3307, i64 %t.3308, ptr @.str.39)
  %ext.3310 = icmp ne i64 %r.3309, 0
  br i1 %ext.3310, label %if.then.3311, label %if.merge.3312
if.then.3311:
  %t.3313 = load i64, ptr %arena.addr
  %t.3314 = load i64, ptr %tokens.addr
  %t.3315 = load i64, ptr %pos.addr
  %r.3316 = call i64 @CurLine(i64 %t.3314, i64 %t.3315)
  %t.3317 = load i64, ptr %tokens.addr
  %t.3318 = load i64, ptr %pos.addr
  %r.3319 = call i64 @CurCol(i64 %t.3317, i64 %t.3318)
  %r.3320 = call i64 @NewNode(i64 %t.3313, ptr @.str.39, ptr @.str.12, i64 %r.3316, i64 %r.3319)
  %node.117 = alloca i64
  store i64 %r.3320, ptr %node.117
  %t.3321 = load i64, ptr %tokens.addr
  %t.3322 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3321, i64 %t.3322)
  %t.3324 = load i64, ptr %tokens.addr
  %t.3325 = load i64, ptr %pos.addr
  %r.3326 = call i64 @IsPunct(i64 %t.3324, i64 %t.3325, ptr @.str.164)
  %ext.3328 = icmp ne i64 %r.3326, 0
  %t.3327 = xor i1 %ext.3328, true
  br i1 %t.3327, label %if.then.3329, label %if.merge.3330
if.then.3329:
  %t.3331 = load i64, ptr %arena.addr
  %t.3332 = load i64, ptr %node.117
  %t.3333 = load i64, ptr %tokens.addr
  %t.3334 = load i64, ptr %pos.addr
  %t.3335 = load i64, ptr %arena.addr
  %t.3336 = load i64, ptr %errors.addr
  %r.3337 = call i64 @ParseExpression(i64 %t.3333, i64 %t.3334, i64 %t.3335, i64 %t.3336)
  call void @AddChild(i64 %t.3331, i64 %t.3332, i64 %r.3337)
  br label %if.merge.3330
if.merge.3330:
  %t.3339 = load i64, ptr %tokens.addr
  %t.3340 = load i64, ptr %pos.addr
  %t.3341 = load i64, ptr %errors.addr
  %r.3342 = call i64 @ExpectPunct(i64 %t.3339, i64 %t.3340, ptr @.str.164, i64 %t.3341, ptr @.str.177)
  %t.3343 = load i64, ptr %node.117
  ret i64 %t.3343
dead.3344:
  br label %if.merge.3312
if.merge.3312:
  %t.3345 = load i64, ptr %tokens.addr
  %t.3346 = load i64, ptr %pos.addr
  %r.3347 = call i64 @IsKw(i64 %t.3345, i64 %t.3346, ptr @.str.37)
  %ext.3348 = icmp ne i64 %r.3347, 0
  br i1 %ext.3348, label %if.then.3349, label %if.merge.3350
if.then.3349:
  %t.3351 = load i64, ptr %arena.addr
  %t.3352 = load i64, ptr %tokens.addr
  %t.3353 = load i64, ptr %pos.addr
  %r.3354 = call i64 @CurLine(i64 %t.3352, i64 %t.3353)
  %t.3355 = load i64, ptr %tokens.addr
  %t.3356 = load i64, ptr %pos.addr
  %r.3357 = call i64 @CurCol(i64 %t.3355, i64 %t.3356)
  %r.3358 = call i64 @NewNode(i64 %t.3351, ptr @.str.37, ptr @.str.12, i64 %r.3354, i64 %r.3357)
  %node.118 = alloca i64
  store i64 %r.3358, ptr %node.118
  %t.3359 = load i64, ptr %tokens.addr
  %t.3360 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3359, i64 %t.3360)
  %t.3362 = load i64, ptr %tokens.addr
  %t.3363 = load i64, ptr %pos.addr
  %t.3364 = load i64, ptr %errors.addr
  %r.3365 = call i64 @ExpectPunct(i64 %t.3362, i64 %t.3363, ptr @.str.164, i64 %t.3364, ptr @.str.178)
  %t.3366 = load i64, ptr %node.118
  ret i64 %t.3366
dead.3367:
  br label %if.merge.3350
if.merge.3350:
  %t.3368 = load i64, ptr %tokens.addr
  %t.3369 = load i64, ptr %pos.addr
  %r.3370 = call i64 @IsKw(i64 %t.3368, i64 %t.3369, ptr @.str.38)
  %ext.3371 = icmp ne i64 %r.3370, 0
  br i1 %ext.3371, label %if.then.3372, label %if.merge.3373
if.then.3372:
  %t.3374 = load i64, ptr %arena.addr
  %t.3375 = load i64, ptr %tokens.addr
  %t.3376 = load i64, ptr %pos.addr
  %r.3377 = call i64 @CurLine(i64 %t.3375, i64 %t.3376)
  %t.3378 = load i64, ptr %tokens.addr
  %t.3379 = load i64, ptr %pos.addr
  %r.3380 = call i64 @CurCol(i64 %t.3378, i64 %t.3379)
  %r.3381 = call i64 @NewNode(i64 %t.3374, ptr @.str.38, ptr @.str.12, i64 %r.3377, i64 %r.3380)
  %node.119 = alloca i64
  store i64 %r.3381, ptr %node.119
  %t.3382 = load i64, ptr %tokens.addr
  %t.3383 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3382, i64 %t.3383)
  %t.3385 = load i64, ptr %tokens.addr
  %t.3386 = load i64, ptr %pos.addr
  %t.3387 = load i64, ptr %errors.addr
  %r.3388 = call i64 @ExpectPunct(i64 %t.3385, i64 %t.3386, ptr @.str.164, i64 %t.3387, ptr @.str.179)
  %t.3389 = load i64, ptr %node.119
  ret i64 %t.3389
dead.3390:
  br label %if.merge.3373
if.merge.3373:
  %t.3391 = load i64, ptr %tokens.addr
  %t.3392 = load i64, ptr %pos.addr
  %r.3393 = call i64 @IsKw(i64 %t.3391, i64 %t.3392, ptr @.str.55)
  %ext.3394 = icmp ne i64 %r.3393, 0
  br i1 %ext.3394, label %if.then.3395, label %if.merge.3396
if.then.3395:
  %t.3397 = load i64, ptr %arena.addr
  %t.3398 = load i64, ptr %tokens.addr
  %t.3399 = load i64, ptr %pos.addr
  %r.3400 = call i64 @CurLine(i64 %t.3398, i64 %t.3399)
  %t.3401 = load i64, ptr %tokens.addr
  %t.3402 = load i64, ptr %pos.addr
  %r.3403 = call i64 @CurCol(i64 %t.3401, i64 %t.3402)
  %r.3404 = call i64 @NewNode(i64 %t.3397, ptr @.str.55, ptr @.str.12, i64 %r.3400, i64 %r.3403)
  %node.120 = alloca i64
  store i64 %r.3404, ptr %node.120
  %t.3405 = load i64, ptr %tokens.addr
  %t.3406 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3405, i64 %t.3406)
  %t.3408 = load i64, ptr %tokens.addr
  %t.3409 = load i64, ptr %pos.addr
  %t.3410 = load i64, ptr %errors.addr
  %r.3411 = call i64 @ExpectPunct(i64 %t.3408, i64 %t.3409, ptr @.str.99, i64 %t.3410, ptr @.str.180)
  %ext.3412 = icmp ne i64 %r.3411, 0
  br i1 %ext.3412, label %if.then.3413, label %if.merge.3414
if.then.3413:
  %t.3415 = load i64, ptr %arena.addr
  %t.3416 = load i64, ptr %node.120
  %t.3417 = load i64, ptr %tokens.addr
  %t.3418 = load i64, ptr %pos.addr
  %t.3419 = load i64, ptr %arena.addr
  %t.3420 = load i64, ptr %errors.addr
  %r.3421 = call i64 @ParseExpression(i64 %t.3417, i64 %t.3418, i64 %t.3419, i64 %t.3420)
  call void @AddChild(i64 %t.3415, i64 %t.3416, i64 %r.3421)
  %t.3423 = load i64, ptr %tokens.addr
  %t.3424 = load i64, ptr %pos.addr
  %t.3425 = load i64, ptr %errors.addr
  %r.3426 = call i64 @ExpectPunct(i64 %t.3423, i64 %t.3424, ptr @.str.100, i64 %t.3425, ptr @.str.181)
  br label %if.merge.3414
if.merge.3414:
  %t.3427 = load i64, ptr %tokens.addr
  %t.3428 = load i64, ptr %pos.addr
  %t.3429 = load i64, ptr %errors.addr
  %r.3430 = call i64 @ExpectPunct(i64 %t.3427, i64 %t.3428, ptr @.str.63, i64 %t.3429, ptr @.str.182)
  %ext.3432 = icmp ne i64 %r.3430, 0
  %t.3431 = xor i1 %ext.3432, true
  br i1 %t.3431, label %if.then.3433, label %if.merge.3434
if.then.3433:
  %t.3435 = load i64, ptr %node.120
  ret i64 %t.3435
dead.3436:
  br label %if.merge.3434
if.merge.3434:
  br label %w.cond.3437
w.cond.3437:
  %t.3440 = load i64, ptr %tokens.addr
  %t.3441 = load i64, ptr %pos.addr
  %r.3442 = call i64 @IsPunct(i64 %t.3440, i64 %t.3441, ptr @.str.64)
  %ext.3444 = icmp ne i64 %r.3442, 0
  %t.3443 = xor i1 %ext.3444, true
  %t.3445 = load i64, ptr %tokens.addr
  %t.3446 = load i64, ptr %pos.addr
  %r.3447 = call i64 @AtEnd(i64 %t.3445, i64 %t.3446)
  %ext.3449 = icmp ne i64 %r.3447, 0
  %t.3448 = xor i1 %ext.3449, true
  %t.3450 = and i1 %t.3443, %t.3448
  br i1 %t.3450, label %w.body.3438, label %w.end.3439
w.body.3438:
  %t.3451 = load i64, ptr %arena.addr
  %t.3452 = load i64, ptr %tokens.addr
  %t.3453 = load i64, ptr %pos.addr
  %r.3454 = call i64 @CurLine(i64 %t.3452, i64 %t.3453)
  %t.3455 = load i64, ptr %tokens.addr
  %t.3456 = load i64, ptr %pos.addr
  %r.3457 = call i64 @CurCol(i64 %t.3455, i64 %t.3456)
  %r.3458 = call i64 @NewNode(i64 %t.3451, ptr @.str.56, ptr @.str.12, i64 %r.3454, i64 %r.3457)
  %caseNode.121 = alloca i64
  store i64 %r.3458, ptr %caseNode.121
  %t.3459 = load i64, ptr %tokens.addr
  %t.3460 = load i64, ptr %pos.addr
  %r.3461 = call i64 @MatchKw(i64 %t.3459, i64 %t.3460, ptr @.str.56)
  %ext.3462 = icmp ne i64 %r.3461, 0
  br i1 %ext.3462, label %if.then.3463, label %if.else.3465
if.then.3463:
  br label %for.cond.3466
for.cond.3466:
  br label %for.body.3467
for.body.3467:
  %t.3470 = load i64, ptr %arena.addr
  %t.3471 = load i64, ptr %caseNode.121
  %t.3472 = load i64, ptr %tokens.addr
  %t.3473 = load i64, ptr %pos.addr
  %t.3474 = load i64, ptr %arena.addr
  %t.3475 = load i64, ptr %errors.addr
  %r.3476 = call i64 @ParseExpression(i64 %t.3472, i64 %t.3473, i64 %t.3474, i64 %t.3475)
  call void @AddChild(i64 %t.3470, i64 %t.3471, i64 %r.3476)
  %t.3478 = load i64, ptr %tokens.addr
  %t.3479 = load i64, ptr %pos.addr
  %r.3480 = call i64 @MatchPunct(i64 %t.3478, i64 %t.3479, ptr @.str.97)
  %ext.3482 = icmp ne i64 %r.3480, 0
  %t.3481 = xor i1 %ext.3482, true
  br i1 %t.3481, label %if.then.3483, label %if.merge.3484
if.then.3483:
  br label %for.end.3469
dead.3485:
  br label %if.merge.3484
if.merge.3484:
  br label %for.inc.3468
for.inc.3468:
  br label %for.cond.3466
for.end.3469:
  %t.3486 = load i64, ptr %tokens.addr
  %t.3487 = load i64, ptr %pos.addr
  %t.3488 = load i64, ptr %errors.addr
  %r.3489 = call i64 @ExpectPunct(i64 %t.3486, i64 %t.3487, ptr @.str.89, i64 %t.3488, ptr @.str.183)
  %ext.3491 = icmp ne i64 %r.3489, 0
  %t.3490 = xor i1 %ext.3491, true
  br i1 %t.3490, label %if.then.3492, label %if.merge.3493
if.then.3492:
  %t.3494 = load i64, ptr %node.120
  ret i64 %t.3494
dead.3495:
  br label %if.merge.3493
if.merge.3493:
  br label %if.merge.3464
if.else.3465:
  %t.3496 = load i64, ptr %tokens.addr
  %t.3497 = load i64, ptr %pos.addr
  %r.3498 = call i64 @MatchKw(i64 %t.3496, i64 %t.3497, ptr @.str.57)
  %ext.3499 = icmp ne i64 %r.3498, 0
  br i1 %ext.3499, label %if.then.3500, label %if.else.3502
if.then.3500:
  %t.3503 = load i64, ptr %tokens.addr
  %t.3504 = load i64, ptr %pos.addr
  %t.3505 = load i64, ptr %errors.addr
  %r.3506 = call i64 @ExpectPunct(i64 %t.3503, i64 %t.3504, ptr @.str.89, i64 %t.3505, ptr @.str.184)
  %ext.3508 = icmp ne i64 %r.3506, 0
  %t.3507 = xor i1 %ext.3508, true
  br i1 %t.3507, label %if.then.3509, label %if.merge.3510
if.then.3509:
  %t.3511 = load i64, ptr %node.120
  ret i64 %t.3511
dead.3512:
  br label %if.merge.3510
if.merge.3510:
  br label %if.merge.3501
if.else.3502:
  %t.3513 = load i64, ptr %errors.addr
  %r.3514 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.3515 = load i64, ptr %tokens.addr
  %t.3516 = load i64, ptr %pos.addr
  %r.3517 = call i64 @CurLine(i64 %t.3515, i64 %t.3516)
  %r.3518 = call ptr @kx_int_str(i64 %r.3517)
  %r.3519 = call ptr @kx_str_cat(ptr %r.3514, ptr %r.3518)
  %r.3520 = call ptr @kx_str_cat(ptr %r.3519, ptr @.str.89)
  %t.3521 = load i64, ptr %tokens.addr
  %t.3522 = load i64, ptr %pos.addr
  %r.3523 = call i64 @CurCol(i64 %t.3521, i64 %t.3522)
  %r.3524 = call ptr @kx_int_str(i64 %r.3523)
  %r.3525 = call ptr @kx_str_cat(ptr %r.3520, ptr %r.3524)
  %r.3526 = call ptr @kx_str_cat(ptr %r.3525, ptr @.str.185)
  %ext.3527 = ptrtoint ptr %r.3526 to i64
  call void @kx_list_add(i64 %t.3513, i64 %ext.3527)
  %t.3528 = load i64, ptr %node.120
  ret i64 %t.3528
dead.3529:
  br label %if.merge.3501
if.merge.3501:
  br label %if.merge.3464
if.merge.3464:
  %t.3530 = load i64, ptr %arena.addr
  %t.3531 = load i64, ptr %tokens.addr
  %t.3532 = load i64, ptr %pos.addr
  %r.3533 = call i64 @CurLine(i64 %t.3531, i64 %t.3532)
  %t.3534 = load i64, ptr %tokens.addr
  %t.3535 = load i64, ptr %pos.addr
  %r.3536 = call i64 @CurCol(i64 %t.3534, i64 %t.3535)
  %r.3537 = call i64 @NewNode(i64 %t.3530, ptr @.str.158, ptr @.str.12, i64 %r.3533, i64 %r.3536)
  %block.122 = alloca i64
  store i64 %r.3537, ptr %block.122
  br label %w.cond.3538
w.cond.3538:
  %t.3541 = load i64, ptr %tokens.addr
  %t.3542 = load i64, ptr %pos.addr
  %r.3543 = call i64 @IsKw(i64 %t.3541, i64 %t.3542, ptr @.str.56)
  %ext.3545 = icmp ne i64 %r.3543, 0
  %t.3544 = xor i1 %ext.3545, true
  %t.3546 = load i64, ptr %tokens.addr
  %t.3547 = load i64, ptr %pos.addr
  %r.3548 = call i64 @IsKw(i64 %t.3546, i64 %t.3547, ptr @.str.57)
  %ext.3550 = icmp ne i64 %r.3548, 0
  %t.3549 = xor i1 %ext.3550, true
  %t.3551 = and i1 %t.3544, %t.3549
  %t.3552 = load i64, ptr %tokens.addr
  %t.3553 = load i64, ptr %pos.addr
  %r.3554 = call i64 @IsPunct(i64 %t.3552, i64 %t.3553, ptr @.str.64)
  %ext.3556 = icmp ne i64 %r.3554, 0
  %t.3555 = xor i1 %ext.3556, true
  %t.3557 = and i1 %t.3551, %t.3555
  %t.3558 = load i64, ptr %tokens.addr
  %t.3559 = load i64, ptr %pos.addr
  %r.3560 = call i64 @AtEnd(i64 %t.3558, i64 %t.3559)
  %ext.3562 = icmp ne i64 %r.3560, 0
  %t.3561 = xor i1 %ext.3562, true
  %t.3563 = and i1 %t.3557, %t.3561
  br i1 %t.3563, label %w.body.3539, label %w.end.3540
w.body.3539:
  %t.3564 = load i64, ptr %arena.addr
  %t.3565 = load i64, ptr %block.122
  %t.3566 = load i64, ptr %tokens.addr
  %t.3567 = load i64, ptr %pos.addr
  %t.3568 = load i64, ptr %arena.addr
  %t.3569 = load i64, ptr %errors.addr
  %r.3570 = call i64 @ParseStatement(i64 %t.3566, i64 %t.3567, i64 %t.3568, i64 %t.3569)
  call void @AddChild(i64 %t.3564, i64 %t.3565, i64 %r.3570)
  br label %w.cond.3538
w.end.3540:
  %t.3572 = load i64, ptr %arena.addr
  %t.3573 = load i64, ptr %caseNode.121
  %t.3574 = load i64, ptr %block.122
  call void @AddChild(i64 %t.3572, i64 %t.3573, i64 %t.3574)
  %t.3576 = load i64, ptr %arena.addr
  %t.3577 = load i64, ptr %node.120
  %t.3578 = load i64, ptr %caseNode.121
  call void @AddChild(i64 %t.3576, i64 %t.3577, i64 %t.3578)
  br label %w.cond.3437
w.end.3439:
  %t.3580 = load i64, ptr %tokens.addr
  %t.3581 = load i64, ptr %pos.addr
  %t.3582 = load i64, ptr %errors.addr
  %r.3583 = call i64 @ExpectPunct(i64 %t.3580, i64 %t.3581, ptr @.str.64, i64 %t.3582, ptr @.str.186)
  %t.3584 = load i64, ptr %node.120
  ret i64 %t.3584
dead.3585:
  br label %if.merge.3396
if.merge.3396:
  %t.3586 = load i64, ptr %tokens.addr
  %t.3587 = load i64, ptr %pos.addr
  %r.3588 = call i64 @IsKw(i64 %t.3586, i64 %t.3587, ptr @.str.42)
  %ext.3589 = icmp ne i64 %r.3588, 0
  br i1 %ext.3589, label %if.then.3590, label %if.merge.3591
if.then.3590:
  %t.3592 = load i64, ptr %arena.addr
  %t.3593 = load i64, ptr %tokens.addr
  %t.3594 = load i64, ptr %pos.addr
  %r.3595 = call i64 @CurLine(i64 %t.3593, i64 %t.3594)
  %t.3596 = load i64, ptr %tokens.addr
  %t.3597 = load i64, ptr %pos.addr
  %r.3598 = call i64 @CurCol(i64 %t.3596, i64 %t.3597)
  %r.3599 = call i64 @NewNode(i64 %t.3592, ptr @.str.42, ptr @.str.12, i64 %r.3595, i64 %r.3598)
  %node.123 = alloca i64
  store i64 %r.3599, ptr %node.123
  %t.3600 = load i64, ptr %tokens.addr
  %t.3601 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3600, i64 %t.3601)
  %t.3603 = load i64, ptr %tokens.addr
  %t.3604 = load i64, ptr %pos.addr
  %t.3605 = load i64, ptr %errors.addr
  %r.3606 = call i64 @ExpectPunct(i64 %t.3603, i64 %t.3604, ptr @.str.99, i64 %t.3605, ptr @.str.187)
  %ext.3608 = icmp ne i64 %r.3606, 0
  %t.3607 = xor i1 %ext.3608, true
  br i1 %t.3607, label %if.then.3609, label %if.merge.3610
if.then.3609:
  %t.3611 = load i64, ptr %node.123
  ret i64 %t.3611
dead.3612:
  br label %if.merge.3610
if.merge.3610:
  %t.3613 = load i64, ptr %arena.addr
  %t.3614 = load i64, ptr %node.123
  %t.3615 = load i64, ptr %tokens.addr
  %t.3616 = load i64, ptr %pos.addr
  %t.3617 = load i64, ptr %arena.addr
  %t.3618 = load i64, ptr %errors.addr
  %r.3619 = call i64 @ParseExpression(i64 %t.3615, i64 %t.3616, i64 %t.3617, i64 %t.3618)
  call void @AddChild(i64 %t.3613, i64 %t.3614, i64 %r.3619)
  %t.3621 = load i64, ptr %tokens.addr
  %t.3622 = load i64, ptr %pos.addr
  %t.3623 = load i64, ptr %errors.addr
  %r.3624 = call i64 @ExpectPunct(i64 %t.3621, i64 %t.3622, ptr @.str.97, i64 %t.3623, ptr @.str.188)
  %ext.3625 = icmp ne i64 %r.3624, 0
  br i1 %ext.3625, label %if.then.3626, label %if.merge.3627
if.then.3626:
  %t.3628 = load i64, ptr %tokens.addr
  %t.3629 = load i64, ptr %pos.addr
  %r.3630 = call i64 @MatchKw(i64 %t.3628, i64 %t.3629, ptr @.str.47)
  %t.3631 = load i64, ptr %arena.addr
  %t.3632 = load i64, ptr %node.123
  %t.3633 = load i64, ptr %tokens.addr
  %t.3634 = load i64, ptr %pos.addr
  %t.3635 = load i64, ptr %arena.addr
  %t.3636 = load i64, ptr %errors.addr
  %r.3637 = call i64 @ParseComponentInit(i64 %t.3633, i64 %t.3634, i64 %t.3635, i64 %t.3636)
  call void @AddChild(i64 %t.3631, i64 %t.3632, i64 %r.3637)
  br label %if.merge.3627
if.merge.3627:
  %t.3639 = load i64, ptr %tokens.addr
  %t.3640 = load i64, ptr %pos.addr
  %t.3641 = load i64, ptr %errors.addr
  %r.3642 = call i64 @ExpectPunct(i64 %t.3639, i64 %t.3640, ptr @.str.100, i64 %t.3641, ptr @.str.189)
  %t.3643 = load i64, ptr %tokens.addr
  %t.3644 = load i64, ptr %pos.addr
  %t.3645 = load i64, ptr %errors.addr
  %r.3646 = call i64 @ExpectPunct(i64 %t.3643, i64 %t.3644, ptr @.str.164, i64 %t.3645, ptr @.str.190)
  %t.3647 = load i64, ptr %node.123
  ret i64 %t.3647
dead.3648:
  br label %if.merge.3591
if.merge.3591:
  %t.3649 = load i64, ptr %tokens.addr
  %t.3650 = load i64, ptr %pos.addr
  %r.3651 = call i64 @IsKw(i64 %t.3649, i64 %t.3650, ptr @.str.43)
  %ext.3652 = icmp ne i64 %r.3651, 0
  br i1 %ext.3652, label %if.then.3653, label %if.merge.3654
if.then.3653:
  %t.3655 = load i64, ptr %arena.addr
  %t.3656 = load i64, ptr %tokens.addr
  %t.3657 = load i64, ptr %pos.addr
  %r.3658 = call i64 @CurLine(i64 %t.3656, i64 %t.3657)
  %t.3659 = load i64, ptr %tokens.addr
  %t.3660 = load i64, ptr %pos.addr
  %r.3661 = call i64 @CurCol(i64 %t.3659, i64 %t.3660)
  %r.3662 = call i64 @NewNode(i64 %t.3655, ptr @.str.43, ptr @.str.12, i64 %r.3658, i64 %r.3661)
  %node.124 = alloca i64
  store i64 %r.3662, ptr %node.124
  %t.3663 = load i64, ptr %tokens.addr
  %t.3664 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3663, i64 %t.3664)
  %t.3666 = load i64, ptr %tokens.addr
  %t.3667 = load i64, ptr %pos.addr
  %t.3668 = load i64, ptr %errors.addr
  %r.3669 = call i64 @ExpectPunct(i64 %t.3666, i64 %t.3667, ptr @.str.99, i64 %t.3668, ptr @.str.191)
  %ext.3671 = icmp ne i64 %r.3669, 0
  %t.3670 = xor i1 %ext.3671, true
  br i1 %t.3670, label %if.then.3672, label %if.merge.3673
if.then.3672:
  %t.3674 = load i64, ptr %node.124
  ret i64 %t.3674
dead.3675:
  br label %if.merge.3673
if.merge.3673:
  %t.3676 = load i64, ptr %arena.addr
  %t.3677 = load i64, ptr %node.124
  %t.3678 = load i64, ptr %tokens.addr
  %t.3679 = load i64, ptr %pos.addr
  %t.3680 = load i64, ptr %arena.addr
  %t.3681 = load i64, ptr %errors.addr
  %r.3682 = call i64 @ParseExpression(i64 %t.3678, i64 %t.3679, i64 %t.3680, i64 %t.3681)
  call void @AddChild(i64 %t.3676, i64 %t.3677, i64 %r.3682)
  %t.3684 = load i64, ptr %tokens.addr
  %t.3685 = load i64, ptr %pos.addr
  %t.3686 = load i64, ptr %errors.addr
  %r.3687 = call i64 @ExpectPunct(i64 %t.3684, i64 %t.3685, ptr @.str.97, i64 %t.3686, ptr @.str.192)
  %ext.3688 = icmp ne i64 %r.3687, 0
  br i1 %ext.3688, label %if.then.3689, label %if.merge.3690
if.then.3689:
  %t.3691 = load i64, ptr %tokens.addr
  %t.3692 = load i64, ptr %pos.addr
  %r.3693 = call i64 @IsNameTok(i64 %t.3691, i64 %t.3692)
  %ext.3694 = icmp ne i64 %r.3693, 0
  br i1 %ext.3694, label %if.then.3695, label %if.merge.3696
if.then.3695:
  %t.3697 = load i64, ptr %tokens.addr
  %t.3698 = load i64, ptr %pos.addr
  %r.3699 = call ptr @CurText(i64 %t.3697, i64 %t.3698)
  %tnText.125 = alloca ptr
  store ptr %r.3699, ptr %tnText.125
  %t.3700 = load i64, ptr %tokens.addr
  %t.3701 = load i64, ptr %pos.addr
  %r.3702 = call i64 @CurLine(i64 %t.3700, i64 %t.3701)
  %tnLine.126 = alloca i64
  store i64 %r.3702, ptr %tnLine.126
  %t.3703 = load i64, ptr %tokens.addr
  %t.3704 = load i64, ptr %pos.addr
  %r.3705 = call i64 @CurCol(i64 %t.3703, i64 %t.3704)
  %tnCol.127 = alloca i64
  store i64 %r.3705, ptr %tnCol.127
  %t.3706 = load i64, ptr %tokens.addr
  %t.3707 = load i64, ptr %pos.addr
  %t.3708 = load i64, ptr %errors.addr
  %r.3709 = call i64 @ExpectName(i64 %t.3706, i64 %t.3707, i64 %t.3708, ptr @.str.193)
  %ext.3710 = icmp ne i64 %r.3709, 0
  br i1 %ext.3710, label %if.then.3711, label %if.merge.3712
if.then.3711:
  %t.3713 = load i64, ptr %arena.addr
  %t.3714 = load i64, ptr %node.124
  %t.3715 = load i64, ptr %arena.addr
  %t.3716 = load ptr, ptr %tnText.125
  %t.3717 = load i64, ptr %tnLine.126
  %t.3718 = load i64, ptr %tnCol.127
  %r.3719 = call i64 @NewNode(i64 %t.3715, ptr @.str.194, ptr %t.3716, i64 %t.3717, i64 %t.3718)
  call void @AddChild(i64 %t.3713, i64 %t.3714, i64 %r.3719)
  br label %if.merge.3712
if.merge.3712:
  br label %if.merge.3696
if.merge.3696:
  br label %if.merge.3690
if.merge.3690:
  %t.3721 = load i64, ptr %tokens.addr
  %t.3722 = load i64, ptr %pos.addr
  %t.3723 = load i64, ptr %errors.addr
  %r.3724 = call i64 @ExpectPunct(i64 %t.3721, i64 %t.3722, ptr @.str.100, i64 %t.3723, ptr @.str.195)
  %t.3725 = load i64, ptr %tokens.addr
  %t.3726 = load i64, ptr %pos.addr
  %t.3727 = load i64, ptr %errors.addr
  %r.3728 = call i64 @ExpectPunct(i64 %t.3725, i64 %t.3726, ptr @.str.164, i64 %t.3727, ptr @.str.196)
  %t.3729 = load i64, ptr %node.124
  ret i64 %t.3729
dead.3730:
  br label %if.merge.3654
if.merge.3654:
  %t.3731 = load i64, ptr %tokens.addr
  %t.3732 = load i64, ptr %pos.addr
  %r.3733 = call i64 @IsKw(i64 %t.3731, i64 %t.3732, ptr @.str.41)
  %ext.3734 = icmp ne i64 %r.3733, 0
  br i1 %ext.3734, label %if.then.3735, label %if.merge.3736
if.then.3735:
  %t.3737 = load i64, ptr %arena.addr
  %t.3738 = load i64, ptr %tokens.addr
  %t.3739 = load i64, ptr %pos.addr
  %r.3740 = call i64 @CurLine(i64 %t.3738, i64 %t.3739)
  %t.3741 = load i64, ptr %tokens.addr
  %t.3742 = load i64, ptr %pos.addr
  %r.3743 = call i64 @CurCol(i64 %t.3741, i64 %t.3742)
  %r.3744 = call i64 @NewNode(i64 %t.3737, ptr @.str.41, ptr @.str.12, i64 %r.3740, i64 %r.3743)
  %node.128 = alloca i64
  store i64 %r.3744, ptr %node.128
  %t.3745 = load i64, ptr %tokens.addr
  %t.3746 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3745, i64 %t.3746)
  %t.3748 = load i64, ptr %arena.addr
  %t.3749 = load i64, ptr %node.128
  %t.3750 = load i64, ptr %tokens.addr
  %t.3751 = load i64, ptr %pos.addr
  %t.3752 = load i64, ptr %arena.addr
  %t.3753 = load i64, ptr %errors.addr
  %r.3754 = call i64 @ParseExpression(i64 %t.3750, i64 %t.3751, i64 %t.3752, i64 %t.3753)
  call void @AddChild(i64 %t.3748, i64 %t.3749, i64 %r.3754)
  %t.3756 = load i64, ptr %tokens.addr
  %t.3757 = load i64, ptr %pos.addr
  %t.3758 = load i64, ptr %errors.addr
  %r.3759 = call i64 @ExpectPunct(i64 %t.3756, i64 %t.3757, ptr @.str.164, i64 %t.3758, ptr @.str.197)
  %t.3760 = load i64, ptr %node.128
  ret i64 %t.3760
dead.3761:
  br label %if.merge.3736
if.merge.3736:
  %t.3762 = load i64, ptr %arena.addr
  %t.3763 = load i64, ptr %tokens.addr
  %t.3764 = load i64, ptr %pos.addr
  %r.3765 = call i64 @CurLine(i64 %t.3763, i64 %t.3764)
  %t.3766 = load i64, ptr %tokens.addr
  %t.3767 = load i64, ptr %pos.addr
  %r.3768 = call i64 @CurCol(i64 %t.3766, i64 %t.3767)
  %r.3769 = call i64 @NewNode(i64 %t.3762, ptr @.str.198, ptr @.str.12, i64 %r.3765, i64 %r.3768)
  %exprNode.129 = alloca i64
  store i64 %r.3769, ptr %exprNode.129
  %t.3770 = load i64, ptr %arena.addr
  %t.3771 = load i64, ptr %exprNode.129
  %t.3772 = load i64, ptr %tokens.addr
  %t.3773 = load i64, ptr %pos.addr
  %t.3774 = load i64, ptr %arena.addr
  %t.3775 = load i64, ptr %errors.addr
  %r.3776 = call i64 @ParseExpression(i64 %t.3772, i64 %t.3773, i64 %t.3774, i64 %t.3775)
  call void @AddChild(i64 %t.3770, i64 %t.3771, i64 %r.3776)
  %t.3778 = load i64, ptr %tokens.addr
  %t.3779 = load i64, ptr %pos.addr
  %t.3780 = load i64, ptr %errors.addr
  %r.3781 = call i64 @ExpectPunct(i64 %t.3778, i64 %t.3779, ptr @.str.164, i64 %t.3780, ptr @.str.199)
  %t.3782 = load i64, ptr %exprNode.129
  ret i64 %t.3782
dead.3783:
  ret i64 0
}

define i64 @ParseComponentDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors, ptr %kind) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %kind.addr = alloca ptr
  store ptr %kind, ptr %kind.addr
  %t.3784 = load i64, ptr %arena.addr
  %t.3785 = load ptr, ptr %kind.addr
  %t.3786 = load i64, ptr %tokens.addr
  %t.3787 = load i64, ptr %pos.addr
  %r.3788 = call i64 @CurLine(i64 %t.3786, i64 %t.3787)
  %t.3789 = load i64, ptr %tokens.addr
  %t.3790 = load i64, ptr %pos.addr
  %r.3791 = call i64 @CurCol(i64 %t.3789, i64 %t.3790)
  %r.3792 = call i64 @NewNode(i64 %t.3784, ptr %t.3785, ptr @.str.12, i64 %r.3788, i64 %r.3791)
  %node.130 = alloca i64
  store i64 %r.3792, ptr %node.130
  %t.3793 = load i64, ptr %tokens.addr
  %t.3794 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3793, i64 %t.3794)
  %t.3796 = load i64, ptr %tokens.addr
  %t.3797 = load i64, ptr %pos.addr
  %r.3798 = call i64 @IsNameTok(i64 %t.3796, i64 %t.3797)
  %ext.3799 = icmp ne i64 %r.3798, 0
  br i1 %ext.3799, label %if.then.3800, label %if.merge.3801
if.then.3800:
  %t.3802 = load i64, ptr %arena.addr
  %t.3803 = load i64, ptr %tokens.addr
  %t.3804 = load i64, ptr %pos.addr
  %r.3805 = call ptr @CurText(i64 %t.3803, i64 %t.3804)
  %t.3806 = load i64, ptr %tokens.addr
  %t.3807 = load i64, ptr %pos.addr
  %r.3808 = call i64 @CurLine(i64 %t.3806, i64 %t.3807)
  %t.3809 = load i64, ptr %tokens.addr
  %t.3810 = load i64, ptr %pos.addr
  %r.3811 = call i64 @CurCol(i64 %t.3809, i64 %t.3810)
  %r.3812 = call i64 @NewNode(i64 %t.3802, ptr @.str.200, ptr %r.3805, i64 %r.3808, i64 %r.3811)
  %dn.131 = alloca i64
  store i64 %r.3812, ptr %dn.131
  %t.3813 = load i64, ptr %tokens.addr
  %t.3814 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3813, i64 %t.3814)
  %t.3816 = load i64, ptr %arena.addr
  %t.3817 = load i64, ptr %node.130
  %t.3818 = load i64, ptr %dn.131
  call void @AddChild(i64 %t.3816, i64 %t.3817, i64 %t.3818)
  br label %if.merge.3801
if.merge.3801:
  %t.3820 = load i64, ptr %tokens.addr
  %t.3821 = load i64, ptr %pos.addr
  %t.3822 = load i64, ptr %errors.addr
  %t.3823 = load ptr, ptr %kind.addr
  %r.3825 = call i1 @kx_str_eq(ptr %t.3823, ptr @.str.16)
  br i1 %r.3825, label %tern.then.3826, label %tern.else.3827
tern.then.3826:
  br label %tern.merge.3828
tern.else.3827:
  br label %tern.merge.3828
tern.merge.3828:
  %phi.3829 = phi ptr [@.str.201, %tern.then.3826], [@.str.202, %tern.else.3827]
  %r.3830 = call i64 @ExpectPunct(i64 %t.3820, i64 %t.3821, ptr @.str.63, i64 %t.3822, ptr %phi.3829)
  %ext.3832 = icmp ne i64 %r.3830, 0
  %t.3831 = xor i1 %ext.3832, true
  br i1 %t.3831, label %if.then.3833, label %if.merge.3834
if.then.3833:
  %t.3835 = load i64, ptr %node.130
  ret i64 %t.3835
dead.3836:
  br label %if.merge.3834
if.merge.3834:
  br label %w.cond.3837
w.cond.3837:
  %t.3840 = load i64, ptr %tokens.addr
  %t.3841 = load i64, ptr %pos.addr
  %r.3842 = call i64 @IsPunct(i64 %t.3840, i64 %t.3841, ptr @.str.64)
  %ext.3844 = icmp ne i64 %r.3842, 0
  %t.3843 = xor i1 %ext.3844, true
  %t.3845 = load i64, ptr %tokens.addr
  %t.3846 = load i64, ptr %pos.addr
  %r.3847 = call i64 @AtEnd(i64 %t.3845, i64 %t.3846)
  %ext.3849 = icmp ne i64 %r.3847, 0
  %t.3848 = xor i1 %ext.3849, true
  %t.3850 = and i1 %t.3843, %t.3848
  br i1 %t.3850, label %w.body.3838, label %w.end.3839
w.body.3838:
  %t.3851 = load i64, ptr %tokens.addr
  %t.3852 = load i64, ptr %pos.addr
  %r.3853 = call i64 @MatchKw(i64 %t.3851, i64 %t.3852, ptr @.str.22)
  %ext.3855 = icmp ne i64 %r.3853, 0
  %t.3854 = xor i1 %ext.3855, true
  br i1 %t.3854, label %if.then.3856, label %if.merge.3857
if.then.3856:
  %t.3858 = load i64, ptr %errors.addr
  %r.3859 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.3860 = load i64, ptr %tokens.addr
  %t.3861 = load i64, ptr %pos.addr
  %r.3862 = call i64 @CurLine(i64 %t.3860, i64 %t.3861)
  %r.3863 = call ptr @kx_int_str(i64 %r.3862)
  %r.3864 = call ptr @kx_str_cat(ptr %r.3859, ptr %r.3863)
  %r.3865 = call ptr @kx_str_cat(ptr %r.3864, ptr @.str.89)
  %t.3866 = load i64, ptr %tokens.addr
  %t.3867 = load i64, ptr %pos.addr
  %r.3868 = call i64 @CurCol(i64 %t.3866, i64 %t.3867)
  %r.3869 = call ptr @kx_int_str(i64 %r.3868)
  %r.3870 = call ptr @kx_str_cat(ptr %r.3865, ptr %r.3869)
  %r.3871 = call ptr @kx_str_cat(ptr %r.3870, ptr @.str.203)
  %ext.3872 = ptrtoint ptr %r.3871 to i64
  call void @kx_list_add(i64 %t.3858, i64 %ext.3872)
  br label %w.end.3839
dead.3873:
  br label %if.merge.3857
if.merge.3857:
  %t.3874 = load i64, ptr %tokens.addr
  %t.3875 = load i64, ptr %pos.addr
  %r.3876 = call i64 @IsNameTok(i64 %t.3874, i64 %t.3875)
  %ext.3877 = icmp ne i64 %r.3876, 0
  br i1 %ext.3877, label %if.then.3878, label %if.merge.3879
if.then.3878:
  %t.3880 = load i64, ptr %arena.addr
  %t.3881 = load i64, ptr %tokens.addr
  %t.3882 = load i64, ptr %pos.addr
  %r.3883 = call ptr @CurText(i64 %t.3881, i64 %t.3882)
  %t.3884 = load i64, ptr %tokens.addr
  %t.3885 = load i64, ptr %pos.addr
  %r.3886 = call i64 @CurLine(i64 %t.3884, i64 %t.3885)
  %t.3887 = load i64, ptr %tokens.addr
  %t.3888 = load i64, ptr %pos.addr
  %r.3889 = call i64 @CurCol(i64 %t.3887, i64 %t.3888)
  %r.3890 = call i64 @NewNode(i64 %t.3880, ptr @.str.96, ptr %r.3883, i64 %r.3886, i64 %r.3889)
  %fn.132 = alloca i64
  store i64 %r.3890, ptr %fn.132
  %t.3891 = load i64, ptr %tokens.addr
  %t.3892 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3891, i64 %t.3892)
  %t.3894 = load i64, ptr %tokens.addr
  %t.3895 = load i64, ptr %pos.addr
  %t.3896 = load i64, ptr %errors.addr
  %r.3897 = call i64 @ExpectPunct(i64 %t.3894, i64 %t.3895, ptr @.str.94, i64 %t.3896, ptr @.str.204)
  %ext.3898 = icmp ne i64 %r.3897, 0
  br i1 %ext.3898, label %if.then.3899, label %if.merge.3900
if.then.3899:
  %t.3901 = load i64, ptr %arena.addr
  %t.3902 = load i64, ptr %fn.132
  %t.3903 = load i64, ptr %tokens.addr
  %t.3904 = load i64, ptr %pos.addr
  %t.3905 = load i64, ptr %arena.addr
  %t.3906 = load i64, ptr %errors.addr
  %r.3907 = call i64 @ParseExpression(i64 %t.3903, i64 %t.3904, i64 %t.3905, i64 %t.3906)
  call void @AddChild(i64 %t.3901, i64 %t.3902, i64 %r.3907)
  br label %if.merge.3900
if.merge.3900:
  %t.3909 = load i64, ptr %arena.addr
  %t.3910 = load i64, ptr %node.130
  %t.3911 = load i64, ptr %fn.132
  call void @AddChild(i64 %t.3909, i64 %t.3910, i64 %t.3911)
  br label %if.merge.3879
if.merge.3879:
  %t.3913 = load i64, ptr %tokens.addr
  %t.3914 = load i64, ptr %pos.addr
  %t.3915 = load i64, ptr %errors.addr
  %r.3916 = call i64 @ExpectPunct(i64 %t.3913, i64 %t.3914, ptr @.str.164, i64 %t.3915, ptr @.str.205)
  br label %w.cond.3837
w.end.3839:
  %t.3917 = load i64, ptr %tokens.addr
  %t.3918 = load i64, ptr %pos.addr
  %t.3919 = load i64, ptr %errors.addr
  %t.3920 = load ptr, ptr %kind.addr
  %r.3922 = call i1 @kx_str_eq(ptr %t.3920, ptr @.str.16)
  br i1 %r.3922, label %tern.then.3923, label %tern.else.3924
tern.then.3923:
  br label %tern.merge.3925
tern.else.3924:
  br label %tern.merge.3925
tern.merge.3925:
  %phi.3926 = phi ptr [@.str.206, %tern.then.3923], [@.str.207, %tern.else.3924]
  %r.3927 = call i64 @ExpectPunct(i64 %t.3917, i64 %t.3918, ptr @.str.64, i64 %t.3919, ptr %phi.3926)
  %t.3928 = load i64, ptr %node.130
  ret i64 %t.3928
dead.3929:
  ret i64 0
}

define i64 @ParseFunctionDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.3930 = load i64, ptr %arena.addr
  %t.3931 = load i64, ptr %tokens.addr
  %t.3932 = load i64, ptr %pos.addr
  %r.3933 = call i64 @CurLine(i64 %t.3931, i64 %t.3932)
  %t.3934 = load i64, ptr %tokens.addr
  %t.3935 = load i64, ptr %pos.addr
  %r.3936 = call i64 @CurCol(i64 %t.3934, i64 %t.3935)
  %r.3937 = call i64 @NewNode(i64 %t.3930, ptr @.str.208, ptr @.str.12, i64 %r.3933, i64 %r.3936)
  %node.133 = alloca i64
  store i64 %r.3937, ptr %node.133
  %retText.134 = alloca ptr
  store ptr @.str.12, ptr %retText.134
  %nameText.135 = alloca ptr
  store ptr @.str.12, ptr %nameText.135
  %t.3938 = load i64, ptr %tokens.addr
  %t.3939 = load i64, ptr %pos.addr
  %r.3940 = call i64 @IsNameTok(i64 %t.3938, i64 %t.3939)
  %ext.3941 = icmp ne i64 %r.3940, 0
  br i1 %ext.3941, label %if.then.3942, label %if.merge.3943
if.then.3942:
  %t.3944 = load i64, ptr %tokens.addr
  %t.3945 = load i64, ptr %pos.addr
  %r.3946 = call ptr @CurText(i64 %t.3944, i64 %t.3945)
  store ptr %r.3946, ptr %retText.134
  %t.3947 = load i64, ptr %tokens.addr
  %t.3948 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3947, i64 %t.3948)
  br label %if.merge.3943
if.merge.3943:
  %t.3950 = load i64, ptr %tokens.addr
  %t.3951 = load i64, ptr %pos.addr
  %r.3952 = call i64 @IsNameTok(i64 %t.3950, i64 %t.3951)
  %ext.3953 = icmp ne i64 %r.3952, 0
  br i1 %ext.3953, label %if.then.3954, label %if.merge.3955
if.then.3954:
  %t.3956 = load i64, ptr %tokens.addr
  %t.3957 = load i64, ptr %pos.addr
  %r.3958 = call ptr @CurText(i64 %t.3956, i64 %t.3957)
  store ptr %r.3958, ptr %nameText.135
  %t.3959 = load i64, ptr %tokens.addr
  %t.3960 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.3959, i64 %t.3960)
  br label %if.merge.3955
if.merge.3955:
  %t.3962 = load ptr, ptr %nameText.135
  %r.3964 = call i1 @kx_str_eq(ptr %t.3962, ptr @.str.12)
  br i1 %r.3964, label %if.then.3965, label %if.merge.3966
if.then.3965:
  %t.3967 = load i64, ptr %arena.addr
  %t.3968 = load i64, ptr %node.133
  %t.3969 = load i64, ptr %arena.addr
  %t.3970 = load ptr, ptr %nameText.135
  %t.3971 = load i64, ptr %tokens.addr
  %t.3972 = load i64, ptr %pos.addr
  %r.3973 = call i64 @CurLine(i64 %t.3971, i64 %t.3972)
  %t.3974 = load i64, ptr %tokens.addr
  %t.3975 = load i64, ptr %pos.addr
  %r.3976 = call i64 @CurCol(i64 %t.3974, i64 %t.3975)
  %r.3977 = call i64 @NewNode(i64 %t.3969, ptr @.str.200, ptr %t.3970, i64 %r.3973, i64 %r.3976)
  call void @AddChild(i64 %t.3967, i64 %t.3968, i64 %r.3977)
  br label %if.merge.3966
if.merge.3966:
  %t.3979 = load ptr, ptr %retText.134
  %r.3981 = call i1 @kx_str_eq(ptr %t.3979, ptr @.str.12)
  br i1 %r.3981, label %if.then.3982, label %if.merge.3983
if.then.3982:
  %t.3984 = load i64, ptr %arena.addr
  %t.3985 = load i64, ptr %node.133
  %t.3986 = load i64, ptr %arena.addr
  %t.3987 = load ptr, ptr %retText.134
  %t.3988 = load i64, ptr %tokens.addr
  %t.3989 = load i64, ptr %pos.addr
  %r.3990 = call i64 @CurLine(i64 %t.3988, i64 %t.3989)
  %t.3991 = load i64, ptr %tokens.addr
  %t.3992 = load i64, ptr %pos.addr
  %r.3993 = call i64 @CurCol(i64 %t.3991, i64 %t.3992)
  %r.3994 = call i64 @NewNode(i64 %t.3986, ptr @.str.209, ptr %t.3987, i64 %r.3990, i64 %r.3993)
  call void @AddChild(i64 %t.3984, i64 %t.3985, i64 %r.3994)
  br label %if.merge.3983
if.merge.3983:
  %t.3996 = load i64, ptr %tokens.addr
  %t.3997 = load i64, ptr %pos.addr
  %t.3998 = load i64, ptr %errors.addr
  %r.3999 = call i64 @ExpectPunct(i64 %t.3996, i64 %t.3997, ptr @.str.99, i64 %t.3998, ptr @.str.210)
  %ext.4001 = icmp ne i64 %r.3999, 0
  %t.4000 = xor i1 %ext.4001, true
  br i1 %t.4000, label %if.then.4002, label %if.merge.4003
if.then.4002:
  %t.4004 = load i64, ptr %node.133
  ret i64 %t.4004
dead.4005:
  br label %if.merge.4003
if.merge.4003:
  br label %w.cond.4006
w.cond.4006:
  %t.4009 = load i64, ptr %tokens.addr
  %t.4010 = load i64, ptr %pos.addr
  %r.4011 = call i64 @IsNameTok(i64 %t.4009, i64 %t.4010)
  %t.4012 = load i64, ptr %tokens.addr
  %t.4013 = load i64, ptr %pos.addr
  %r.4014 = call i64 @IsPunct(i64 %t.4012, i64 %t.4013, ptr @.str.100)
  %ext.4016 = icmp ne i64 %r.4014, 0
  %t.4015 = xor i1 %ext.4016, true
  %ext.4018 = icmp ne i64 %r.4011, 0
  %t.4017 = and i1 %ext.4018, %t.4015
  br i1 %t.4017, label %w.body.4007, label %w.end.4008
w.body.4007:
  %t.4019 = load i64, ptr %arena.addr
  %t.4020 = load i64, ptr %tokens.addr
  %t.4021 = load i64, ptr %pos.addr
  %r.4022 = call ptr @CurText(i64 %t.4020, i64 %t.4021)
  %t.4023 = load i64, ptr %tokens.addr
  %t.4024 = load i64, ptr %pos.addr
  %r.4025 = call i64 @CurLine(i64 %t.4023, i64 %t.4024)
  %t.4026 = load i64, ptr %tokens.addr
  %t.4027 = load i64, ptr %pos.addr
  %r.4028 = call i64 @CurCol(i64 %t.4026, i64 %t.4027)
  %r.4029 = call i64 @NewNode(i64 %t.4019, ptr @.str.211, ptr %r.4022, i64 %r.4025, i64 %r.4028)
  %pn.136 = alloca i64
  store i64 %r.4029, ptr %pn.136
  %t.4030 = load i64, ptr %tokens.addr
  %t.4031 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4030, i64 %t.4031)
  %t.4033 = load i64, ptr %arena.addr
  %t.4034 = load i64, ptr %node.133
  %t.4035 = load i64, ptr %pn.136
  call void @AddChild(i64 %t.4033, i64 %t.4034, i64 %t.4035)
  %t.4037 = load i64, ptr %tokens.addr
  %t.4038 = load i64, ptr %pos.addr
  %r.4039 = call i64 @MatchPunct(i64 %t.4037, i64 %t.4038, ptr @.str.97)
  %ext.4041 = icmp ne i64 %r.4039, 0
  %t.4040 = xor i1 %ext.4041, true
  br i1 %t.4040, label %if.then.4042, label %if.merge.4043
if.then.4042:
  br label %w.end.4008
dead.4044:
  br label %if.merge.4043
if.merge.4043:
  br label %w.cond.4006
w.end.4008:
  %t.4045 = load i64, ptr %tokens.addr
  %t.4046 = load i64, ptr %pos.addr
  %t.4047 = load i64, ptr %errors.addr
  %r.4048 = call i64 @ExpectPunct(i64 %t.4045, i64 %t.4046, ptr @.str.100, i64 %t.4047, ptr @.str.212)
  %t.4049 = load i64, ptr %arena.addr
  %t.4050 = load i64, ptr %node.133
  %t.4051 = load i64, ptr %tokens.addr
  %t.4052 = load i64, ptr %pos.addr
  %t.4053 = load i64, ptr %arena.addr
  %t.4054 = load i64, ptr %errors.addr
  %r.4055 = call i64 @ParseBlock(i64 %t.4051, i64 %t.4052, i64 %t.4053, i64 %t.4054)
  call void @AddChild(i64 %t.4049, i64 %t.4050, i64 %r.4055)
  %t.4057 = load i64, ptr %node.133
  ret i64 %t.4057
dead.4058:
  ret i64 0
}

define i64 @ParseTagDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.4059 = load i64, ptr %arena.addr
  %t.4060 = load i64, ptr %tokens.addr
  %t.4061 = load i64, ptr %pos.addr
  %r.4062 = call i64 @CurLine(i64 %t.4060, i64 %t.4061)
  %t.4063 = load i64, ptr %tokens.addr
  %t.4064 = load i64, ptr %pos.addr
  %r.4065 = call i64 @CurCol(i64 %t.4063, i64 %t.4064)
  %r.4066 = call i64 @NewNode(i64 %t.4059, ptr @.str.18, ptr @.str.12, i64 %r.4062, i64 %r.4065)
  %node.137 = alloca i64
  store i64 %r.4066, ptr %node.137
  %t.4067 = load i64, ptr %tokens.addr
  %t.4068 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4067, i64 %t.4068)
  %t.4070 = load i64, ptr %tokens.addr
  %t.4071 = load i64, ptr %pos.addr
  %r.4072 = call i64 @IsNameTok(i64 %t.4070, i64 %t.4071)
  %ext.4073 = icmp ne i64 %r.4072, 0
  br i1 %ext.4073, label %if.then.4074, label %if.merge.4075
if.then.4074:
  %t.4076 = load i64, ptr %arena.addr
  %t.4077 = load i64, ptr %tokens.addr
  %t.4078 = load i64, ptr %pos.addr
  %r.4079 = call ptr @CurText(i64 %t.4077, i64 %t.4078)
  %t.4080 = load i64, ptr %tokens.addr
  %t.4081 = load i64, ptr %pos.addr
  %r.4082 = call i64 @CurLine(i64 %t.4080, i64 %t.4081)
  %t.4083 = load i64, ptr %tokens.addr
  %t.4084 = load i64, ptr %pos.addr
  %r.4085 = call i64 @CurCol(i64 %t.4083, i64 %t.4084)
  %r.4086 = call i64 @NewNode(i64 %t.4076, ptr @.str.200, ptr %r.4079, i64 %r.4082, i64 %r.4085)
  %dn.138 = alloca i64
  store i64 %r.4086, ptr %dn.138
  %t.4087 = load i64, ptr %tokens.addr
  %t.4088 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4087, i64 %t.4088)
  %t.4090 = load i64, ptr %arena.addr
  %t.4091 = load i64, ptr %node.137
  %t.4092 = load i64, ptr %dn.138
  call void @AddChild(i64 %t.4090, i64 %t.4091, i64 %t.4092)
  br label %if.merge.4075
if.merge.4075:
  %t.4094 = load i64, ptr %tokens.addr
  %t.4095 = load i64, ptr %pos.addr
  %r.4096 = call i64 @MatchPunct(i64 %t.4094, i64 %t.4095, ptr @.str.89)
  %ext.4097 = icmp ne i64 %r.4096, 0
  br i1 %ext.4097, label %if.then.4098, label %if.merge.4099
if.then.4098:
  %t.4100 = load i64, ptr %tokens.addr
  %t.4101 = load i64, ptr %pos.addr
  %r.4102 = call i64 @IsNameTok(i64 %t.4100, i64 %t.4101)
  %ext.4103 = icmp ne i64 %r.4102, 0
  br i1 %ext.4103, label %if.then.4104, label %if.merge.4105
if.then.4104:
  %t.4106 = load i64, ptr %tokens.addr
  %t.4107 = load i64, ptr %pos.addr
  %r.4108 = call ptr @CurText(i64 %t.4106, i64 %t.4107)
  %pnText.139 = alloca ptr
  store ptr %r.4108, ptr %pnText.139
  %t.4109 = load i64, ptr %tokens.addr
  %t.4110 = load i64, ptr %pos.addr
  %r.4111 = call i64 @CurLine(i64 %t.4109, i64 %t.4110)
  %pnLine.140 = alloca i64
  store i64 %r.4111, ptr %pnLine.140
  %t.4112 = load i64, ptr %tokens.addr
  %t.4113 = load i64, ptr %pos.addr
  %r.4114 = call i64 @CurCol(i64 %t.4112, i64 %t.4113)
  %pnCol.141 = alloca i64
  store i64 %r.4114, ptr %pnCol.141
  %t.4115 = load i64, ptr %tokens.addr
  %t.4116 = load i64, ptr %pos.addr
  %t.4117 = load i64, ptr %errors.addr
  %r.4118 = call i64 @ExpectName(i64 %t.4115, i64 %t.4116, i64 %t.4117, ptr @.str.213)
  %ext.4119 = icmp ne i64 %r.4118, 0
  br i1 %ext.4119, label %if.then.4120, label %if.merge.4121
if.then.4120:
  %t.4122 = load i64, ptr %arena.addr
  %t.4123 = load i64, ptr %node.137
  %t.4124 = load i64, ptr %arena.addr
  %t.4125 = load ptr, ptr %pnText.139
  %t.4126 = load i64, ptr %pnLine.140
  %t.4127 = load i64, ptr %pnCol.141
  %r.4128 = call i64 @NewNode(i64 %t.4124, ptr @.str.214, ptr %t.4125, i64 %t.4126, i64 %t.4127)
  call void @AddChild(i64 %t.4122, i64 %t.4123, i64 %r.4128)
  br label %if.merge.4121
if.merge.4121:
  br label %if.merge.4105
if.merge.4105:
  br label %if.merge.4099
if.merge.4099:
  %t.4130 = load i64, ptr %tokens.addr
  %t.4131 = load i64, ptr %pos.addr
  %t.4132 = load i64, ptr %errors.addr
  %r.4133 = call i64 @ExpectPunct(i64 %t.4130, i64 %t.4131, ptr @.str.164, i64 %t.4132, ptr @.str.215)
  %t.4134 = load i64, ptr %node.137
  ret i64 %t.4134
dead.4135:
  ret i64 0
}

define i64 @ParseEnumDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.4136 = load i64, ptr %arena.addr
  %t.4137 = load i64, ptr %tokens.addr
  %t.4138 = load i64, ptr %pos.addr
  %r.4139 = call i64 @CurLine(i64 %t.4137, i64 %t.4138)
  %t.4140 = load i64, ptr %tokens.addr
  %t.4141 = load i64, ptr %pos.addr
  %r.4142 = call i64 @CurCol(i64 %t.4140, i64 %t.4141)
  %r.4143 = call i64 @NewNode(i64 %t.4136, ptr @.str.20, ptr @.str.12, i64 %r.4139, i64 %r.4142)
  %node.142 = alloca i64
  store i64 %r.4143, ptr %node.142
  %t.4144 = load i64, ptr %tokens.addr
  %t.4145 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4144, i64 %t.4145)
  %t.4147 = load i64, ptr %tokens.addr
  %t.4148 = load i64, ptr %pos.addr
  %r.4149 = call i64 @IsNameTok(i64 %t.4147, i64 %t.4148)
  %ext.4150 = icmp ne i64 %r.4149, 0
  br i1 %ext.4150, label %if.then.4151, label %if.merge.4152
if.then.4151:
  %t.4153 = load i64, ptr %arena.addr
  %t.4154 = load i64, ptr %tokens.addr
  %t.4155 = load i64, ptr %pos.addr
  %r.4156 = call ptr @CurText(i64 %t.4154, i64 %t.4155)
  %t.4157 = load i64, ptr %tokens.addr
  %t.4158 = load i64, ptr %pos.addr
  %r.4159 = call i64 @CurLine(i64 %t.4157, i64 %t.4158)
  %t.4160 = load i64, ptr %tokens.addr
  %t.4161 = load i64, ptr %pos.addr
  %r.4162 = call i64 @CurCol(i64 %t.4160, i64 %t.4161)
  %r.4163 = call i64 @NewNode(i64 %t.4153, ptr @.str.200, ptr %r.4156, i64 %r.4159, i64 %r.4162)
  %dn.143 = alloca i64
  store i64 %r.4163, ptr %dn.143
  %t.4164 = load i64, ptr %tokens.addr
  %t.4165 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4164, i64 %t.4165)
  %t.4167 = load i64, ptr %arena.addr
  %t.4168 = load i64, ptr %node.142
  %t.4169 = load i64, ptr %dn.143
  call void @AddChild(i64 %t.4167, i64 %t.4168, i64 %t.4169)
  br label %if.merge.4152
if.merge.4152:
  %t.4171 = load i64, ptr %tokens.addr
  %t.4172 = load i64, ptr %pos.addr
  %t.4173 = load i64, ptr %errors.addr
  %r.4174 = call i64 @ExpectPunct(i64 %t.4171, i64 %t.4172, ptr @.str.63, i64 %t.4173, ptr @.str.216)
  %ext.4176 = icmp ne i64 %r.4174, 0
  %t.4175 = xor i1 %ext.4176, true
  br i1 %t.4175, label %if.then.4177, label %if.merge.4178
if.then.4177:
  %t.4179 = load i64, ptr %node.142
  ret i64 %t.4179
dead.4180:
  br label %if.merge.4178
if.merge.4178:
  br label %w.cond.4181
w.cond.4181:
  %t.4184 = load i64, ptr %tokens.addr
  %t.4185 = load i64, ptr %pos.addr
  %r.4186 = call i64 @IsNameTok(i64 %t.4184, i64 %t.4185)
  %t.4187 = load i64, ptr %tokens.addr
  %t.4188 = load i64, ptr %pos.addr
  %r.4189 = call i64 @IsPunct(i64 %t.4187, i64 %t.4188, ptr @.str.64)
  %ext.4191 = icmp ne i64 %r.4189, 0
  %t.4190 = xor i1 %ext.4191, true
  %ext.4193 = icmp ne i64 %r.4186, 0
  %t.4192 = and i1 %ext.4193, %t.4190
  br i1 %t.4192, label %w.body.4182, label %w.end.4183
w.body.4182:
  %t.4194 = load i64, ptr %arena.addr
  %t.4195 = load i64, ptr %tokens.addr
  %t.4196 = load i64, ptr %pos.addr
  %r.4197 = call ptr @CurText(i64 %t.4195, i64 %t.4196)
  %t.4198 = load i64, ptr %tokens.addr
  %t.4199 = load i64, ptr %pos.addr
  %r.4200 = call i64 @CurLine(i64 %t.4198, i64 %t.4199)
  %t.4201 = load i64, ptr %tokens.addr
  %t.4202 = load i64, ptr %pos.addr
  %r.4203 = call i64 @CurCol(i64 %t.4201, i64 %t.4202)
  %r.4204 = call i64 @NewNode(i64 %t.4194, ptr @.str.111, ptr %r.4197, i64 %r.4200, i64 %r.4203)
  %mn.144 = alloca i64
  store i64 %r.4204, ptr %mn.144
  %t.4205 = load i64, ptr %tokens.addr
  %t.4206 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4205, i64 %t.4206)
  %t.4208 = load i64, ptr %arena.addr
  %t.4209 = load i64, ptr %node.142
  %t.4210 = load i64, ptr %mn.144
  call void @AddChild(i64 %t.4208, i64 %t.4209, i64 %t.4210)
  %t.4212 = load i64, ptr %tokens.addr
  %t.4213 = load i64, ptr %pos.addr
  %r.4214 = call i64 @MatchPunct(i64 %t.4212, i64 %t.4213, ptr @.str.97)
  %ext.4216 = icmp ne i64 %r.4214, 0
  %t.4215 = xor i1 %ext.4216, true
  br i1 %t.4215, label %if.then.4217, label %if.merge.4218
if.then.4217:
  br label %w.end.4183
dead.4219:
  br label %if.merge.4218
if.merge.4218:
  br label %w.cond.4181
w.end.4183:
  %t.4220 = load i64, ptr %tokens.addr
  %t.4221 = load i64, ptr %pos.addr
  %t.4222 = load i64, ptr %errors.addr
  %r.4223 = call i64 @ExpectPunct(i64 %t.4220, i64 %t.4221, ptr @.str.64, i64 %t.4222, ptr @.str.217)
  %t.4224 = load i64, ptr %node.142
  ret i64 %t.4224
dead.4225:
  ret i64 0
}

define i64 @ParseConstDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.4226 = load i64, ptr %arena.addr
  %t.4227 = load i64, ptr %tokens.addr
  %t.4228 = load i64, ptr %pos.addr
  %r.4229 = call i64 @CurLine(i64 %t.4227, i64 %t.4228)
  %t.4230 = load i64, ptr %tokens.addr
  %t.4231 = load i64, ptr %pos.addr
  %r.4232 = call i64 @CurCol(i64 %t.4230, i64 %t.4231)
  %r.4233 = call i64 @NewNode(i64 %t.4226, ptr @.str.21, ptr @.str.12, i64 %r.4229, i64 %r.4232)
  %node.145 = alloca i64
  store i64 %r.4233, ptr %node.145
  %t.4234 = load i64, ptr %tokens.addr
  %t.4235 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4234, i64 %t.4235)
  %t.4237 = load i64, ptr %tokens.addr
  %t.4238 = load i64, ptr %pos.addr
  %r.4239 = call i64 @IsNameTok(i64 %t.4237, i64 %t.4238)
  %ext.4240 = icmp ne i64 %r.4239, 0
  br i1 %ext.4240, label %if.then.4241, label %if.merge.4242
if.then.4241:
  %t.4243 = load i64, ptr %arena.addr
  %t.4244 = load i64, ptr %tokens.addr
  %t.4245 = load i64, ptr %pos.addr
  %r.4246 = call ptr @CurText(i64 %t.4244, i64 %t.4245)
  %t.4247 = load i64, ptr %tokens.addr
  %t.4248 = load i64, ptr %pos.addr
  %r.4249 = call i64 @CurLine(i64 %t.4247, i64 %t.4248)
  %t.4250 = load i64, ptr %tokens.addr
  %t.4251 = load i64, ptr %pos.addr
  %r.4252 = call i64 @CurCol(i64 %t.4250, i64 %t.4251)
  %r.4253 = call i64 @NewNode(i64 %t.4243, ptr @.str.200, ptr %r.4246, i64 %r.4249, i64 %r.4252)
  %dn.146 = alloca i64
  store i64 %r.4253, ptr %dn.146
  %t.4254 = load i64, ptr %tokens.addr
  %t.4255 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4254, i64 %t.4255)
  %t.4257 = load i64, ptr %arena.addr
  %t.4258 = load i64, ptr %node.145
  %t.4259 = load i64, ptr %dn.146
  call void @AddChild(i64 %t.4257, i64 %t.4258, i64 %t.4259)
  br label %if.merge.4242
if.merge.4242:
  %t.4261 = load i64, ptr %tokens.addr
  %t.4262 = load i64, ptr %pos.addr
  %t.4263 = load i64, ptr %errors.addr
  %r.4264 = call i64 @ExpectPunct(i64 %t.4261, i64 %t.4262, ptr @.str.94, i64 %t.4263, ptr @.str.218)
  %ext.4265 = icmp ne i64 %r.4264, 0
  br i1 %ext.4265, label %if.then.4266, label %if.merge.4267
if.then.4266:
  %t.4268 = load i64, ptr %arena.addr
  %t.4269 = load i64, ptr %node.145
  %t.4270 = load i64, ptr %tokens.addr
  %t.4271 = load i64, ptr %pos.addr
  %t.4272 = load i64, ptr %arena.addr
  %t.4273 = load i64, ptr %errors.addr
  %r.4274 = call i64 @ParseExpression(i64 %t.4270, i64 %t.4271, i64 %t.4272, i64 %t.4273)
  call void @AddChild(i64 %t.4268, i64 %t.4269, i64 %r.4274)
  br label %if.merge.4267
if.merge.4267:
  %t.4276 = load i64, ptr %tokens.addr
  %t.4277 = load i64, ptr %pos.addr
  %t.4278 = load i64, ptr %errors.addr
  %r.4279 = call i64 @ExpectPunct(i64 %t.4276, i64 %t.4277, ptr @.str.164, i64 %t.4278, ptr @.str.219)
  %t.4280 = load i64, ptr %node.145
  ret i64 %t.4280
dead.4281:
  ret i64 0
}

define i64 @ParseSystemDecl(i64 %tokens, i64 %pos, i64 %arena, i64 %errors) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %t.4282 = load i64, ptr %arena.addr
  %t.4283 = load i64, ptr %tokens.addr
  %t.4284 = load i64, ptr %pos.addr
  %r.4285 = call i64 @CurLine(i64 %t.4283, i64 %t.4284)
  %t.4286 = load i64, ptr %tokens.addr
  %t.4287 = load i64, ptr %pos.addr
  %r.4288 = call i64 @CurCol(i64 %t.4286, i64 %t.4287)
  %r.4289 = call i64 @NewNode(i64 %t.4282, ptr @.str.17, ptr @.str.12, i64 %r.4285, i64 %r.4288)
  %node.147 = alloca i64
  store i64 %r.4289, ptr %node.147
  %t.4290 = load i64, ptr %tokens.addr
  %t.4291 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4290, i64 %t.4291)
  %t.4293 = load i64, ptr %tokens.addr
  %t.4294 = load i64, ptr %pos.addr
  %r.4295 = call i64 @IsNameTok(i64 %t.4293, i64 %t.4294)
  %ext.4296 = icmp ne i64 %r.4295, 0
  br i1 %ext.4296, label %if.then.4297, label %if.merge.4298
if.then.4297:
  %t.4299 = load i64, ptr %arena.addr
  %t.4300 = load i64, ptr %tokens.addr
  %t.4301 = load i64, ptr %pos.addr
  %r.4302 = call ptr @CurText(i64 %t.4300, i64 %t.4301)
  %t.4303 = load i64, ptr %tokens.addr
  %t.4304 = load i64, ptr %pos.addr
  %r.4305 = call i64 @CurLine(i64 %t.4303, i64 %t.4304)
  %t.4306 = load i64, ptr %tokens.addr
  %t.4307 = load i64, ptr %pos.addr
  %r.4308 = call i64 @CurCol(i64 %t.4306, i64 %t.4307)
  %r.4309 = call i64 @NewNode(i64 %t.4299, ptr @.str.200, ptr %r.4302, i64 %r.4305, i64 %r.4308)
  %dn.148 = alloca i64
  store i64 %r.4309, ptr %dn.148
  %t.4310 = load i64, ptr %tokens.addr
  %t.4311 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4310, i64 %t.4311)
  %t.4313 = load i64, ptr %arena.addr
  %t.4314 = load i64, ptr %node.147
  %t.4315 = load i64, ptr %dn.148
  call void @AddChild(i64 %t.4313, i64 %t.4314, i64 %t.4315)
  br label %if.merge.4298
if.merge.4298:
  br label %for.cond.4317
for.cond.4317:
  br label %for.body.4318
for.body.4318:
  %t.4321 = load i64, ptr %tokens.addr
  %t.4322 = load i64, ptr %pos.addr
  %r.4323 = call i64 @MatchKw(i64 %t.4321, i64 %t.4322, ptr @.str.45)
  %ext.4324 = icmp ne i64 %r.4323, 0
  br i1 %ext.4324, label %if.then.4325, label %if.merge.4326
if.then.4325:
  %t.4327 = load i64, ptr %tokens.addr
  %t.4328 = load i64, ptr %pos.addr
  %t.4329 = load i64, ptr %errors.addr
  %r.4330 = call i64 @ExpectPunct(i64 %t.4327, i64 %t.4328, ptr @.str.99, i64 %t.4329, ptr @.str.220)
  %ext.4331 = icmp ne i64 %r.4330, 0
  br i1 %ext.4331, label %if.then.4332, label %if.merge.4333
if.then.4332:
  br label %w.cond.4334
w.cond.4334:
  %t.4337 = load i64, ptr %tokens.addr
  %t.4338 = load i64, ptr %pos.addr
  %r.4339 = call i64 @IsNameTok(i64 %t.4337, i64 %t.4338)
  %t.4340 = load i64, ptr %tokens.addr
  %t.4341 = load i64, ptr %pos.addr
  %r.4342 = call i64 @IsPunct(i64 %t.4340, i64 %t.4341, ptr @.str.100)
  %ext.4344 = icmp ne i64 %r.4342, 0
  %t.4343 = xor i1 %ext.4344, true
  %ext.4346 = icmp ne i64 %r.4339, 0
  %t.4345 = and i1 %ext.4346, %t.4343
  br i1 %t.4345, label %w.body.4335, label %w.end.4336
w.body.4335:
  %t.4347 = load i64, ptr %arena.addr
  %t.4348 = load i64, ptr %tokens.addr
  %t.4349 = load i64, ptr %pos.addr
  %r.4350 = call ptr @CurText(i64 %t.4348, i64 %t.4349)
  %t.4351 = load i64, ptr %tokens.addr
  %t.4352 = load i64, ptr %pos.addr
  %r.4353 = call i64 @CurLine(i64 %t.4351, i64 %t.4352)
  %t.4354 = load i64, ptr %tokens.addr
  %t.4355 = load i64, ptr %pos.addr
  %r.4356 = call i64 @CurCol(i64 %t.4354, i64 %t.4355)
  %r.4357 = call i64 @NewNode(i64 %t.4347, ptr @.str.45, ptr %r.4350, i64 %r.4353, i64 %r.4356)
  %wn.149 = alloca i64
  store i64 %r.4357, ptr %wn.149
  %t.4358 = load i64, ptr %tokens.addr
  %t.4359 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4358, i64 %t.4359)
  %t.4361 = load i64, ptr %arena.addr
  %t.4362 = load i64, ptr %node.147
  %t.4363 = load i64, ptr %wn.149
  call void @AddChild(i64 %t.4361, i64 %t.4362, i64 %t.4363)
  %t.4365 = load i64, ptr %tokens.addr
  %t.4366 = load i64, ptr %pos.addr
  %r.4367 = call i64 @MatchPunct(i64 %t.4365, i64 %t.4366, ptr @.str.97)
  %ext.4369 = icmp ne i64 %r.4367, 0
  %t.4368 = xor i1 %ext.4369, true
  br i1 %t.4368, label %if.then.4370, label %if.merge.4371
if.then.4370:
  br label %w.end.4336
dead.4372:
  br label %if.merge.4371
if.merge.4371:
  br label %w.cond.4334
w.end.4336:
  %t.4373 = load i64, ptr %tokens.addr
  %t.4374 = load i64, ptr %pos.addr
  %t.4375 = load i64, ptr %errors.addr
  %r.4376 = call i64 @ExpectPunct(i64 %t.4373, i64 %t.4374, ptr @.str.100, i64 %t.4375, ptr @.str.221)
  br label %if.merge.4333
if.merge.4333:
  br label %for.inc.4319
dead.4377:
  br label %if.merge.4326
if.merge.4326:
  %t.4378 = load i64, ptr %tokens.addr
  %t.4379 = load i64, ptr %pos.addr
  %r.4380 = call i64 @MatchKw(i64 %t.4378, i64 %t.4379, ptr @.str.46)
  %ext.4381 = icmp ne i64 %r.4380, 0
  br i1 %ext.4381, label %if.then.4382, label %if.merge.4383
if.then.4382:
  %t.4384 = load i64, ptr %tokens.addr
  %t.4385 = load i64, ptr %pos.addr
  %t.4386 = load i64, ptr %errors.addr
  %r.4387 = call i64 @ExpectPunct(i64 %t.4384, i64 %t.4385, ptr @.str.99, i64 %t.4386, ptr @.str.222)
  %ext.4388 = icmp ne i64 %r.4387, 0
  br i1 %ext.4388, label %if.then.4389, label %if.merge.4390
if.then.4389:
  br label %w.cond.4391
w.cond.4391:
  %t.4394 = load i64, ptr %tokens.addr
  %t.4395 = load i64, ptr %pos.addr
  %r.4396 = call i64 @IsNameTok(i64 %t.4394, i64 %t.4395)
  %t.4397 = load i64, ptr %tokens.addr
  %t.4398 = load i64, ptr %pos.addr
  %r.4399 = call i64 @IsPunct(i64 %t.4397, i64 %t.4398, ptr @.str.100)
  %ext.4401 = icmp ne i64 %r.4399, 0
  %t.4400 = xor i1 %ext.4401, true
  %ext.4403 = icmp ne i64 %r.4396, 0
  %t.4402 = and i1 %ext.4403, %t.4400
  br i1 %t.4402, label %w.body.4392, label %w.end.4393
w.body.4392:
  %t.4404 = load i64, ptr %arena.addr
  %t.4405 = load i64, ptr %tokens.addr
  %t.4406 = load i64, ptr %pos.addr
  %r.4407 = call ptr @CurText(i64 %t.4405, i64 %t.4406)
  %t.4408 = load i64, ptr %tokens.addr
  %t.4409 = load i64, ptr %pos.addr
  %r.4410 = call i64 @CurLine(i64 %t.4408, i64 %t.4409)
  %t.4411 = load i64, ptr %tokens.addr
  %t.4412 = load i64, ptr %pos.addr
  %r.4413 = call i64 @CurCol(i64 %t.4411, i64 %t.4412)
  %r.4414 = call i64 @NewNode(i64 %t.4404, ptr @.str.46, ptr %r.4407, i64 %r.4410, i64 %r.4413)
  %wn.150 = alloca i64
  store i64 %r.4414, ptr %wn.150
  %t.4415 = load i64, ptr %tokens.addr
  %t.4416 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4415, i64 %t.4416)
  %t.4418 = load i64, ptr %arena.addr
  %t.4419 = load i64, ptr %node.147
  %t.4420 = load i64, ptr %wn.150
  call void @AddChild(i64 %t.4418, i64 %t.4419, i64 %t.4420)
  %t.4422 = load i64, ptr %tokens.addr
  %t.4423 = load i64, ptr %pos.addr
  %r.4424 = call i64 @MatchPunct(i64 %t.4422, i64 %t.4423, ptr @.str.97)
  %ext.4426 = icmp ne i64 %r.4424, 0
  %t.4425 = xor i1 %ext.4426, true
  br i1 %t.4425, label %if.then.4427, label %if.merge.4428
if.then.4427:
  br label %w.end.4393
dead.4429:
  br label %if.merge.4428
if.merge.4428:
  br label %w.cond.4391
w.end.4393:
  %t.4430 = load i64, ptr %tokens.addr
  %t.4431 = load i64, ptr %pos.addr
  %t.4432 = load i64, ptr %errors.addr
  %r.4433 = call i64 @ExpectPunct(i64 %t.4430, i64 %t.4431, ptr @.str.100, i64 %t.4432, ptr @.str.223)
  br label %if.merge.4390
if.merge.4390:
  br label %for.inc.4319
dead.4434:
  br label %if.merge.4383
if.merge.4383:
  br label %for.end.4320
dead.4435:
  br label %for.inc.4319
for.inc.4319:
  br label %for.cond.4317
for.end.4320:
  br label %w.cond.4436
w.cond.4436:
  %t.4439 = load i64, ptr %tokens.addr
  %t.4440 = load i64, ptr %pos.addr
  %r.4441 = call i64 @IsPunct(i64 %t.4439, i64 %t.4440, ptr @.str.146)
  %ext.4442 = icmp ne i64 %r.4441, 0
  br i1 %ext.4442, label %w.body.4437, label %w.end.4438
w.body.4437:
  %t.4443 = load i64, ptr %tokens.addr
  %t.4444 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4443, i64 %t.4444)
  %t.4446 = load i64, ptr %arena.addr
  %t.4447 = load i64, ptr %tokens.addr
  %t.4448 = load i64, ptr %pos.addr
  %r.4449 = call i64 @CurLine(i64 %t.4447, i64 %t.4448)
  %t.4450 = load i64, ptr %tokens.addr
  %t.4451 = load i64, ptr %pos.addr
  %r.4452 = call i64 @CurCol(i64 %t.4450, i64 %t.4451)
  %r.4453 = call i64 @NewNode(i64 %t.4446, ptr @.str.224, ptr @.str.12, i64 %r.4449, i64 %r.4452)
  %attr.151 = alloca i64
  store i64 %r.4453, ptr %attr.151
  %t.4454 = load i64, ptr %tokens.addr
  %t.4455 = load i64, ptr %pos.addr
  %r.4456 = call i64 @IsNameTok(i64 %t.4454, i64 %t.4455)
  %ext.4457 = icmp ne i64 %r.4456, 0
  br i1 %ext.4457, label %if.then.4458, label %if.merge.4459
if.then.4458:
  %t.4460 = load i64, ptr %arena.addr
  %t.4461 = load i64, ptr %tokens.addr
  %t.4462 = load i64, ptr %pos.addr
  %r.4463 = call ptr @CurText(i64 %t.4461, i64 %t.4462)
  %t.4464 = load i64, ptr %tokens.addr
  %t.4465 = load i64, ptr %pos.addr
  %r.4466 = call i64 @CurLine(i64 %t.4464, i64 %t.4465)
  %t.4467 = load i64, ptr %tokens.addr
  %t.4468 = load i64, ptr %pos.addr
  %r.4469 = call i64 @CurCol(i64 %t.4467, i64 %t.4468)
  %r.4470 = call i64 @NewNode(i64 %t.4460, ptr @.str.225, ptr %r.4463, i64 %r.4466, i64 %r.4469)
  %an.152 = alloca i64
  store i64 %r.4470, ptr %an.152
  %t.4471 = load i64, ptr %tokens.addr
  %t.4472 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4471, i64 %t.4472)
  %t.4474 = load i64, ptr %arena.addr
  %t.4475 = load i64, ptr %attr.151
  %t.4476 = load i64, ptr %an.152
  call void @AddChild(i64 %t.4474, i64 %t.4475, i64 %t.4476)
  br label %if.merge.4459
if.merge.4459:
  %t.4478 = load i64, ptr %tokens.addr
  %t.4479 = load i64, ptr %pos.addr
  %r.4480 = call i64 @MatchPunct(i64 %t.4478, i64 %t.4479, ptr @.str.99)
  %ext.4481 = icmp ne i64 %r.4480, 0
  br i1 %ext.4481, label %if.then.4482, label %if.merge.4483
if.then.4482:
  br label %w.cond.4484
w.cond.4484:
  %t.4487 = load i64, ptr %tokens.addr
  %t.4488 = load i64, ptr %pos.addr
  %r.4489 = call i64 @IsPunct(i64 %t.4487, i64 %t.4488, ptr @.str.100)
  %ext.4491 = icmp ne i64 %r.4489, 0
  %t.4490 = xor i1 %ext.4491, true
  %t.4492 = load i64, ptr %tokens.addr
  %t.4493 = load i64, ptr %pos.addr
  %r.4494 = call i64 @AtEnd(i64 %t.4492, i64 %t.4493)
  %ext.4496 = icmp ne i64 %r.4494, 0
  %t.4495 = xor i1 %ext.4496, true
  %t.4497 = and i1 %t.4490, %t.4495
  br i1 %t.4497, label %w.body.4485, label %w.end.4486
w.body.4485:
  %t.4498 = load i64, ptr %arena.addr
  %t.4499 = load i64, ptr %attr.151
  %t.4500 = load i64, ptr %tokens.addr
  %t.4501 = load i64, ptr %pos.addr
  %t.4502 = load i64, ptr %arena.addr
  %t.4503 = load i64, ptr %errors.addr
  %r.4504 = call i64 @ParseExpression(i64 %t.4500, i64 %t.4501, i64 %t.4502, i64 %t.4503)
  call void @AddChild(i64 %t.4498, i64 %t.4499, i64 %r.4504)
  %t.4506 = load i64, ptr %tokens.addr
  %t.4507 = load i64, ptr %pos.addr
  %r.4508 = call i64 @MatchPunct(i64 %t.4506, i64 %t.4507, ptr @.str.97)
  %ext.4510 = icmp ne i64 %r.4508, 0
  %t.4509 = xor i1 %ext.4510, true
  br i1 %t.4509, label %if.then.4511, label %if.merge.4512
if.then.4511:
  br label %w.end.4486
dead.4513:
  br label %if.merge.4512
if.merge.4512:
  br label %w.cond.4484
w.end.4486:
  %t.4514 = load i64, ptr %tokens.addr
  %t.4515 = load i64, ptr %pos.addr
  %t.4516 = load i64, ptr %errors.addr
  %r.4517 = call i64 @ExpectPunct(i64 %t.4514, i64 %t.4515, ptr @.str.100, i64 %t.4516, ptr @.str.226)
  br label %if.merge.4483
if.merge.4483:
  %t.4518 = load i64, ptr %tokens.addr
  %t.4519 = load i64, ptr %pos.addr
  %t.4520 = load i64, ptr %errors.addr
  %r.4521 = call i64 @ExpectPunct(i64 %t.4518, i64 %t.4519, ptr @.str.148, i64 %t.4520, ptr @.str.227)
  %t.4522 = load i64, ptr %arena.addr
  %t.4523 = load i64, ptr %node.147
  %t.4524 = load i64, ptr %attr.151
  call void @AddChild(i64 %t.4522, i64 %t.4523, i64 %t.4524)
  br label %w.cond.4436
w.end.4438:
  %t.4526 = load i64, ptr %arena.addr
  %t.4527 = load i64, ptr %node.147
  %t.4528 = load i64, ptr %tokens.addr
  %t.4529 = load i64, ptr %pos.addr
  %t.4530 = load i64, ptr %arena.addr
  %t.4531 = load i64, ptr %errors.addr
  %r.4532 = call i64 @ParseBlock(i64 %t.4528, i64 %t.4529, i64 %t.4530, i64 %t.4531)
  call void @AddChild(i64 %t.4526, i64 %t.4527, i64 %r.4532)
  %t.4534 = load i64, ptr %node.147
  ret i64 %t.4534
dead.4535:
  ret i64 0
}

define i64 @ParseProgram(i64 %tokens, i64 %pos, i64 %arena, i64 %errors, ptr %file) {
entry:
  %tokens.addr = alloca i64
  store i64 %tokens, ptr %tokens.addr
  %pos.addr = alloca i64
  store i64 %pos, ptr %pos.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %errors.addr = alloca i64
  store i64 %errors, ptr %errors.addr
  %file.addr = alloca ptr
  store ptr %file, ptr %file.addr
  %t.4536 = load i64, ptr %arena.addr
  %t.4537 = load ptr, ptr %file.addr
  %cast.4538 = sext i32 0 to i64
  %cast.4539 = sext i32 0 to i64
  %r.4540 = call i64 @NewNode(i64 %t.4536, ptr @.str.228, ptr %t.4537, i64 %cast.4538, i64 %cast.4539)
  %root.153 = alloca i64
  store i64 %r.4540, ptr %root.153
  br label %w.cond.4541
w.cond.4541:
  %t.4544 = load i64, ptr %tokens.addr
  %t.4545 = load i64, ptr %pos.addr
  %r.4546 = call i64 @AtEnd(i64 %t.4544, i64 %t.4545)
  %ext.4548 = icmp ne i64 %r.4546, 0
  %t.4547 = xor i1 %ext.4548, true
  br i1 %t.4547, label %w.body.4542, label %w.end.4543
w.body.4542:
  %t.4549 = load i64, ptr %tokens.addr
  %t.4550 = load i64, ptr %pos.addr
  %r.4551 = call i64 @IsKw(i64 %t.4549, i64 %t.4550, ptr @.str.49)
  %ext.4552 = icmp ne i64 %r.4551, 0
  br i1 %ext.4552, label %if.then.4553, label %if.merge.4554
if.then.4553:
  %t.4555 = load i64, ptr %tokens.addr
  %t.4556 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4555, i64 %t.4556)
  %t.4558 = load i64, ptr %arena.addr
  %t.4559 = load i64, ptr %tokens.addr
  %t.4560 = load i64, ptr %pos.addr
  %r.4561 = call i64 @CurLine(i64 %t.4559, i64 %t.4560)
  %t.4562 = load i64, ptr %tokens.addr
  %t.4563 = load i64, ptr %pos.addr
  %r.4564 = call i64 @CurCol(i64 %t.4562, i64 %t.4563)
  %r.4565 = call i64 @NewNode(i64 %t.4558, ptr @.str.49, ptr @.str.12, i64 %r.4561, i64 %r.4564)
  %un.154 = alloca i64
  store i64 %r.4565, ptr %un.154
  br label %w.cond.4566
w.cond.4566:
  %t.4569 = load i64, ptr %tokens.addr
  %t.4570 = load i64, ptr %pos.addr
  %r.4571 = call i64 @IsNameTok(i64 %t.4569, i64 %t.4570)
  %ext.4572 = icmp ne i64 %r.4571, 0
  br i1 %ext.4572, label %w.body.4567, label %w.end.4568
w.body.4567:
  %t.4573 = load i64, ptr %arena.addr
  %t.4574 = load i64, ptr %tokens.addr
  %t.4575 = load i64, ptr %pos.addr
  %r.4576 = call ptr @CurText(i64 %t.4574, i64 %t.4575)
  %t.4577 = load i64, ptr %tokens.addr
  %t.4578 = load i64, ptr %pos.addr
  %r.4579 = call i64 @CurLine(i64 %t.4577, i64 %t.4578)
  %t.4580 = load i64, ptr %tokens.addr
  %t.4581 = load i64, ptr %pos.addr
  %r.4582 = call i64 @CurCol(i64 %t.4580, i64 %t.4581)
  %r.4583 = call i64 @NewNode(i64 %t.4573, ptr @.str.229, ptr %r.4576, i64 %r.4579, i64 %r.4582)
  %nn.155 = alloca i64
  store i64 %r.4583, ptr %nn.155
  %t.4584 = load i64, ptr %tokens.addr
  %t.4585 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4584, i64 %t.4585)
  %t.4587 = load i64, ptr %arena.addr
  %t.4588 = load i64, ptr %un.154
  %t.4589 = load i64, ptr %nn.155
  call void @AddChild(i64 %t.4587, i64 %t.4588, i64 %t.4589)
  %t.4591 = load i64, ptr %tokens.addr
  %t.4592 = load i64, ptr %pos.addr
  %r.4593 = call i64 @MatchPunct(i64 %t.4591, i64 %t.4592, ptr @.str.60)
  %ext.4595 = icmp ne i64 %r.4593, 0
  %t.4594 = xor i1 %ext.4595, true
  br i1 %t.4594, label %if.then.4596, label %if.merge.4597
if.then.4596:
  br label %w.end.4568
dead.4598:
  br label %if.merge.4597
if.merge.4597:
  br label %w.cond.4566
w.end.4568:
  %t.4599 = load i64, ptr %tokens.addr
  %t.4600 = load i64, ptr %pos.addr
  %t.4601 = load i64, ptr %errors.addr
  %r.4602 = call i64 @ExpectPunct(i64 %t.4599, i64 %t.4600, ptr @.str.164, i64 %t.4601, ptr @.str.230)
  %t.4603 = load i64, ptr %arena.addr
  %t.4604 = load i64, ptr %root.153
  %t.4605 = load i64, ptr %un.154
  call void @AddChild(i64 %t.4603, i64 %t.4604, i64 %t.4605)
  br label %w.cond.4541
dead.4607:
  br label %if.merge.4554
if.merge.4554:
  %t.4608 = load i64, ptr %tokens.addr
  %t.4609 = load i64, ptr %pos.addr
  %r.4610 = call i64 @IsKw(i64 %t.4608, i64 %t.4609, ptr @.str.16)
  %ext.4611 = icmp ne i64 %r.4610, 0
  br i1 %ext.4611, label %if.then.4612, label %if.merge.4613
if.then.4612:
  %t.4614 = load i64, ptr %arena.addr
  %t.4615 = load i64, ptr %root.153
  %t.4616 = load i64, ptr %tokens.addr
  %t.4617 = load i64, ptr %pos.addr
  %t.4618 = load i64, ptr %arena.addr
  %t.4619 = load i64, ptr %errors.addr
  %r.4620 = call i64 @ParseComponentDecl(i64 %t.4616, i64 %t.4617, i64 %t.4618, i64 %t.4619, ptr @.str.16)
  call void @AddChild(i64 %t.4614, i64 %t.4615, i64 %r.4620)
  br label %w.cond.4541
dead.4622:
  br label %if.merge.4613
if.merge.4613:
  %t.4623 = load i64, ptr %tokens.addr
  %t.4624 = load i64, ptr %pos.addr
  %r.4625 = call i64 @IsKw(i64 %t.4623, i64 %t.4624, ptr @.str.19)
  %ext.4626 = icmp ne i64 %r.4625, 0
  br i1 %ext.4626, label %if.then.4627, label %if.merge.4628
if.then.4627:
  %t.4629 = load i64, ptr %arena.addr
  %t.4630 = load i64, ptr %root.153
  %t.4631 = load i64, ptr %tokens.addr
  %t.4632 = load i64, ptr %pos.addr
  %t.4633 = load i64, ptr %arena.addr
  %t.4634 = load i64, ptr %errors.addr
  %r.4635 = call i64 @ParseComponentDecl(i64 %t.4631, i64 %t.4632, i64 %t.4633, i64 %t.4634, ptr @.str.19)
  call void @AddChild(i64 %t.4629, i64 %t.4630, i64 %r.4635)
  br label %w.cond.4541
dead.4637:
  br label %if.merge.4628
if.merge.4628:
  %t.4638 = load i64, ptr %tokens.addr
  %t.4639 = load i64, ptr %pos.addr
  %r.4640 = call i64 @IsKw(i64 %t.4638, i64 %t.4639, ptr @.str.17)
  %ext.4641 = icmp ne i64 %r.4640, 0
  br i1 %ext.4641, label %if.then.4642, label %if.merge.4643
if.then.4642:
  %t.4644 = load i64, ptr %arena.addr
  %t.4645 = load i64, ptr %root.153
  %t.4646 = load i64, ptr %tokens.addr
  %t.4647 = load i64, ptr %pos.addr
  %t.4648 = load i64, ptr %arena.addr
  %t.4649 = load i64, ptr %errors.addr
  %r.4650 = call i64 @ParseSystemDecl(i64 %t.4646, i64 %t.4647, i64 %t.4648, i64 %t.4649)
  call void @AddChild(i64 %t.4644, i64 %t.4645, i64 %r.4650)
  br label %w.cond.4541
dead.4652:
  br label %if.merge.4643
if.merge.4643:
  %t.4653 = load i64, ptr %tokens.addr
  %t.4654 = load i64, ptr %pos.addr
  %r.4655 = call i64 @IsKw(i64 %t.4653, i64 %t.4654, ptr @.str.18)
  %ext.4656 = icmp ne i64 %r.4655, 0
  br i1 %ext.4656, label %if.then.4657, label %if.merge.4658
if.then.4657:
  %t.4659 = load i64, ptr %arena.addr
  %t.4660 = load i64, ptr %root.153
  %t.4661 = load i64, ptr %tokens.addr
  %t.4662 = load i64, ptr %pos.addr
  %t.4663 = load i64, ptr %arena.addr
  %t.4664 = load i64, ptr %errors.addr
  %r.4665 = call i64 @ParseTagDecl(i64 %t.4661, i64 %t.4662, i64 %t.4663, i64 %t.4664)
  call void @AddChild(i64 %t.4659, i64 %t.4660, i64 %r.4665)
  br label %w.cond.4541
dead.4667:
  br label %if.merge.4658
if.merge.4658:
  %t.4668 = load i64, ptr %tokens.addr
  %t.4669 = load i64, ptr %pos.addr
  %r.4670 = call i64 @IsKw(i64 %t.4668, i64 %t.4669, ptr @.str.20)
  %ext.4671 = icmp ne i64 %r.4670, 0
  br i1 %ext.4671, label %if.then.4672, label %if.merge.4673
if.then.4672:
  %t.4674 = load i64, ptr %arena.addr
  %t.4675 = load i64, ptr %root.153
  %t.4676 = load i64, ptr %tokens.addr
  %t.4677 = load i64, ptr %pos.addr
  %t.4678 = load i64, ptr %arena.addr
  %t.4679 = load i64, ptr %errors.addr
  %r.4680 = call i64 @ParseEnumDecl(i64 %t.4676, i64 %t.4677, i64 %t.4678, i64 %t.4679)
  call void @AddChild(i64 %t.4674, i64 %t.4675, i64 %r.4680)
  br label %w.cond.4541
dead.4682:
  br label %if.merge.4673
if.merge.4673:
  %t.4683 = load i64, ptr %tokens.addr
  %t.4684 = load i64, ptr %pos.addr
  %r.4685 = call i64 @IsKw(i64 %t.4683, i64 %t.4684, ptr @.str.21)
  %ext.4686 = icmp ne i64 %r.4685, 0
  br i1 %ext.4686, label %if.then.4687, label %if.merge.4688
if.then.4687:
  %t.4689 = load i64, ptr %arena.addr
  %t.4690 = load i64, ptr %root.153
  %t.4691 = load i64, ptr %tokens.addr
  %t.4692 = load i64, ptr %pos.addr
  %t.4693 = load i64, ptr %arena.addr
  %t.4694 = load i64, ptr %errors.addr
  %r.4695 = call i64 @ParseConstDecl(i64 %t.4691, i64 %t.4692, i64 %t.4693, i64 %t.4694)
  call void @AddChild(i64 %t.4689, i64 %t.4690, i64 %r.4695)
  br label %w.cond.4541
dead.4697:
  br label %if.merge.4688
if.merge.4688:
  %t.4698 = load i64, ptr %tokens.addr
  %t.4699 = load i64, ptr %pos.addr
  %r.4700 = call i64 @IsKw(i64 %t.4698, i64 %t.4699, ptr @.str.58)
  %ext.4701 = icmp ne i64 %r.4700, 0
  br i1 %ext.4701, label %if.then.4702, label %if.merge.4703
if.then.4702:
  %t.4704 = load i64, ptr %tokens.addr
  %t.4705 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4704, i64 %t.4705)
  %t.4707 = load i64, ptr %arena.addr
  %t.4708 = load i64, ptr %tokens.addr
  %t.4709 = load i64, ptr %pos.addr
  %r.4710 = call i64 @CurLine(i64 %t.4708, i64 %t.4709)
  %t.4711 = load i64, ptr %tokens.addr
  %t.4712 = load i64, ptr %pos.addr
  %r.4713 = call i64 @CurCol(i64 %t.4711, i64 %t.4712)
  %r.4714 = call i64 @NewNode(i64 %t.4707, ptr @.str.58, ptr @.str.12, i64 %r.4710, i64 %r.4713)
  %en.156 = alloca i64
  store i64 %r.4714, ptr %en.156
  %t.4715 = load i64, ptr %tokens.addr
  %t.4716 = load i64, ptr %pos.addr
  %r.4717 = call i64 @IsNameTok(i64 %t.4715, i64 %t.4716)
  %ext.4718 = icmp ne i64 %r.4717, 0
  br i1 %ext.4718, label %if.then.4719, label %if.merge.4720
if.then.4719:
  %t.4721 = load i64, ptr %arena.addr
  %t.4722 = load i64, ptr %tokens.addr
  %t.4723 = load i64, ptr %pos.addr
  %r.4724 = call ptr @CurText(i64 %t.4722, i64 %t.4723)
  %t.4725 = load i64, ptr %tokens.addr
  %t.4726 = load i64, ptr %pos.addr
  %r.4727 = call i64 @CurLine(i64 %t.4725, i64 %t.4726)
  %t.4728 = load i64, ptr %tokens.addr
  %t.4729 = load i64, ptr %pos.addr
  %r.4730 = call i64 @CurCol(i64 %t.4728, i64 %t.4729)
  %r.4731 = call i64 @NewNode(i64 %t.4721, ptr @.str.209, ptr %r.4724, i64 %r.4727, i64 %r.4730)
  %rn.157 = alloca i64
  store i64 %r.4731, ptr %rn.157
  %t.4732 = load i64, ptr %tokens.addr
  %t.4733 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4732, i64 %t.4733)
  %t.4735 = load i64, ptr %arena.addr
  %t.4736 = load i64, ptr %en.156
  %t.4737 = load i64, ptr %rn.157
  call void @AddChild(i64 %t.4735, i64 %t.4736, i64 %t.4737)
  br label %if.merge.4720
if.merge.4720:
  %t.4739 = load i64, ptr %tokens.addr
  %t.4740 = load i64, ptr %pos.addr
  %r.4741 = call i64 @IsNameTok(i64 %t.4739, i64 %t.4740)
  %ext.4742 = icmp ne i64 %r.4741, 0
  br i1 %ext.4742, label %if.then.4743, label %if.merge.4744
if.then.4743:
  %t.4745 = load i64, ptr %arena.addr
  %t.4746 = load i64, ptr %tokens.addr
  %t.4747 = load i64, ptr %pos.addr
  %r.4748 = call ptr @CurText(i64 %t.4746, i64 %t.4747)
  %t.4749 = load i64, ptr %tokens.addr
  %t.4750 = load i64, ptr %pos.addr
  %r.4751 = call i64 @CurLine(i64 %t.4749, i64 %t.4750)
  %t.4752 = load i64, ptr %tokens.addr
  %t.4753 = load i64, ptr %pos.addr
  %r.4754 = call i64 @CurCol(i64 %t.4752, i64 %t.4753)
  %r.4755 = call i64 @NewNode(i64 %t.4745, ptr @.str.200, ptr %r.4748, i64 %r.4751, i64 %r.4754)
  %dn.158 = alloca i64
  store i64 %r.4755, ptr %dn.158
  %t.4756 = load i64, ptr %tokens.addr
  %t.4757 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4756, i64 %t.4757)
  %t.4759 = load i64, ptr %arena.addr
  %t.4760 = load i64, ptr %en.156
  %t.4761 = load i64, ptr %dn.158
  call void @AddChild(i64 %t.4759, i64 %t.4760, i64 %t.4761)
  br label %if.merge.4744
if.merge.4744:
  %t.4763 = load i64, ptr %tokens.addr
  %t.4764 = load i64, ptr %pos.addr
  %t.4765 = load i64, ptr %errors.addr
  %r.4766 = call i64 @ExpectPunct(i64 %t.4763, i64 %t.4764, ptr @.str.99, i64 %t.4765, ptr @.str.210)
  %ext.4768 = icmp ne i64 %r.4766, 0
  %t.4767 = xor i1 %ext.4768, true
  br i1 %t.4767, label %if.then.4769, label %if.merge.4770
if.then.4769:
  %t.4771 = load i64, ptr %arena.addr
  %t.4772 = load i64, ptr %root.153
  %t.4773 = load i64, ptr %en.156
  call void @AddChild(i64 %t.4771, i64 %t.4772, i64 %t.4773)
  br label %w.cond.4541
dead.4775:
  br label %if.merge.4770
if.merge.4770:
  br label %w.cond.4776
w.cond.4776:
  %t.4779 = load i64, ptr %tokens.addr
  %t.4780 = load i64, ptr %pos.addr
  %r.4781 = call i64 @IsPunct(i64 %t.4779, i64 %t.4780, ptr @.str.100)
  %ext.4783 = icmp ne i64 %r.4781, 0
  %t.4782 = xor i1 %ext.4783, true
  %t.4784 = load i64, ptr %tokens.addr
  %t.4785 = load i64, ptr %pos.addr
  %r.4786 = call i64 @AtEnd(i64 %t.4784, i64 %t.4785)
  %ext.4788 = icmp ne i64 %r.4786, 0
  %t.4787 = xor i1 %ext.4788, true
  %t.4789 = and i1 %t.4782, %t.4787
  br i1 %t.4789, label %w.body.4777, label %w.end.4778
w.body.4777:
  %t.4790 = load i64, ptr %tokens.addr
  %t.4791 = load i64, ptr %pos.addr
  %r.4792 = call i64 @IsNameTok(i64 %t.4790, i64 %t.4791)
  %ext.4793 = icmp ne i64 %r.4792, 0
  br i1 %ext.4793, label %if.then.4794, label %if.merge.4795
if.then.4794:
  %t.4796 = load i64, ptr %arena.addr
  %t.4797 = load i64, ptr %tokens.addr
  %t.4798 = load i64, ptr %pos.addr
  %r.4799 = call ptr @CurText(i64 %t.4797, i64 %t.4798)
  %t.4800 = load i64, ptr %tokens.addr
  %t.4801 = load i64, ptr %pos.addr
  %r.4802 = call i64 @CurLine(i64 %t.4800, i64 %t.4801)
  %t.4803 = load i64, ptr %tokens.addr
  %t.4804 = load i64, ptr %pos.addr
  %r.4805 = call i64 @CurCol(i64 %t.4803, i64 %t.4804)
  %r.4806 = call i64 @NewNode(i64 %t.4796, ptr @.str.231, ptr %r.4799, i64 %r.4802, i64 %r.4805)
  %pt.159 = alloca i64
  store i64 %r.4806, ptr %pt.159
  %t.4807 = load i64, ptr %tokens.addr
  %t.4808 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4807, i64 %t.4808)
  %t.4810 = load i64, ptr %arena.addr
  %t.4811 = load i64, ptr %en.156
  %t.4812 = load i64, ptr %pt.159
  call void @AddChild(i64 %t.4810, i64 %t.4811, i64 %t.4812)
  br label %if.merge.4795
if.merge.4795:
  %t.4814 = load i64, ptr %tokens.addr
  %t.4815 = load i64, ptr %pos.addr
  %r.4816 = call i64 @IsNameTok(i64 %t.4814, i64 %t.4815)
  %ext.4817 = icmp ne i64 %r.4816, 0
  br i1 %ext.4817, label %if.then.4818, label %if.merge.4819
if.then.4818:
  %t.4820 = load i64, ptr %arena.addr
  %t.4821 = load i64, ptr %tokens.addr
  %t.4822 = load i64, ptr %pos.addr
  %r.4823 = call ptr @CurText(i64 %t.4821, i64 %t.4822)
  %t.4824 = load i64, ptr %tokens.addr
  %t.4825 = load i64, ptr %pos.addr
  %r.4826 = call i64 @CurLine(i64 %t.4824, i64 %t.4825)
  %t.4827 = load i64, ptr %tokens.addr
  %t.4828 = load i64, ptr %pos.addr
  %r.4829 = call i64 @CurCol(i64 %t.4827, i64 %t.4828)
  %r.4830 = call i64 @NewNode(i64 %t.4820, ptr @.str.211, ptr %r.4823, i64 %r.4826, i64 %r.4829)
  %pn.160 = alloca i64
  store i64 %r.4830, ptr %pn.160
  %t.4831 = load i64, ptr %tokens.addr
  %t.4832 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4831, i64 %t.4832)
  %t.4834 = load i64, ptr %arena.addr
  %t.4835 = load i64, ptr %en.156
  %t.4836 = load i64, ptr %pn.160
  call void @AddChild(i64 %t.4834, i64 %t.4835, i64 %t.4836)
  br label %if.merge.4819
if.merge.4819:
  %t.4838 = load i64, ptr %tokens.addr
  %t.4839 = load i64, ptr %pos.addr
  %r.4840 = call i64 @MatchPunct(i64 %t.4838, i64 %t.4839, ptr @.str.97)
  %ext.4842 = icmp ne i64 %r.4840, 0
  %t.4841 = xor i1 %ext.4842, true
  br i1 %t.4841, label %if.then.4843, label %if.merge.4844
if.then.4843:
  br label %w.end.4778
dead.4845:
  br label %if.merge.4844
if.merge.4844:
  br label %w.cond.4776
w.end.4778:
  %t.4846 = load i64, ptr %tokens.addr
  %t.4847 = load i64, ptr %pos.addr
  %t.4848 = load i64, ptr %errors.addr
  %r.4849 = call i64 @ExpectPunct(i64 %t.4846, i64 %t.4847, ptr @.str.100, i64 %t.4848, ptr @.str.212)
  %t.4850 = load i64, ptr %tokens.addr
  %t.4851 = load i64, ptr %pos.addr
  %t.4852 = load i64, ptr %errors.addr
  %r.4853 = call i64 @ExpectPunct(i64 %t.4850, i64 %t.4851, ptr @.str.164, i64 %t.4852, ptr @.str.232)
  %t.4854 = load i64, ptr %arena.addr
  %t.4855 = load i64, ptr %root.153
  %t.4856 = load i64, ptr %en.156
  call void @AddChild(i64 %t.4854, i64 %t.4855, i64 %t.4856)
  br label %w.cond.4541
dead.4858:
  br label %if.merge.4703
if.merge.4703:
  %t.4859 = load i64, ptr %tokens.addr
  %t.4860 = load i64, ptr %pos.addr
  %r.4861 = call i64 @IsKw(i64 %t.4859, i64 %t.4860, ptr @.str.22)
  %t.4862 = load i64, ptr %tokens.addr
  %t.4863 = load i64, ptr %pos.addr
  %r.4864 = call i64 @IsKw(i64 %t.4862, i64 %t.4863, ptr @.str.23)
  %ext.4866 = icmp ne i64 %r.4861, 0
  %ext.4867 = icmp ne i64 %r.4864, 0
  %t.4865 = or i1 %ext.4866, %ext.4867
  %t.4868 = load i64, ptr %tokens.addr
  %t.4869 = load i64, ptr %pos.addr
  %r.4870 = call i64 @IsKw(i64 %t.4868, i64 %t.4869, ptr @.str.24)
  %ext.4872 = icmp ne i64 %r.4870, 0
  %t.4871 = or i1 %t.4865, %ext.4872
  br i1 %t.4871, label %if.then.4873, label %if.merge.4874
if.then.4873:
  %t.4875 = load i64, ptr %arena.addr
  %t.4876 = load i64, ptr %root.153
  %t.4877 = load i64, ptr %tokens.addr
  %t.4878 = load i64, ptr %pos.addr
  %t.4879 = load i64, ptr %arena.addr
  %t.4880 = load i64, ptr %errors.addr
  %r.4881 = call i64 @ParseFunctionDecl(i64 %t.4877, i64 %t.4878, i64 %t.4879, i64 %t.4880)
  call void @AddChild(i64 %t.4875, i64 %t.4876, i64 %r.4881)
  br label %w.cond.4541
dead.4883:
  br label %if.merge.4874
if.merge.4874:
  %t.4884 = load i64, ptr %tokens.addr
  %t.4885 = load i64, ptr %pos.addr
  %r.4886 = call i64 @IsPunct(i64 %t.4884, i64 %t.4885, ptr @.str.146)
  %ext.4887 = icmp ne i64 %r.4886, 0
  br i1 %ext.4887, label %if.then.4888, label %if.merge.4889
if.then.4888:
  %t.4890 = load i64, ptr %tokens.addr
  %t.4891 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4890, i64 %t.4891)
  %t.4893 = load i64, ptr %arena.addr
  %t.4894 = load i64, ptr %tokens.addr
  %t.4895 = load i64, ptr %pos.addr
  %r.4896 = call i64 @CurLine(i64 %t.4894, i64 %t.4895)
  %t.4897 = load i64, ptr %tokens.addr
  %t.4898 = load i64, ptr %pos.addr
  %r.4899 = call i64 @CurCol(i64 %t.4897, i64 %t.4898)
  %r.4900 = call i64 @NewNode(i64 %t.4893, ptr @.str.224, ptr @.str.12, i64 %r.4896, i64 %r.4899)
  %attr.161 = alloca i64
  store i64 %r.4900, ptr %attr.161
  %t.4901 = load i64, ptr %tokens.addr
  %t.4902 = load i64, ptr %pos.addr
  %r.4903 = call i64 @IsNameTok(i64 %t.4901, i64 %t.4902)
  %ext.4904 = icmp ne i64 %r.4903, 0
  br i1 %ext.4904, label %if.then.4905, label %if.merge.4906
if.then.4905:
  %t.4907 = load i64, ptr %arena.addr
  %t.4908 = load i64, ptr %tokens.addr
  %t.4909 = load i64, ptr %pos.addr
  %r.4910 = call ptr @CurText(i64 %t.4908, i64 %t.4909)
  %t.4911 = load i64, ptr %tokens.addr
  %t.4912 = load i64, ptr %pos.addr
  %r.4913 = call i64 @CurLine(i64 %t.4911, i64 %t.4912)
  %t.4914 = load i64, ptr %tokens.addr
  %t.4915 = load i64, ptr %pos.addr
  %r.4916 = call i64 @CurCol(i64 %t.4914, i64 %t.4915)
  %r.4917 = call i64 @NewNode(i64 %t.4907, ptr @.str.225, ptr %r.4910, i64 %r.4913, i64 %r.4916)
  %an.162 = alloca i64
  store i64 %r.4917, ptr %an.162
  %t.4918 = load i64, ptr %tokens.addr
  %t.4919 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.4918, i64 %t.4919)
  %t.4921 = load i64, ptr %arena.addr
  %t.4922 = load i64, ptr %attr.161
  %t.4923 = load i64, ptr %an.162
  call void @AddChild(i64 %t.4921, i64 %t.4922, i64 %t.4923)
  br label %if.merge.4906
if.merge.4906:
  %t.4925 = load i64, ptr %tokens.addr
  %t.4926 = load i64, ptr %pos.addr
  %r.4927 = call i64 @MatchPunct(i64 %t.4925, i64 %t.4926, ptr @.str.99)
  %ext.4928 = icmp ne i64 %r.4927, 0
  br i1 %ext.4928, label %if.then.4929, label %if.merge.4930
if.then.4929:
  br label %w.cond.4931
w.cond.4931:
  %t.4934 = load i64, ptr %tokens.addr
  %t.4935 = load i64, ptr %pos.addr
  %r.4936 = call i64 @IsPunct(i64 %t.4934, i64 %t.4935, ptr @.str.100)
  %ext.4938 = icmp ne i64 %r.4936, 0
  %t.4937 = xor i1 %ext.4938, true
  %t.4939 = load i64, ptr %tokens.addr
  %t.4940 = load i64, ptr %pos.addr
  %r.4941 = call i64 @AtEnd(i64 %t.4939, i64 %t.4940)
  %ext.4943 = icmp ne i64 %r.4941, 0
  %t.4942 = xor i1 %ext.4943, true
  %t.4944 = and i1 %t.4937, %t.4942
  br i1 %t.4944, label %w.body.4932, label %w.end.4933
w.body.4932:
  %t.4945 = load i64, ptr %arena.addr
  %t.4946 = load i64, ptr %attr.161
  %t.4947 = load i64, ptr %tokens.addr
  %t.4948 = load i64, ptr %pos.addr
  %t.4949 = load i64, ptr %arena.addr
  %t.4950 = load i64, ptr %errors.addr
  %r.4951 = call i64 @ParseExpression(i64 %t.4947, i64 %t.4948, i64 %t.4949, i64 %t.4950)
  call void @AddChild(i64 %t.4945, i64 %t.4946, i64 %r.4951)
  %t.4953 = load i64, ptr %tokens.addr
  %t.4954 = load i64, ptr %pos.addr
  %r.4955 = call i64 @MatchPunct(i64 %t.4953, i64 %t.4954, ptr @.str.97)
  %ext.4957 = icmp ne i64 %r.4955, 0
  %t.4956 = xor i1 %ext.4957, true
  br i1 %t.4956, label %if.then.4958, label %if.merge.4959
if.then.4958:
  br label %w.end.4933
dead.4960:
  br label %if.merge.4959
if.merge.4959:
  br label %w.cond.4931
w.end.4933:
  %t.4961 = load i64, ptr %tokens.addr
  %t.4962 = load i64, ptr %pos.addr
  %t.4963 = load i64, ptr %errors.addr
  %r.4964 = call i64 @ExpectPunct(i64 %t.4961, i64 %t.4962, ptr @.str.100, i64 %t.4963, ptr @.str.226)
  br label %if.merge.4930
if.merge.4930:
  %t.4965 = load i64, ptr %tokens.addr
  %t.4966 = load i64, ptr %pos.addr
  %t.4967 = load i64, ptr %errors.addr
  %r.4968 = call i64 @ExpectPunct(i64 %t.4965, i64 %t.4966, ptr @.str.148, i64 %t.4967, ptr @.str.227)
  %t.4969 = load i64, ptr %tokens.addr
  %t.4970 = load i64, ptr %pos.addr
  %r.4971 = call i64 @MatchKw(i64 %t.4969, i64 %t.4970, ptr @.str.58)
  %ext.4972 = icmp ne i64 %r.4971, 0
  br i1 %ext.4972, label %if.then.4973, label %if.merge.4974
if.then.4973:
  %t.4975 = load i64, ptr %arena.addr
  %t.4976 = load i64, ptr %tokens.addr
  %t.4977 = load i64, ptr %pos.addr
  %r.4978 = call i64 @CurLine(i64 %t.4976, i64 %t.4977)
  %t.4979 = load i64, ptr %tokens.addr
  %t.4980 = load i64, ptr %pos.addr
  %r.4981 = call i64 @CurCol(i64 %t.4979, i64 %t.4980)
  %r.4982 = call i64 @NewNode(i64 %t.4975, ptr @.str.58, ptr @.str.12, i64 %r.4978, i64 %r.4981)
  %en.163 = alloca i64
  store i64 %r.4982, ptr %en.163
  %t.4983 = load i64, ptr %arena.addr
  %t.4984 = load i64, ptr %en.163
  %t.4985 = load i64, ptr %attr.161
  call void @AddChild(i64 %t.4983, i64 %t.4984, i64 %t.4985)
  %t.4987 = load i64, ptr %tokens.addr
  %t.4988 = load i64, ptr %pos.addr
  %r.4989 = call i64 @IsNameTok(i64 %t.4987, i64 %t.4988)
  %ext.4990 = icmp ne i64 %r.4989, 0
  br i1 %ext.4990, label %if.then.4991, label %if.merge.4992
if.then.4991:
  %t.4993 = load i64, ptr %arena.addr
  %t.4994 = load i64, ptr %tokens.addr
  %t.4995 = load i64, ptr %pos.addr
  %r.4996 = call ptr @CurText(i64 %t.4994, i64 %t.4995)
  %t.4997 = load i64, ptr %tokens.addr
  %t.4998 = load i64, ptr %pos.addr
  %r.4999 = call i64 @CurLine(i64 %t.4997, i64 %t.4998)
  %t.5000 = load i64, ptr %tokens.addr
  %t.5001 = load i64, ptr %pos.addr
  %r.5002 = call i64 @CurCol(i64 %t.5000, i64 %t.5001)
  %r.5003 = call i64 @NewNode(i64 %t.4993, ptr @.str.209, ptr %r.4996, i64 %r.4999, i64 %r.5002)
  %rn.164 = alloca i64
  store i64 %r.5003, ptr %rn.164
  %t.5004 = load i64, ptr %tokens.addr
  %t.5005 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.5004, i64 %t.5005)
  %t.5007 = load i64, ptr %arena.addr
  %t.5008 = load i64, ptr %en.163
  %t.5009 = load i64, ptr %rn.164
  call void @AddChild(i64 %t.5007, i64 %t.5008, i64 %t.5009)
  br label %if.merge.4992
if.merge.4992:
  %t.5011 = load i64, ptr %tokens.addr
  %t.5012 = load i64, ptr %pos.addr
  %r.5013 = call i64 @IsNameTok(i64 %t.5011, i64 %t.5012)
  %ext.5014 = icmp ne i64 %r.5013, 0
  br i1 %ext.5014, label %if.then.5015, label %if.merge.5016
if.then.5015:
  %t.5017 = load i64, ptr %arena.addr
  %t.5018 = load i64, ptr %tokens.addr
  %t.5019 = load i64, ptr %pos.addr
  %r.5020 = call ptr @CurText(i64 %t.5018, i64 %t.5019)
  %t.5021 = load i64, ptr %tokens.addr
  %t.5022 = load i64, ptr %pos.addr
  %r.5023 = call i64 @CurLine(i64 %t.5021, i64 %t.5022)
  %t.5024 = load i64, ptr %tokens.addr
  %t.5025 = load i64, ptr %pos.addr
  %r.5026 = call i64 @CurCol(i64 %t.5024, i64 %t.5025)
  %r.5027 = call i64 @NewNode(i64 %t.5017, ptr @.str.200, ptr %r.5020, i64 %r.5023, i64 %r.5026)
  %dn.165 = alloca i64
  store i64 %r.5027, ptr %dn.165
  %t.5028 = load i64, ptr %tokens.addr
  %t.5029 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.5028, i64 %t.5029)
  %t.5031 = load i64, ptr %arena.addr
  %t.5032 = load i64, ptr %en.163
  %t.5033 = load i64, ptr %dn.165
  call void @AddChild(i64 %t.5031, i64 %t.5032, i64 %t.5033)
  br label %if.merge.5016
if.merge.5016:
  %t.5035 = load i64, ptr %tokens.addr
  %t.5036 = load i64, ptr %pos.addr
  %t.5037 = load i64, ptr %errors.addr
  %r.5038 = call i64 @ExpectPunct(i64 %t.5035, i64 %t.5036, ptr @.str.99, i64 %t.5037, ptr @.str.210)
  %ext.5040 = icmp ne i64 %r.5038, 0
  %t.5039 = xor i1 %ext.5040, true
  br i1 %t.5039, label %if.then.5041, label %if.merge.5042
if.then.5041:
  %t.5043 = load i64, ptr %arena.addr
  %t.5044 = load i64, ptr %root.153
  %t.5045 = load i64, ptr %en.163
  call void @AddChild(i64 %t.5043, i64 %t.5044, i64 %t.5045)
  br label %w.cond.4541
dead.5047:
  br label %if.merge.5042
if.merge.5042:
  br label %w.cond.5048
w.cond.5048:
  %t.5051 = load i64, ptr %tokens.addr
  %t.5052 = load i64, ptr %pos.addr
  %r.5053 = call i64 @IsPunct(i64 %t.5051, i64 %t.5052, ptr @.str.100)
  %ext.5055 = icmp ne i64 %r.5053, 0
  %t.5054 = xor i1 %ext.5055, true
  %t.5056 = load i64, ptr %tokens.addr
  %t.5057 = load i64, ptr %pos.addr
  %r.5058 = call i64 @AtEnd(i64 %t.5056, i64 %t.5057)
  %ext.5060 = icmp ne i64 %r.5058, 0
  %t.5059 = xor i1 %ext.5060, true
  %t.5061 = and i1 %t.5054, %t.5059
  br i1 %t.5061, label %w.body.5049, label %w.end.5050
w.body.5049:
  %t.5062 = load i64, ptr %tokens.addr
  %t.5063 = load i64, ptr %pos.addr
  %r.5064 = call i64 @IsNameTok(i64 %t.5062, i64 %t.5063)
  %ext.5065 = icmp ne i64 %r.5064, 0
  br i1 %ext.5065, label %if.then.5066, label %if.merge.5067
if.then.5066:
  %t.5068 = load i64, ptr %arena.addr
  %t.5069 = load i64, ptr %tokens.addr
  %t.5070 = load i64, ptr %pos.addr
  %r.5071 = call ptr @CurText(i64 %t.5069, i64 %t.5070)
  %t.5072 = load i64, ptr %tokens.addr
  %t.5073 = load i64, ptr %pos.addr
  %r.5074 = call i64 @CurLine(i64 %t.5072, i64 %t.5073)
  %t.5075 = load i64, ptr %tokens.addr
  %t.5076 = load i64, ptr %pos.addr
  %r.5077 = call i64 @CurCol(i64 %t.5075, i64 %t.5076)
  %r.5078 = call i64 @NewNode(i64 %t.5068, ptr @.str.231, ptr %r.5071, i64 %r.5074, i64 %r.5077)
  %pt.166 = alloca i64
  store i64 %r.5078, ptr %pt.166
  %t.5079 = load i64, ptr %tokens.addr
  %t.5080 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.5079, i64 %t.5080)
  %t.5082 = load i64, ptr %arena.addr
  %t.5083 = load i64, ptr %en.163
  %t.5084 = load i64, ptr %pt.166
  call void @AddChild(i64 %t.5082, i64 %t.5083, i64 %t.5084)
  br label %if.merge.5067
if.merge.5067:
  %t.5086 = load i64, ptr %tokens.addr
  %t.5087 = load i64, ptr %pos.addr
  %r.5088 = call i64 @IsNameTok(i64 %t.5086, i64 %t.5087)
  %ext.5089 = icmp ne i64 %r.5088, 0
  br i1 %ext.5089, label %if.then.5090, label %if.merge.5091
if.then.5090:
  %t.5092 = load i64, ptr %arena.addr
  %t.5093 = load i64, ptr %tokens.addr
  %t.5094 = load i64, ptr %pos.addr
  %r.5095 = call ptr @CurText(i64 %t.5093, i64 %t.5094)
  %t.5096 = load i64, ptr %tokens.addr
  %t.5097 = load i64, ptr %pos.addr
  %r.5098 = call i64 @CurLine(i64 %t.5096, i64 %t.5097)
  %t.5099 = load i64, ptr %tokens.addr
  %t.5100 = load i64, ptr %pos.addr
  %r.5101 = call i64 @CurCol(i64 %t.5099, i64 %t.5100)
  %r.5102 = call i64 @NewNode(i64 %t.5092, ptr @.str.211, ptr %r.5095, i64 %r.5098, i64 %r.5101)
  %pn.167 = alloca i64
  store i64 %r.5102, ptr %pn.167
  %t.5103 = load i64, ptr %tokens.addr
  %t.5104 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.5103, i64 %t.5104)
  %t.5106 = load i64, ptr %arena.addr
  %t.5107 = load i64, ptr %en.163
  %t.5108 = load i64, ptr %pn.167
  call void @AddChild(i64 %t.5106, i64 %t.5107, i64 %t.5108)
  br label %if.merge.5091
if.merge.5091:
  %t.5110 = load i64, ptr %tokens.addr
  %t.5111 = load i64, ptr %pos.addr
  %r.5112 = call i64 @MatchPunct(i64 %t.5110, i64 %t.5111, ptr @.str.97)
  %ext.5114 = icmp ne i64 %r.5112, 0
  %t.5113 = xor i1 %ext.5114, true
  br i1 %t.5113, label %if.then.5115, label %if.merge.5116
if.then.5115:
  br label %w.end.5050
dead.5117:
  br label %if.merge.5116
if.merge.5116:
  br label %w.cond.5048
w.end.5050:
  %t.5118 = load i64, ptr %tokens.addr
  %t.5119 = load i64, ptr %pos.addr
  %t.5120 = load i64, ptr %errors.addr
  %r.5121 = call i64 @ExpectPunct(i64 %t.5118, i64 %t.5119, ptr @.str.100, i64 %t.5120, ptr @.str.212)
  %t.5122 = load i64, ptr %tokens.addr
  %t.5123 = load i64, ptr %pos.addr
  %t.5124 = load i64, ptr %errors.addr
  %r.5125 = call i64 @ExpectPunct(i64 %t.5122, i64 %t.5123, ptr @.str.164, i64 %t.5124, ptr @.str.232)
  %t.5126 = load i64, ptr %arena.addr
  %t.5127 = load i64, ptr %root.153
  %t.5128 = load i64, ptr %en.163
  call void @AddChild(i64 %t.5126, i64 %t.5127, i64 %t.5128)
  br label %w.cond.4541
dead.5130:
  br label %if.merge.4974
if.merge.4974:
  %t.5131 = load i64, ptr %errors.addr
  %r.5132 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.5133 = load i64, ptr %tokens.addr
  %t.5134 = load i64, ptr %pos.addr
  %r.5135 = call i64 @CurLine(i64 %t.5133, i64 %t.5134)
  %r.5136 = call ptr @kx_int_str(i64 %r.5135)
  %r.5137 = call ptr @kx_str_cat(ptr %r.5132, ptr %r.5136)
  %r.5138 = call ptr @kx_str_cat(ptr %r.5137, ptr @.str.89)
  %t.5139 = load i64, ptr %tokens.addr
  %t.5140 = load i64, ptr %pos.addr
  %r.5141 = call i64 @CurCol(i64 %t.5139, i64 %t.5140)
  %r.5142 = call ptr @kx_int_str(i64 %r.5141)
  %r.5143 = call ptr @kx_str_cat(ptr %r.5138, ptr %r.5142)
  %r.5144 = call ptr @kx_str_cat(ptr %r.5143, ptr @.str.233)
  %ext.5145 = ptrtoint ptr %r.5144 to i64
  call void @kx_list_add(i64 %t.5131, i64 %ext.5145)
  br label %w.cond.4541
dead.5146:
  br label %if.merge.4889
if.merge.4889:
  %t.5147 = load i64, ptr %errors.addr
  %r.5148 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.5149 = load i64, ptr %tokens.addr
  %t.5150 = load i64, ptr %pos.addr
  %r.5151 = call i64 @CurLine(i64 %t.5149, i64 %t.5150)
  %r.5152 = call ptr @kx_int_str(i64 %r.5151)
  %r.5153 = call ptr @kx_str_cat(ptr %r.5148, ptr %r.5152)
  %r.5154 = call ptr @kx_str_cat(ptr %r.5153, ptr @.str.89)
  %t.5155 = load i64, ptr %tokens.addr
  %t.5156 = load i64, ptr %pos.addr
  %r.5157 = call i64 @CurCol(i64 %t.5155, i64 %t.5156)
  %r.5158 = call ptr @kx_int_str(i64 %r.5157)
  %r.5159 = call ptr @kx_str_cat(ptr %r.5154, ptr %r.5158)
  %r.5160 = call ptr @kx_str_cat(ptr %r.5159, ptr @.str.234)
  %ext.5161 = ptrtoint ptr %r.5160 to i64
  call void @kx_list_add(i64 %t.5147, i64 %ext.5161)
  %t.5162 = load i64, ptr %tokens.addr
  %t.5163 = load i64, ptr %pos.addr
  call void @Advance(i64 %t.5162, i64 %t.5163)
  br label %w.cond.4541
w.end.4543:
  %t.5165 = load i64, ptr %root.153
  ret i64 %t.5165
dead.5166:
  ret i64 0
}

define ptr @Dump(i64 %arena, i64 %i) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %i.addr = alloca i64
  store i64 %i, ptr %i.addr
  %t.5167 = load i64, ptr %arena.addr
  %t.5168 = load i64, ptr %i.addr
  %r.5169 = call i64 @kx_list_get(i64 %t.5167, i64 %t.5168)
  %n.168 = alloca i64
  store i64 %r.5169, ptr %n.168
  %out.169 = alloca ptr
  store ptr @.str.12, ptr %out.169
  %t.5170 = load i64, ptr %n.168
  %kind.170 = alloca i64
  store i64 %t.5170, ptr %kind.170
  %t.5171 = load i64, ptr %kind.170
  %ext.5173 = inttoptr i64 %t.5171 to ptr
  %r.5174 = call i1 @kx_str_eq(ptr %ext.5173, ptr @.str.228)
  br i1 %r.5174, label %if.then.5175, label %if.merge.5176
if.then.5175:
  %s.171 = alloca ptr
  store ptr @.str.235, ptr %s.171
  %t.5177 = load i64, ptr %n.168
  %ext.5179 = inttoptr i64 %t.5177 to ptr
  %r.5180 = call i1 @kx_str_eq(ptr %ext.5179, ptr @.str.12)
  br i1 %r.5180, label %if.then.5181, label %if.merge.5182
if.then.5181:
  %t.5183 = load ptr, ptr %s.171
  %r.5185 = call ptr @kx_str_cat(ptr %t.5183, ptr @.str.236)
  %t.5186 = load i64, ptr %n.168
  %ext.5188 = call ptr @kx_int_str(i64 %t.5186)
  %r.5189 = call ptr @kx_str_cat(ptr %r.5185, ptr %ext.5188)
  store ptr %r.5189, ptr %s.171
  br label %if.merge.5182
if.merge.5182:
  %_ci.172 = alloca i32
  store i32 0, ptr %_ci.172
  br label %for.cond.5190
for.cond.5190:
  %t.5194 = load i32, ptr %_ci.172
  %t.5195 = load i64, ptr %n.168
  %r.5196 = call i64 @kx_list_size(i64 %t.5195)
  %ext.5197 = sext i32 %t.5194 to i64
  %t.5198 = icmp slt i64 %ext.5197, %r.5196
  br i1 %t.5198, label %for.body.5191, label %for.end.5193
for.body.5191:
  %t.5199 = load i64, ptr %n.168
  %t.5200 = load i32, ptr %_ci.172
  %ext.5202 = sext i32 %t.5200 to i64
  %r.5201 = call i64 @kx_list_get(i64 %t.5199, i64 %ext.5202)
  %c.173 = alloca i64
  store i64 %r.5201, ptr %c.173
  %t.5203 = load ptr, ptr %s.171
  %r.5205 = call ptr @kx_str_cat(ptr %t.5203, ptr @.str.8)
  %t.5206 = load i64, ptr %arena.addr
  %t.5207 = load i64, ptr %c.173
  %r.5208 = call ptr @Dump(i64 %t.5206, i64 %t.5207)
  %r.5210 = call ptr @kx_str_cat(ptr %r.5205, ptr %r.5208)
  store ptr %r.5210, ptr %s.171
  br label %for.inc.5192
for.inc.5192:
  %t.5211 = load i32, ptr %_ci.172
  %t.5212 = add i32 %t.5211, 1
  store i32 %t.5212, ptr %_ci.172
  br label %for.cond.5190
for.end.5193:
  %t.5213 = load ptr, ptr %s.171
  %r.5215 = call ptr @kx_str_cat(ptr %t.5213, ptr @.str.100)
  ret ptr %r.5215
dead.5216:
  br label %if.merge.5176
if.merge.5176:
  %t.5217 = load i64, ptr %kind.170
  %ext.5219 = inttoptr i64 %t.5217 to ptr
  %r.5220 = call i1 @kx_str_eq(ptr %ext.5219, ptr @.str.30)
  br i1 %r.5220, label %if.then.5221, label %if.merge.5222
if.then.5221:
  %t.5223 = load i64, ptr %n.168
  %ext.5225 = call ptr @kx_int_str(i64 %t.5223)
  %r.5226 = call ptr @kx_str_cat(ptr @.str.237, ptr %ext.5225)
  %r.5228 = call ptr @kx_str_cat(ptr %r.5226, ptr @.str.238)
  ret ptr %r.5228
dead.5229:
  br label %if.merge.5222
if.merge.5222:
  %t.5230 = load i64, ptr %kind.170
  %ext.5232 = inttoptr i64 %t.5230 to ptr
  %r.5233 = call i1 @kx_str_eq(ptr %ext.5232, ptr @.str.28)
  br i1 %r.5233, label %if.then.5234, label %if.merge.5235
if.then.5234:
  %t.5236 = load i64, ptr %n.168
  %ext.5238 = call ptr @kx_int_str(i64 %t.5236)
  %r.5239 = call ptr @kx_str_cat(ptr @.str.239, ptr %ext.5238)
  %r.5241 = call ptr @kx_str_cat(ptr %r.5239, ptr @.str.100)
  ret ptr %r.5241
dead.5242:
  br label %if.merge.5235
if.merge.5235:
  %t.5243 = load i64, ptr %kind.170
  %ext.5245 = inttoptr i64 %t.5243 to ptr
  %r.5246 = call i1 @kx_str_eq(ptr %ext.5245, ptr @.str.92)
  br i1 %r.5246, label %if.then.5247, label %if.merge.5248
if.then.5247:
  %t.5249 = load i64, ptr %n.168
  %ext.5251 = call ptr @kx_int_str(i64 %t.5249)
  %r.5252 = call ptr @kx_str_cat(ptr @.str.240, ptr %ext.5251)
  %r.5254 = call ptr @kx_str_cat(ptr %r.5252, ptr @.str.100)
  ret ptr %r.5254
dead.5255:
  br label %if.merge.5248
if.merge.5248:
  %t.5256 = load i64, ptr %kind.170
  %ext.5258 = inttoptr i64 %t.5256 to ptr
  %r.5259 = call i1 @kx_str_eq(ptr %ext.5258, ptr @.str.200)
  %t.5260 = load i64, ptr %kind.170
  %ext.5262 = inttoptr i64 %t.5260 to ptr
  %r.5263 = call i1 @kx_str_eq(ptr %ext.5262, ptr @.str.209)
  %t.5264 = or i1 %r.5259, %r.5263
  %t.5265 = load i64, ptr %kind.170
  %ext.5267 = inttoptr i64 %t.5265 to ptr
  %r.5268 = call i1 @kx_str_eq(ptr %ext.5267, ptr @.str.211)
  %t.5269 = or i1 %t.5264, %r.5268
  %t.5270 = load i64, ptr %kind.170
  %ext.5272 = inttoptr i64 %t.5270 to ptr
  %r.5273 = call i1 @kx_str_eq(ptr %ext.5272, ptr @.str.162)
  %t.5274 = or i1 %t.5269, %r.5273
  %t.5275 = load i64, ptr %kind.170
  %ext.5277 = inttoptr i64 %t.5275 to ptr
  %r.5278 = call i1 @kx_str_eq(ptr %ext.5277, ptr @.str.194)
  %t.5279 = or i1 %t.5274, %r.5278
  %t.5280 = load i64, ptr %kind.170
  %ext.5282 = inttoptr i64 %t.5280 to ptr
  %r.5283 = call i1 @kx_str_eq(ptr %ext.5282, ptr @.str.153)
  %t.5284 = or i1 %t.5279, %r.5283
  %t.5285 = load i64, ptr %kind.170
  %ext.5287 = inttoptr i64 %t.5285 to ptr
  %r.5288 = call i1 @kx_str_eq(ptr %ext.5287, ptr @.str.112)
  %t.5289 = or i1 %t.5284, %r.5288
  %t.5290 = load i64, ptr %kind.170
  %ext.5292 = inttoptr i64 %t.5290 to ptr
  %r.5293 = call i1 @kx_str_eq(ptr %ext.5292, ptr @.str.113)
  %t.5294 = or i1 %t.5289, %r.5293
  %t.5295 = load i64, ptr %kind.170
  %ext.5297 = inttoptr i64 %t.5295 to ptr
  %r.5298 = call i1 @kx_str_eq(ptr %ext.5297, ptr @.str.45)
  %t.5299 = or i1 %t.5294, %r.5298
  %t.5300 = load i64, ptr %kind.170
  %ext.5302 = inttoptr i64 %t.5300 to ptr
  %r.5303 = call i1 @kx_str_eq(ptr %ext.5302, ptr @.str.46)
  %t.5304 = or i1 %t.5299, %r.5303
  %t.5305 = load i64, ptr %kind.170
  %ext.5307 = inttoptr i64 %t.5305 to ptr
  %r.5308 = call i1 @kx_str_eq(ptr %ext.5307, ptr @.str.225)
  %t.5309 = or i1 %t.5304, %r.5308
  %t.5310 = load i64, ptr %kind.170
  %ext.5312 = inttoptr i64 %t.5310 to ptr
  %r.5313 = call i1 @kx_str_eq(ptr %ext.5312, ptr @.str.229)
  %t.5314 = or i1 %t.5309, %r.5313
  %t.5315 = load i64, ptr %kind.170
  %ext.5317 = inttoptr i64 %t.5315 to ptr
  %r.5318 = call i1 @kx_str_eq(ptr %ext.5317, ptr @.str.149)
  %t.5319 = or i1 %t.5314, %r.5318
  br i1 %t.5319, label %if.then.5320, label %if.merge.5321
if.then.5320:
  %t.5322 = load i64, ptr %n.168
  %ext.5323 = inttoptr i64 %t.5322 to ptr
  ret ptr %ext.5323
dead.5324:
  br label %if.merge.5321
if.merge.5321:
  %t.5325 = load i64, ptr %kind.170
  %ext.5327 = inttoptr i64 %t.5325 to ptr
  %r.5328 = call i1 @kx_str_eq(ptr %ext.5327, ptr @.str.24)
  %t.5329 = load i64, ptr %kind.170
  %ext.5331 = inttoptr i64 %t.5329 to ptr
  %r.5332 = call i1 @kx_str_eq(ptr %ext.5331, ptr @.str.26)
  %t.5333 = or i1 %r.5328, %r.5332
  br i1 %t.5333, label %if.then.5334, label %if.merge.5335
if.then.5334:
  %t.5336 = load i64, ptr %kind.170
  %ext.5338 = inttoptr i64 %t.5336 to ptr
  %r.5339 = call i1 @kx_str_eq(ptr %ext.5338, ptr @.str.26)
  br i1 %r.5339, label %if.then.5340, label %if.merge.5341
if.then.5340:
  %t.5342 = load i64, ptr %n.168
  %r.5343 = call ptr @TrimFloat(i64 %t.5342)
  %r.5345 = call ptr @kx_str_cat(ptr @.str.241, ptr %r.5343)
  %r.5347 = call ptr @kx_str_cat(ptr %r.5345, ptr @.str.100)
  ret ptr %r.5347
dead.5348:
  br label %if.merge.5341
if.merge.5341:
  %t.5349 = load i64, ptr %n.168
  %ext.5351 = call ptr @kx_int_str(i64 %t.5349)
  %r.5352 = call ptr @kx_str_cat(ptr @.str.242, ptr %ext.5351)
  %r.5354 = call ptr @kx_str_cat(ptr %r.5352, ptr @.str.100)
  ret ptr %r.5354
dead.5355:
  br label %if.merge.5335
if.merge.5335:
  %t.5356 = load i64, ptr %kind.170
  %ext.5358 = inttoptr i64 %t.5356 to ptr
  %r.5359 = call i1 @kx_str_eq(ptr %ext.5358, ptr @.str.104)
  br i1 %r.5359, label %if.then.5360, label %if.merge.5361
if.then.5360:
  %t.5362 = load i64, ptr %n.168
  %ext.5364 = call ptr @kx_int_str(i64 %t.5362)
  %r.5365 = call ptr @kx_str_cat(ptr @.str.108, ptr %ext.5364)
  %r.5367 = call ptr @kx_str_cat(ptr %r.5365, ptr @.str.109)
  ret ptr %r.5367
dead.5368:
  br label %if.merge.5361
if.merge.5361:
  %t.5369 = load i64, ptr %kind.170
  %ext.5371 = inttoptr i64 %t.5369 to ptr
  %r.5372 = call i1 @kx_str_eq(ptr %ext.5371, ptr @.str.16)
  %t.5373 = load i64, ptr %kind.170
  %ext.5375 = inttoptr i64 %t.5373 to ptr
  %r.5376 = call i1 @kx_str_eq(ptr %ext.5375, ptr @.str.19)
  %t.5377 = or i1 %r.5372, %r.5376
  %t.5378 = load i64, ptr %kind.170
  %ext.5380 = inttoptr i64 %t.5378 to ptr
  %r.5381 = call i1 @kx_str_eq(ptr %ext.5380, ptr @.str.18)
  %t.5382 = or i1 %t.5377, %r.5381
  %t.5383 = load i64, ptr %kind.170
  %ext.5385 = inttoptr i64 %t.5383 to ptr
  %r.5386 = call i1 @kx_str_eq(ptr %ext.5385, ptr @.str.20)
  %t.5387 = or i1 %t.5382, %r.5386
  %t.5388 = load i64, ptr %kind.170
  %ext.5390 = inttoptr i64 %t.5388 to ptr
  %r.5391 = call i1 @kx_str_eq(ptr %ext.5390, ptr @.str.21)
  %t.5392 = or i1 %t.5387, %r.5391
  %t.5393 = load i64, ptr %kind.170
  %ext.5395 = inttoptr i64 %t.5393 to ptr
  %r.5396 = call i1 @kx_str_eq(ptr %ext.5395, ptr @.str.17)
  %t.5397 = or i1 %t.5392, %r.5396
  %t.5398 = load i64, ptr %kind.170
  %ext.5400 = inttoptr i64 %t.5398 to ptr
  %r.5401 = call i1 @kx_str_eq(ptr %ext.5400, ptr @.str.208)
  %t.5402 = or i1 %t.5397, %r.5401
  %t.5403 = load i64, ptr %kind.170
  %ext.5405 = inttoptr i64 %t.5403 to ptr
  %r.5406 = call i1 @kx_str_eq(ptr %ext.5405, ptr @.str.58)
  %t.5407 = or i1 %t.5402, %r.5406
  br i1 %t.5407, label %if.then.5408, label %if.merge.5409
if.then.5408:
  %t.5410 = load i64, ptr %arena.addr
  %t.5411 = load i64, ptr %i.addr
  %r.5412 = call ptr @DumpDecl(i64 %t.5410, i64 %t.5411)
  ret ptr %r.5412
dead.5413:
  br label %if.merge.5409
if.merge.5409:
  %t.5414 = load i64, ptr %kind.170
  %ext.5416 = inttoptr i64 %t.5414 to ptr
  %r.5417 = call i1 @kx_str_eq(ptr %ext.5416, ptr @.str.117)
  %t.5418 = load i64, ptr %kind.170
  %ext.5420 = inttoptr i64 %t.5418 to ptr
  %r.5421 = call i1 @kx_str_eq(ptr %ext.5420, ptr @.str.114)
  %t.5422 = or i1 %r.5417, %r.5421
  %t.5423 = load i64, ptr %kind.170
  %ext.5425 = inttoptr i64 %t.5423 to ptr
  %r.5426 = call i1 @kx_str_eq(ptr %ext.5425, ptr @.str.139)
  %t.5427 = or i1 %t.5422, %r.5426
  br i1 %t.5427, label %if.then.5428, label %if.merge.5429
if.then.5428:
  %t.5430 = load i64, ptr %kind.170
  %ext.5432 = call ptr @kx_int_str(i64 %t.5430)
  %r.5433 = call ptr @kx_str_cat(ptr @.str.99, ptr %ext.5432)
  %r.5435 = call ptr @kx_str_cat(ptr %r.5433, ptr @.str.8)
  %t.5436 = load i64, ptr %n.168
  %ext.5438 = call ptr @kx_int_str(i64 %t.5436)
  %r.5439 = call ptr @kx_str_cat(ptr %r.5435, ptr %ext.5438)
  %s.174 = alloca ptr
  store ptr %r.5439, ptr %s.174
  %_ci.175 = alloca i32
  store i32 0, ptr %_ci.175
  br label %for.cond.5440
for.cond.5440:
  %t.5444 = load i32, ptr %_ci.175
  %t.5445 = load i64, ptr %n.168
  %r.5446 = call i64 @kx_list_size(i64 %t.5445)
  %ext.5447 = sext i32 %t.5444 to i64
  %t.5448 = icmp slt i64 %ext.5447, %r.5446
  br i1 %t.5448, label %for.body.5441, label %for.end.5443
for.body.5441:
  %t.5449 = load i64, ptr %n.168
  %t.5450 = load i32, ptr %_ci.175
  %ext.5452 = sext i32 %t.5450 to i64
  %r.5451 = call i64 @kx_list_get(i64 %t.5449, i64 %ext.5452)
  %c.176 = alloca i64
  store i64 %r.5451, ptr %c.176
  %t.5453 = load ptr, ptr %s.174
  %r.5455 = call ptr @kx_str_cat(ptr %t.5453, ptr @.str.8)
  %t.5456 = load i64, ptr %arena.addr
  %t.5457 = load i64, ptr %c.176
  %r.5458 = call ptr @Dump(i64 %t.5456, i64 %t.5457)
  %r.5460 = call ptr @kx_str_cat(ptr %r.5455, ptr %r.5458)
  store ptr %r.5460, ptr %s.174
  br label %for.inc.5442
for.inc.5442:
  %t.5461 = load i32, ptr %_ci.175
  %t.5462 = add i32 %t.5461, 1
  store i32 %t.5462, ptr %_ci.175
  br label %for.cond.5440
for.end.5443:
  %t.5463 = load ptr, ptr %s.174
  %r.5465 = call ptr @kx_str_cat(ptr %t.5463, ptr @.str.100)
  ret ptr %r.5465
dead.5466:
  br label %if.merge.5429
if.merge.5429:
  %t.5467 = load i64, ptr %kind.170
  %ext.5469 = inttoptr i64 %t.5467 to ptr
  %r.5470 = call i1 @kx_str_eq(ptr %ext.5469, ptr @.str.111)
  br i1 %r.5470, label %if.then.5471, label %if.merge.5472
if.then.5471:
  %t.5473 = load i64, ptr %arena.addr
  %t.5474 = load i64, ptr %n.168
  %ext.5476 = sext i32 0 to i64
  %r.5475 = call i64 @kx_list_get(i64 %t.5474, i64 %ext.5476)
  %r.5477 = call ptr @Dump(i64 %t.5473, i64 %r.5475)
  %r.5479 = call ptr @kx_str_cat(ptr @.str.243, ptr %r.5477)
  %r.5481 = call ptr @kx_str_cat(ptr %r.5479, ptr @.str.8)
  %t.5482 = load i64, ptr %n.168
  %ext.5484 = call ptr @kx_int_str(i64 %t.5482)
  %r.5485 = call ptr @kx_str_cat(ptr %r.5481, ptr %ext.5484)
  %r.5487 = call ptr @kx_str_cat(ptr %r.5485, ptr @.str.100)
  ret ptr %r.5487
dead.5488:
  br label %if.merge.5472
if.merge.5472:
  %t.5489 = load i64, ptr %kind.170
  %ext.5491 = inttoptr i64 %t.5489 to ptr
  %r.5492 = call i1 @kx_str_eq(ptr %ext.5491, ptr @.str.103)
  br i1 %r.5492, label %if.then.5493, label %if.merge.5494
if.then.5493:
  %s.177 = alloca ptr
  store ptr @.str.244, ptr %s.177
  %first.178 = alloca i1
  store i1 true, ptr %first.178
  %_ci.179 = alloca i32
  store i32 0, ptr %_ci.179
  br label %for.cond.5495
for.cond.5495:
  %t.5499 = load i32, ptr %_ci.179
  %t.5500 = load i64, ptr %n.168
  %r.5501 = call i64 @kx_list_size(i64 %t.5500)
  %ext.5502 = sext i32 %t.5499 to i64
  %t.5503 = icmp slt i64 %ext.5502, %r.5501
  br i1 %t.5503, label %for.body.5496, label %for.end.5498
for.body.5496:
  %t.5504 = load i64, ptr %n.168
  %t.5505 = load i32, ptr %_ci.179
  %ext.5507 = sext i32 %t.5505 to i64
  %r.5506 = call i64 @kx_list_get(i64 %t.5504, i64 %ext.5507)
  %c.180 = alloca i64
  store i64 %r.5506, ptr %c.180
  %t.5508 = load i64, ptr %arena.addr
  %t.5509 = load i64, ptr %c.180
  %r.5510 = call i64 @kx_list_get(i64 %t.5508, i64 %t.5509)
  %cn.181 = alloca i64
  store i64 %r.5510, ptr %cn.181
  %t.5511 = load i64, ptr %cn.181
  %ext.5513 = inttoptr i64 %t.5511 to ptr
  %r.5514 = call i1 @kx_str_eq(ptr %ext.5513, ptr @.str.104)
  br i1 %r.5514, label %if.then.5515, label %if.else.5517
if.then.5515:
  %t.5518 = load ptr, ptr %s.177
  %r.5520 = call ptr @kx_str_cat(ptr %t.5518, ptr @.str.245)
  %t.5521 = load i64, ptr %cn.181
  %ext.5523 = call ptr @kx_int_str(i64 %t.5521)
  %r.5524 = call ptr @kx_str_cat(ptr %r.5520, ptr %ext.5523)
  %r.5526 = call ptr @kx_str_cat(ptr %r.5524, ptr @.str.109)
  store ptr %r.5526, ptr %s.177
  br label %if.merge.5516
if.else.5517:
  %t.5527 = load ptr, ptr %s.177
  %r.5529 = call ptr @kx_str_cat(ptr %t.5527, ptr @.str.8)
  %t.5530 = load i64, ptr %arena.addr
  %t.5531 = load i64, ptr %c.180
  %r.5532 = call ptr @Dump(i64 %t.5530, i64 %t.5531)
  %r.5534 = call ptr @kx_str_cat(ptr %r.5529, ptr %r.5532)
  store ptr %r.5534, ptr %s.177
  br label %if.merge.5516
if.merge.5516:
  store i1 false, ptr %first.178
  br label %for.inc.5497
for.inc.5497:
  %t.5535 = load i32, ptr %_ci.179
  %t.5536 = add i32 %t.5535, 1
  store i32 %t.5536, ptr %_ci.179
  br label %for.cond.5495
for.end.5498:
  %t.5537 = load ptr, ptr %s.177
  %r.5539 = call ptr @kx_str_cat(ptr %t.5537, ptr @.str.100)
  ret ptr %r.5539
dead.5540:
  br label %if.merge.5494
if.merge.5494:
  %t.5541 = load i64, ptr %kind.170
  %ext.5543 = inttoptr i64 %t.5541 to ptr
  %r.5544 = call i1 @kx_str_eq(ptr %ext.5543, ptr @.str.106)
  br i1 %r.5544, label %if.then.5545, label %if.merge.5546
if.then.5545:
  %t.5547 = load i64, ptr %n.168
  %r.5548 = call i64 @kx_list_size(i64 %t.5547)
  %ext.5549 = sext i32 2 to i64
  %t.5550 = icmp eq i64 %r.5548, %ext.5549
  %t.5551 = load i64, ptr %arena.addr
  %t.5552 = load i64, ptr %n.168
  %ext.5554 = sext i32 0 to i64
  %r.5553 = call i64 @kx_list_get(i64 %t.5552, i64 %ext.5554)
  %r.5555 = call i64 @kx_list_get(i64 %t.5551, i64 %r.5553)
  %ext.5557 = inttoptr i64 %r.5555 to ptr
  %r.5558 = call i1 @kx_str_eq(ptr %ext.5557, ptr @.str.107)
  %t.5559 = and i1 %t.5550, %r.5558
  br i1 %t.5559, label %if.then.5560, label %if.merge.5561
if.then.5560:
  %t.5562 = load i64, ptr %arena.addr
  %t.5563 = load i64, ptr %n.168
  %ext.5565 = sext i32 0 to i64
  %r.5564 = call i64 @kx_list_get(i64 %t.5563, i64 %ext.5565)
  %r.5566 = call i64 @kx_list_get(i64 %t.5562, i64 %r.5564)
  %ext.5568 = call ptr @kx_int_str(i64 %r.5566)
  %r.5569 = call ptr @kx_str_cat(ptr %ext.5568, ptr @.str.89)
  %t.5570 = load i64, ptr %arena.addr
  %t.5571 = load i64, ptr %n.168
  %ext.5573 = sext i32 1 to i64
  %r.5572 = call i64 @kx_list_get(i64 %t.5571, i64 %ext.5573)
  %r.5574 = call ptr @Dump(i64 %t.5570, i64 %r.5572)
  %r.5576 = call ptr @kx_str_cat(ptr %r.5569, ptr %r.5574)
  ret ptr %r.5576
dead.5577:
  br label %if.merge.5561
if.merge.5561:
  %t.5578 = load i64, ptr %arena.addr
  %t.5579 = load i64, ptr %n.168
  %ext.5581 = sext i32 0 to i64
  %r.5580 = call i64 @kx_list_get(i64 %t.5579, i64 %ext.5581)
  %r.5582 = call ptr @Dump(i64 %t.5578, i64 %r.5580)
  ret ptr %r.5582
dead.5583:
  br label %if.merge.5546
if.merge.5546:
  %t.5584 = load i64, ptr %kind.170
  %ext.5586 = inttoptr i64 %t.5584 to ptr
  %r.5587 = call i1 @kx_str_eq(ptr %ext.5586, ptr @.str.155)
  br i1 %r.5587, label %if.then.5588, label %if.merge.5589
if.then.5588:
  %s.182 = alloca ptr
  store ptr @.str.246, ptr %s.182
  %_ci.183 = alloca i32
  store i32 0, ptr %_ci.183
  br label %for.cond.5590
for.cond.5590:
  %t.5594 = load i32, ptr %_ci.183
  %t.5595 = load i64, ptr %n.168
  %r.5596 = call i64 @kx_list_size(i64 %t.5595)
  %ext.5597 = sext i32 %t.5594 to i64
  %t.5598 = icmp slt i64 %ext.5597, %r.5596
  br i1 %t.5598, label %for.body.5591, label %for.end.5593
for.body.5591:
  %t.5599 = load i64, ptr %n.168
  %t.5600 = load i32, ptr %_ci.183
  %ext.5602 = sext i32 %t.5600 to i64
  %r.5601 = call i64 @kx_list_get(i64 %t.5599, i64 %ext.5602)
  %c.184 = alloca i64
  store i64 %r.5601, ptr %c.184
  %t.5603 = load i64, ptr %arena.addr
  %t.5604 = load i64, ptr %c.184
  %r.5605 = call i64 @kx_list_get(i64 %t.5603, i64 %t.5604)
  %cn.185 = alloca i64
  store i64 %r.5605, ptr %cn.185
  %t.5606 = load i64, ptr %cn.185
  %ext.5608 = inttoptr i64 %t.5606 to ptr
  %r.5609 = call i1 @kx_str_eq(ptr %ext.5608, ptr @.str.156)
  br i1 %r.5609, label %if.then.5610, label %if.else.5612
if.then.5610:
  %t.5613 = load ptr, ptr %s.182
  %r.5615 = call ptr @kx_str_cat(ptr %t.5613, ptr @.str.247)
  %t.5616 = load i64, ptr %cn.185
  %ext.5618 = call ptr @kx_int_str(i64 %t.5616)
  %r.5619 = call ptr @kx_str_cat(ptr %r.5615, ptr %ext.5618)
  %r.5621 = call ptr @kx_str_cat(ptr %r.5619, ptr @.str.62)
  store ptr %r.5621, ptr %s.182
  br label %if.merge.5611
if.else.5612:
  %t.5622 = load ptr, ptr %s.182
  %r.5624 = call ptr @kx_str_cat(ptr %t.5622, ptr @.str.248)
  store ptr %r.5624, ptr %s.182
  %t.5625 = load ptr, ptr %s.182
  %t.5626 = load i64, ptr %arena.addr
  %t.5627 = load i64, ptr %cn.185
  %ext.5629 = sext i32 0 to i64
  %r.5628 = call i64 @kx_list_get(i64 %t.5627, i64 %ext.5629)
  %r.5630 = call ptr @Dump(i64 %t.5626, i64 %r.5628)
  %r.5632 = call ptr @kx_str_cat(ptr %t.5625, ptr %r.5630)
  store ptr %r.5632, ptr %s.182
  %t.5633 = load ptr, ptr %s.182
  %r.5635 = call ptr @kx_str_cat(ptr %t.5633, ptr @.str.64)
  store ptr %r.5635, ptr %s.182
  br label %if.merge.5611
if.merge.5611:
  br label %for.inc.5592
for.inc.5592:
  %t.5636 = load i32, ptr %_ci.183
  %t.5637 = add i32 %t.5636, 1
  store i32 %t.5637, ptr %_ci.183
  br label %for.cond.5590
for.end.5593:
  %t.5638 = load ptr, ptr %s.182
  %r.5640 = call ptr @kx_str_cat(ptr %t.5638, ptr @.str.100)
  ret ptr %r.5640
dead.5641:
  br label %if.merge.5589
if.merge.5589:
  %t.5642 = load i64, ptr %kind.170
  %ext.5644 = inttoptr i64 %t.5642 to ptr
  %r.5645 = call i1 @kx_str_eq(ptr %ext.5644, ptr @.str.152)
  br i1 %r.5645, label %if.then.5646, label %if.merge.5647
if.then.5646:
  %s.186 = alloca ptr
  store ptr @.str.99, ptr %s.186
  %_ci.187 = alloca i32
  store i32 0, ptr %_ci.187
  br label %for.cond.5648
for.cond.5648:
  %t.5652 = load i32, ptr %_ci.187
  %t.5653 = load i64, ptr %n.168
  %r.5654 = call i64 @kx_list_size(i64 %t.5653)
  %ext.5655 = sext i32 %t.5652 to i64
  %t.5656 = icmp slt i64 %ext.5655, %r.5654
  br i1 %t.5656, label %for.body.5649, label %for.end.5651
for.body.5649:
  %t.5657 = load i64, ptr %n.168
  %t.5658 = load i32, ptr %_ci.187
  %ext.5660 = sext i32 %t.5658 to i64
  %r.5659 = call i64 @kx_list_get(i64 %t.5657, i64 %ext.5660)
  %c.188 = alloca i64
  store i64 %r.5659, ptr %c.188
  %t.5661 = load i64, ptr %arena.addr
  %t.5662 = load i64, ptr %c.188
  %r.5663 = call i64 @kx_list_get(i64 %t.5661, i64 %t.5662)
  %cn.189 = alloca i64
  store i64 %r.5663, ptr %cn.189
  %t.5664 = load i64, ptr %cn.189
  %ext.5666 = inttoptr i64 %t.5664 to ptr
  %r.5667 = call i1 @kx_str_eq(ptr %ext.5666, ptr @.str.153)
  br i1 %r.5667, label %if.then.5668, label %if.else.5670
if.then.5668:
  %t.5671 = load ptr, ptr %s.186
  %t.5672 = load i64, ptr %cn.189
  %ext.5674 = call ptr @kx_int_str(i64 %t.5672)
  %r.5675 = call ptr @kx_str_cat(ptr %t.5671, ptr %ext.5674)
  store ptr %r.5675, ptr %s.186
  br label %if.merge.5669
if.else.5670:
  %t.5676 = load i64, ptr %cn.189
  %ext.5678 = inttoptr i64 %t.5676 to ptr
  %r.5679 = call i1 @kx_str_eq(ptr %ext.5678, ptr @.str.96)
  br i1 %r.5679, label %if.then.5680, label %if.merge.5681
if.then.5680:
  %t.5682 = load ptr, ptr %s.186
  %r.5684 = call ptr @kx_str_cat(ptr %t.5682, ptr @.str.8)
  %t.5685 = load i64, ptr %cn.189
  %ext.5687 = call ptr @kx_int_str(i64 %t.5685)
  %r.5688 = call ptr @kx_str_cat(ptr %r.5684, ptr %ext.5687)
  %r.5690 = call ptr @kx_str_cat(ptr %r.5688, ptr @.str.94)
  store ptr %r.5690, ptr %s.186
  %t.5691 = load ptr, ptr %s.186
  %t.5692 = load i64, ptr %arena.addr
  %t.5693 = load i64, ptr %cn.189
  %ext.5695 = sext i32 0 to i64
  %r.5694 = call i64 @kx_list_get(i64 %t.5693, i64 %ext.5695)
  %r.5696 = call ptr @Dump(i64 %t.5692, i64 %r.5694)
  %r.5698 = call ptr @kx_str_cat(ptr %t.5691, ptr %r.5696)
  store ptr %r.5698, ptr %s.186
  br label %if.merge.5681
if.merge.5681:
  br label %if.merge.5669
if.merge.5669:
  br label %for.inc.5650
for.inc.5650:
  %t.5699 = load i32, ptr %_ci.187
  %t.5700 = add i32 %t.5699, 1
  store i32 %t.5700, ptr %_ci.187
  br label %for.cond.5648
for.end.5651:
  %t.5701 = load ptr, ptr %s.186
  %r.5703 = call ptr @kx_str_cat(ptr %t.5701, ptr @.str.100)
  ret ptr %r.5703
dead.5704:
  br label %if.merge.5647
if.merge.5647:
  %t.5705 = load i64, ptr %kind.170
  %ext.5707 = inttoptr i64 %t.5705 to ptr
  %r.5708 = call i1 @kx_str_eq(ptr %ext.5707, ptr @.str.40)
  br i1 %r.5708, label %if.then.5709, label %if.merge.5710
if.then.5709:
  %s.190 = alloca ptr
  store ptr @.str.249, ptr %s.190
  %_ci.191 = alloca i32
  store i32 0, ptr %_ci.191
  br label %for.cond.5711
for.cond.5711:
  %t.5715 = load i32, ptr %_ci.191
  %t.5716 = load i64, ptr %n.168
  %r.5717 = call i64 @kx_list_size(i64 %t.5716)
  %ext.5718 = sext i32 %t.5715 to i64
  %t.5719 = icmp slt i64 %ext.5718, %r.5717
  br i1 %t.5719, label %for.body.5712, label %for.end.5714
for.body.5712:
  %t.5720 = load i64, ptr %n.168
  %t.5721 = load i32, ptr %_ci.191
  %ext.5723 = sext i32 %t.5721 to i64
  %r.5722 = call i64 @kx_list_get(i64 %t.5720, i64 %ext.5723)
  %c.192 = alloca i64
  store i64 %r.5722, ptr %c.192
  %t.5724 = load i64, ptr %arena.addr
  %t.5725 = load i64, ptr %c.192
  %r.5726 = call i64 @kx_list_get(i64 %t.5724, i64 %t.5725)
  %cn.193 = alloca i64
  store i64 %r.5726, ptr %cn.193
  %t.5727 = load i64, ptr %cn.193
  %ext.5729 = inttoptr i64 %t.5727 to ptr
  %r.5730 = call i1 @kx_str_eq(ptr %ext.5729, ptr @.str.152)
  br i1 %r.5730, label %if.then.5731, label %if.else.5733
if.then.5731:
  %t.5734 = load ptr, ptr %s.190
  %r.5736 = call ptr @kx_str_cat(ptr %t.5734, ptr @.str.8)
  %t.5737 = load i64, ptr %arena.addr
  %t.5738 = load i64, ptr %c.192
  %r.5739 = call ptr @Dump(i64 %t.5737, i64 %t.5738)
  %r.5741 = call ptr @kx_str_cat(ptr %r.5736, ptr %r.5739)
  store ptr %r.5741, ptr %s.190
  br label %if.merge.5732
if.else.5733:
  %t.5742 = load i64, ptr %cn.193
  %ext.5744 = inttoptr i64 %t.5742 to ptr
  %r.5745 = call i1 @kx_str_eq(ptr %ext.5744, ptr @.str.149)
  br i1 %r.5745, label %if.then.5746, label %if.merge.5747
if.then.5746:
  %t.5748 = load ptr, ptr %s.190
  %r.5750 = call ptr @kx_str_cat(ptr %t.5748, ptr @.str.250)
  %t.5751 = load i64, ptr %cn.193
  %ext.5753 = call ptr @kx_int_str(i64 %t.5751)
  %r.5754 = call ptr @kx_str_cat(ptr %r.5750, ptr %ext.5753)
  store ptr %r.5754, ptr %s.190
  br label %if.merge.5747
if.merge.5747:
  br label %if.merge.5732
if.merge.5732:
  br label %for.inc.5713
for.inc.5713:
  %t.5755 = load i32, ptr %_ci.191
  %t.5756 = add i32 %t.5755, 1
  store i32 %t.5756, ptr %_ci.191
  br label %for.cond.5711
for.end.5714:
  %t.5757 = load ptr, ptr %s.190
  %r.5759 = call ptr @kx_str_cat(ptr %t.5757, ptr @.str.100)
  ret ptr %r.5759
dead.5760:
  br label %if.merge.5710
if.merge.5710:
  %t.5761 = load i64, ptr %kind.170
  %ext.5763 = inttoptr i64 %t.5761 to ptr
  %r.5764 = call i1 @kx_str_eq(ptr %ext.5763, ptr @.str.93)
  br i1 %r.5764, label %if.then.5765, label %if.merge.5766
if.then.5765:
  %t.5767 = load i64, ptr %n.168
  %ext.5769 = call ptr @kx_int_str(i64 %t.5767)
  %r.5770 = call ptr @kx_str_cat(ptr @.str.251, ptr %ext.5769)
  %s.194 = alloca ptr
  store ptr %r.5770, ptr %s.194
  %_ci.195 = alloca i32
  store i32 0, ptr %_ci.195
  br label %for.cond.5771
for.cond.5771:
  %t.5775 = load i32, ptr %_ci.195
  %t.5776 = load i64, ptr %n.168
  %r.5777 = call i64 @kx_list_size(i64 %t.5776)
  %ext.5778 = sext i32 %t.5775 to i64
  %t.5779 = icmp slt i64 %ext.5778, %r.5777
  br i1 %t.5779, label %for.body.5772, label %for.end.5774
for.body.5772:
  %t.5780 = load i64, ptr %n.168
  %t.5781 = load i32, ptr %_ci.195
  %ext.5783 = sext i32 %t.5781 to i64
  %r.5782 = call i64 @kx_list_get(i64 %t.5780, i64 %ext.5783)
  %c.196 = alloca i64
  store i64 %r.5782, ptr %c.196
  %t.5784 = load i64, ptr %arena.addr
  %t.5785 = load i64, ptr %c.196
  %r.5786 = call i64 @kx_list_get(i64 %t.5784, i64 %t.5785)
  %cn.197 = alloca i64
  store i64 %r.5786, ptr %cn.197
  %t.5787 = load ptr, ptr %s.194
  %r.5789 = call ptr @kx_str_cat(ptr %t.5787, ptr @.str.8)
  %t.5790 = load i64, ptr %cn.197
  %ext.5792 = call ptr @kx_int_str(i64 %t.5790)
  %r.5793 = call ptr @kx_str_cat(ptr %r.5789, ptr %ext.5792)
  %r.5795 = call ptr @kx_str_cat(ptr %r.5793, ptr @.str.94)
  store ptr %r.5795, ptr %s.194
  %t.5796 = load ptr, ptr %s.194
  %t.5797 = load i64, ptr %arena.addr
  %t.5798 = load i64, ptr %cn.197
  %ext.5800 = sext i32 0 to i64
  %r.5799 = call i64 @kx_list_get(i64 %t.5798, i64 %ext.5800)
  %r.5801 = call ptr @Dump(i64 %t.5797, i64 %r.5799)
  %r.5803 = call ptr @kx_str_cat(ptr %t.5796, ptr %r.5801)
  store ptr %r.5803, ptr %s.194
  br label %for.inc.5773
for.inc.5773:
  %t.5804 = load i32, ptr %_ci.195
  %t.5805 = add i32 %t.5804, 1
  store i32 %t.5805, ptr %_ci.195
  br label %for.cond.5771
for.end.5774:
  %t.5806 = load ptr, ptr %s.194
  %r.5808 = call ptr @kx_str_cat(ptr %t.5806, ptr @.str.252)
  ret ptr %r.5808
dead.5809:
  br label %if.merge.5766
if.merge.5766:
  %t.5810 = load i64, ptr %kind.170
  %ext.5812 = inttoptr i64 %t.5810 to ptr
  %r.5813 = call i1 @kx_str_eq(ptr %ext.5812, ptr @.str.56)
  br i1 %r.5813, label %if.then.5814, label %if.merge.5815
if.then.5814:
  %s.198 = alloca ptr
  store ptr @.str.99, ptr %s.198
  %_ci.199 = alloca i32
  store i32 0, ptr %_ci.199
  br label %for.cond.5816
for.cond.5816:
  %t.5820 = load i32, ptr %_ci.199
  %t.5821 = load i64, ptr %n.168
  %r.5822 = call i64 @kx_list_size(i64 %t.5821)
  %ext.5823 = sext i32 %t.5820 to i64
  %t.5824 = icmp slt i64 %ext.5823, %r.5822
  br i1 %t.5824, label %for.body.5817, label %for.end.5819
for.body.5817:
  %t.5825 = load i64, ptr %n.168
  %t.5826 = load i32, ptr %_ci.199
  %ext.5828 = sext i32 %t.5826 to i64
  %r.5827 = call i64 @kx_list_get(i64 %t.5825, i64 %ext.5828)
  %c.200 = alloca i64
  store i64 %r.5827, ptr %c.200
  %t.5829 = load i64, ptr %arena.addr
  %t.5830 = load i64, ptr %c.200
  %r.5831 = call i64 @kx_list_get(i64 %t.5829, i64 %t.5830)
  %cn.201 = alloca i64
  store i64 %r.5831, ptr %cn.201
  %t.5832 = load i64, ptr %cn.201
  %ext.5834 = inttoptr i64 %t.5832 to ptr
  %r.5835 = call i1 @kx_str_eq(ptr %ext.5834, ptr @.str.158)
  br i1 %r.5835, label %if.then.5836, label %if.else.5838
if.then.5836:
  %t.5839 = load ptr, ptr %s.198
  %r.5841 = call ptr @kx_str_cat(ptr %t.5839, ptr @.str.8)
  %t.5842 = load i64, ptr %arena.addr
  %t.5843 = load i64, ptr %c.200
  %r.5844 = call ptr @Dump(i64 %t.5842, i64 %t.5843)
  %r.5846 = call ptr @kx_str_cat(ptr %r.5841, ptr %r.5844)
  store ptr %r.5846, ptr %s.198
  br label %if.merge.5837
if.else.5838:
  %t.5847 = load ptr, ptr %s.198
  %r.5849 = call ptr @kx_str_cat(ptr %t.5847, ptr @.str.253)
  %t.5850 = load i64, ptr %arena.addr
  %t.5851 = load i64, ptr %c.200
  %r.5852 = call ptr @Dump(i64 %t.5850, i64 %t.5851)
  %r.5854 = call ptr @kx_str_cat(ptr %r.5849, ptr %r.5852)
  store ptr %r.5854, ptr %s.198
  br label %if.merge.5837
if.merge.5837:
  br label %for.inc.5818
for.inc.5818:
  %t.5855 = load i32, ptr %_ci.199
  %t.5856 = add i32 %t.5855, 1
  store i32 %t.5856, ptr %_ci.199
  br label %for.cond.5816
for.end.5819:
  %t.5857 = load ptr, ptr %s.198
  %r.5859 = call ptr @kx_str_cat(ptr %t.5857, ptr @.str.100)
  ret ptr %r.5859
dead.5860:
  br label %if.merge.5815
if.merge.5815:
  %t.5861 = load i64, ptr %kind.170
  %ext.5863 = call ptr @kx_int_str(i64 %t.5861)
  %r.5864 = call ptr @kx_str_cat(ptr @.str.99, ptr %ext.5863)
  %generic.202 = alloca ptr
  store ptr %r.5864, ptr %generic.202
  %_ci.203 = alloca i32
  store i32 0, ptr %_ci.203
  br label %for.cond.5865
for.cond.5865:
  %t.5869 = load i32, ptr %_ci.203
  %t.5870 = load i64, ptr %n.168
  %r.5871 = call i64 @kx_list_size(i64 %t.5870)
  %ext.5872 = sext i32 %t.5869 to i64
  %t.5873 = icmp slt i64 %ext.5872, %r.5871
  br i1 %t.5873, label %for.body.5866, label %for.end.5868
for.body.5866:
  %t.5874 = load i64, ptr %n.168
  %t.5875 = load i32, ptr %_ci.203
  %ext.5877 = sext i32 %t.5875 to i64
  %r.5876 = call i64 @kx_list_get(i64 %t.5874, i64 %ext.5877)
  %c.204 = alloca i64
  store i64 %r.5876, ptr %c.204
  %t.5878 = load ptr, ptr %generic.202
  %r.5880 = call ptr @kx_str_cat(ptr %t.5878, ptr @.str.8)
  %t.5881 = load i64, ptr %arena.addr
  %t.5882 = load i64, ptr %c.204
  %r.5883 = call ptr @Dump(i64 %t.5881, i64 %t.5882)
  %r.5885 = call ptr @kx_str_cat(ptr %r.5880, ptr %r.5883)
  store ptr %r.5885, ptr %generic.202
  br label %for.inc.5867
for.inc.5867:
  %t.5886 = load i32, ptr %_ci.203
  %t.5887 = add i32 %t.5886, 1
  store i32 %t.5887, ptr %_ci.203
  br label %for.cond.5865
for.end.5868:
  %t.5888 = load ptr, ptr %generic.202
  %r.5890 = call ptr @kx_str_cat(ptr %t.5888, ptr @.str.100)
  ret ptr %r.5890
dead.5891:
  ret ptr null
}

define ptr @DumpDecl(i64 %arena, i64 %i) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %i.addr = alloca i64
  store i64 %i, ptr %i.addr
  %t.5892 = load i64, ptr %arena.addr
  %t.5893 = load i64, ptr %i.addr
  %r.5894 = call i64 @kx_list_get(i64 %t.5892, i64 %t.5893)
  %n.205 = alloca i64
  store i64 %r.5894, ptr %n.205
  %t.5895 = load i64, ptr %n.205
  %ext.5897 = inttoptr i64 %t.5895 to ptr
  %r.5898 = call i1 @kx_str_eq(ptr %ext.5897, ptr @.str.16)
  %t.5899 = load i64, ptr %n.205
  %ext.5901 = inttoptr i64 %t.5899 to ptr
  %r.5902 = call i1 @kx_str_eq(ptr %ext.5901, ptr @.str.19)
  %t.5903 = or i1 %r.5898, %r.5902
  br i1 %t.5903, label %if.then.5904, label %if.merge.5905
if.then.5904:
  %t.5906 = load i64, ptr %n.205
  %ext.5908 = call ptr @kx_int_str(i64 %t.5906)
  %r.5909 = call ptr @kx_str_cat(ptr @.str.99, ptr %ext.5908)
  %r.5911 = call ptr @kx_str_cat(ptr %r.5909, ptr @.str.8)
  %t.5912 = load i64, ptr %arena.addr
  %t.5913 = load i64, ptr %n.205
  %ext.5915 = sext i32 0 to i64
  %r.5914 = call i64 @kx_list_get(i64 %t.5913, i64 %ext.5915)
  %r.5916 = call i64 @kx_list_get(i64 %t.5912, i64 %r.5914)
  %ext.5918 = call ptr @kx_int_str(i64 %r.5916)
  %r.5919 = call ptr @kx_str_cat(ptr %r.5911, ptr %ext.5918)
  %s.206 = alloca ptr
  store ptr %r.5919, ptr %s.206
  %k.207 = alloca i32
  store i32 1, ptr %k.207
  br label %for.cond.5920
for.cond.5920:
  %t.5924 = load i32, ptr %k.207
  %t.5925 = load i64, ptr %n.205
  %r.5926 = call i64 @kx_list_size(i64 %t.5925)
  %ext.5927 = sext i32 %t.5924 to i64
  %t.5928 = icmp slt i64 %ext.5927, %r.5926
  br i1 %t.5928, label %for.body.5921, label %for.end.5923
for.body.5921:
  %t.5929 = load i64, ptr %arena.addr
  %t.5930 = load i64, ptr %n.205
  %t.5931 = load i32, ptr %k.207
  %ext.5933 = sext i32 %t.5931 to i64
  %r.5932 = call i64 @kx_list_get(i64 %t.5930, i64 %ext.5933)
  %r.5934 = call i64 @kx_list_get(i64 %t.5929, i64 %r.5932)
  %cn.208 = alloca i64
  store i64 %r.5934, ptr %cn.208
  %t.5935 = load ptr, ptr %s.206
  %r.5937 = call ptr @kx_str_cat(ptr %t.5935, ptr @.str.254)
  %t.5938 = load i64, ptr %cn.208
  %ext.5940 = call ptr @kx_int_str(i64 %t.5938)
  %r.5941 = call ptr @kx_str_cat(ptr %r.5937, ptr %ext.5940)
  %r.5943 = call ptr @kx_str_cat(ptr %r.5941, ptr @.str.8)
  %t.5944 = load i64, ptr %arena.addr
  %t.5945 = load i64, ptr %cn.208
  %ext.5947 = sext i32 0 to i64
  %r.5946 = call i64 @kx_list_get(i64 %t.5945, i64 %ext.5947)
  %r.5948 = call ptr @Dump(i64 %t.5944, i64 %r.5946)
  %r.5950 = call ptr @kx_str_cat(ptr %r.5943, ptr %r.5948)
  %r.5952 = call ptr @kx_str_cat(ptr %r.5950, ptr @.str.100)
  store ptr %r.5952, ptr %s.206
  br label %for.inc.5922
for.inc.5922:
  %t.5953 = load i32, ptr %k.207
  %t.5954 = add i32 %t.5953, 1
  store i32 %t.5954, ptr %k.207
  br label %for.cond.5920
for.end.5923:
  %t.5955 = load ptr, ptr %s.206
  %r.5957 = call ptr @kx_str_cat(ptr %t.5955, ptr @.str.100)
  ret ptr %r.5957
dead.5958:
  br label %if.merge.5905
if.merge.5905:
  %t.5959 = load i64, ptr %n.205
  %ext.5961 = inttoptr i64 %t.5959 to ptr
  %r.5962 = call i1 @kx_str_eq(ptr %ext.5961, ptr @.str.18)
  br i1 %r.5962, label %if.then.5963, label %if.merge.5964
if.then.5963:
  %t.5965 = load i64, ptr %arena.addr
  %t.5966 = load i64, ptr %n.205
  %ext.5968 = sext i32 0 to i64
  %r.5967 = call i64 @kx_list_get(i64 %t.5966, i64 %ext.5968)
  %r.5969 = call i64 @kx_list_get(i64 %t.5965, i64 %r.5967)
  %ext.5971 = call ptr @kx_int_str(i64 %r.5969)
  %r.5972 = call ptr @kx_str_cat(ptr @.str.255, ptr %ext.5971)
  %s.209 = alloca ptr
  store ptr %r.5972, ptr %s.209
  %t.5973 = load i64, ptr %n.205
  %r.5974 = call i64 @kx_list_size(i64 %t.5973)
  %ext.5975 = sext i32 1 to i64
  %t.5976 = icmp sgt i64 %r.5974, %ext.5975
  br i1 %t.5976, label %if.then.5977, label %if.merge.5978
if.then.5977:
  %t.5979 = load ptr, ptr %s.209
  %r.5981 = call ptr @kx_str_cat(ptr %t.5979, ptr @.str.256)
  %t.5982 = load i64, ptr %arena.addr
  %t.5983 = load i64, ptr %n.205
  %ext.5985 = sext i32 1 to i64
  %r.5984 = call i64 @kx_list_get(i64 %t.5983, i64 %ext.5985)
  %r.5986 = call i64 @kx_list_get(i64 %t.5982, i64 %r.5984)
  %ext.5988 = call ptr @kx_int_str(i64 %r.5986)
  %r.5989 = call ptr @kx_str_cat(ptr %r.5981, ptr %ext.5988)
  store ptr %r.5989, ptr %s.209
  br label %if.merge.5978
if.merge.5978:
  %t.5990 = load ptr, ptr %s.209
  %r.5992 = call ptr @kx_str_cat(ptr %t.5990, ptr @.str.100)
  ret ptr %r.5992
dead.5993:
  br label %if.merge.5964
if.merge.5964:
  %t.5994 = load i64, ptr %n.205
  %ext.5996 = inttoptr i64 %t.5994 to ptr
  %r.5997 = call i1 @kx_str_eq(ptr %ext.5996, ptr @.str.20)
  br i1 %r.5997, label %if.then.5998, label %if.merge.5999
if.then.5998:
  %t.6000 = load i64, ptr %arena.addr
  %t.6001 = load i64, ptr %n.205
  %ext.6003 = sext i32 0 to i64
  %r.6002 = call i64 @kx_list_get(i64 %t.6001, i64 %ext.6003)
  %r.6004 = call i64 @kx_list_get(i64 %t.6000, i64 %r.6002)
  %ext.6006 = call ptr @kx_int_str(i64 %r.6004)
  %r.6007 = call ptr @kx_str_cat(ptr @.str.257, ptr %ext.6006)
  %s.210 = alloca ptr
  store ptr %r.6007, ptr %s.210
  %k.211 = alloca i32
  store i32 1, ptr %k.211
  br label %for.cond.6008
for.cond.6008:
  %t.6012 = load i32, ptr %k.211
  %t.6013 = load i64, ptr %n.205
  %r.6014 = call i64 @kx_list_size(i64 %t.6013)
  %ext.6015 = sext i32 %t.6012 to i64
  %t.6016 = icmp slt i64 %ext.6015, %r.6014
  br i1 %t.6016, label %for.body.6009, label %for.end.6011
for.body.6009:
  %t.6017 = load ptr, ptr %s.210
  %r.6019 = call ptr @kx_str_cat(ptr %t.6017, ptr @.str.8)
  %t.6020 = load i64, ptr %arena.addr
  %t.6021 = load i64, ptr %n.205
  %t.6022 = load i32, ptr %k.211
  %ext.6024 = sext i32 %t.6022 to i64
  %r.6023 = call i64 @kx_list_get(i64 %t.6021, i64 %ext.6024)
  %r.6025 = call i64 @kx_list_get(i64 %t.6020, i64 %r.6023)
  %ext.6027 = call ptr @kx_int_str(i64 %r.6025)
  %r.6028 = call ptr @kx_str_cat(ptr %r.6019, ptr %ext.6027)
  store ptr %r.6028, ptr %s.210
  br label %for.inc.6010
for.inc.6010:
  %t.6029 = load i32, ptr %k.211
  %t.6030 = add i32 %t.6029, 1
  store i32 %t.6030, ptr %k.211
  br label %for.cond.6008
for.end.6011:
  %t.6031 = load ptr, ptr %s.210
  %r.6033 = call ptr @kx_str_cat(ptr %t.6031, ptr @.str.100)
  ret ptr %r.6033
dead.6034:
  br label %if.merge.5999
if.merge.5999:
  %t.6035 = load i64, ptr %n.205
  %ext.6037 = inttoptr i64 %t.6035 to ptr
  %r.6038 = call i1 @kx_str_eq(ptr %ext.6037, ptr @.str.21)
  br i1 %r.6038, label %if.then.6039, label %if.merge.6040
if.then.6039:
  %t.6041 = load i64, ptr %arena.addr
  %t.6042 = load i64, ptr %n.205
  %ext.6044 = sext i32 0 to i64
  %r.6043 = call i64 @kx_list_get(i64 %t.6042, i64 %ext.6044)
  %r.6045 = call i64 @kx_list_get(i64 %t.6041, i64 %r.6043)
  %ext.6047 = call ptr @kx_int_str(i64 %r.6045)
  %r.6048 = call ptr @kx_str_cat(ptr @.str.258, ptr %ext.6047)
  %r.6050 = call ptr @kx_str_cat(ptr %r.6048, ptr @.str.8)
  %t.6051 = load i64, ptr %arena.addr
  %t.6052 = load i64, ptr %n.205
  %ext.6054 = sext i32 1 to i64
  %r.6053 = call i64 @kx_list_get(i64 %t.6052, i64 %ext.6054)
  %r.6055 = call ptr @Dump(i64 %t.6051, i64 %r.6053)
  %r.6057 = call ptr @kx_str_cat(ptr %r.6050, ptr %r.6055)
  %r.6059 = call ptr @kx_str_cat(ptr %r.6057, ptr @.str.100)
  ret ptr %r.6059
dead.6060:
  br label %if.merge.6040
if.merge.6040:
  %t.6061 = load i64, ptr %n.205
  %ext.6063 = inttoptr i64 %t.6061 to ptr
  %r.6064 = call i1 @kx_str_eq(ptr %ext.6063, ptr @.str.17)
  br i1 %r.6064, label %if.then.6065, label %if.merge.6066
if.then.6065:
  %t.6067 = load i64, ptr %arena.addr
  %t.6068 = load i64, ptr %n.205
  %ext.6070 = sext i32 0 to i64
  %r.6069 = call i64 @kx_list_get(i64 %t.6068, i64 %ext.6070)
  %r.6071 = call i64 @kx_list_get(i64 %t.6067, i64 %r.6069)
  %ext.6073 = call ptr @kx_int_str(i64 %r.6071)
  %r.6074 = call ptr @kx_str_cat(ptr @.str.259, ptr %ext.6073)
  %s.212 = alloca ptr
  store ptr %r.6074, ptr %s.212
  %_ci.213 = alloca i32
  store i32 0, ptr %_ci.213
  br label %for.cond.6075
for.cond.6075:
  %t.6079 = load i32, ptr %_ci.213
  %t.6080 = load i64, ptr %n.205
  %r.6081 = call i64 @kx_list_size(i64 %t.6080)
  %ext.6082 = sext i32 %t.6079 to i64
  %t.6083 = icmp slt i64 %ext.6082, %r.6081
  br i1 %t.6083, label %for.body.6076, label %for.end.6078
for.body.6076:
  %t.6084 = load i64, ptr %n.205
  %t.6085 = load i32, ptr %_ci.213
  %ext.6087 = sext i32 %t.6085 to i64
  %r.6086 = call i64 @kx_list_get(i64 %t.6084, i64 %ext.6087)
  %c.214 = alloca i64
  store i64 %r.6086, ptr %c.214
  %t.6088 = load i64, ptr %arena.addr
  %t.6089 = load i64, ptr %c.214
  %r.6090 = call i64 @kx_list_get(i64 %t.6088, i64 %t.6089)
  %cn.215 = alloca i64
  store i64 %r.6090, ptr %cn.215
  %t.6091 = load i64, ptr %cn.215
  %ext.6093 = inttoptr i64 %t.6091 to ptr
  %r.6094 = call i1 @kx_str_eq(ptr %ext.6093, ptr @.str.45)
  br i1 %r.6094, label %if.then.6095, label %if.else.6097
if.then.6095:
  %t.6098 = load ptr, ptr %s.212
  %r.6100 = call ptr @kx_str_cat(ptr %t.6098, ptr @.str.260)
  %t.6101 = load i64, ptr %cn.215
  %ext.6103 = call ptr @kx_int_str(i64 %t.6101)
  %r.6104 = call ptr @kx_str_cat(ptr %r.6100, ptr %ext.6103)
  store ptr %r.6104, ptr %s.212
  br label %if.merge.6096
if.else.6097:
  %t.6105 = load i64, ptr %cn.215
  %ext.6107 = inttoptr i64 %t.6105 to ptr
  %r.6108 = call i1 @kx_str_eq(ptr %ext.6107, ptr @.str.46)
  br i1 %r.6108, label %if.then.6109, label %if.else.6111
if.then.6109:
  %t.6112 = load ptr, ptr %s.212
  %r.6114 = call ptr @kx_str_cat(ptr %t.6112, ptr @.str.261)
  %t.6115 = load i64, ptr %cn.215
  %ext.6117 = call ptr @kx_int_str(i64 %t.6115)
  %r.6118 = call ptr @kx_str_cat(ptr %r.6114, ptr %ext.6117)
  store ptr %r.6118, ptr %s.212
  br label %if.merge.6110
if.else.6111:
  %t.6119 = load i64, ptr %cn.215
  %ext.6121 = inttoptr i64 %t.6119 to ptr
  %r.6122 = call i1 @kx_str_eq(ptr %ext.6121, ptr @.str.224)
  br i1 %r.6122, label %if.then.6123, label %if.else.6125
if.then.6123:
  %t.6126 = load ptr, ptr %s.212
  %r.6128 = call ptr @kx_str_cat(ptr %t.6126, ptr @.str.262)
  %t.6129 = load i64, ptr %arena.addr
  %t.6130 = load i64, ptr %n.205
  %ext.6132 = sext i32 0 to i64
  %r.6131 = call i64 @kx_list_get(i64 %t.6130, i64 %ext.6132)
  %r.6133 = call i64 @kx_list_get(i64 %t.6129, i64 %r.6131)
  %ext.6135 = call ptr @kx_int_str(i64 %r.6133)
  %r.6136 = call ptr @kx_str_cat(ptr %r.6128, ptr %ext.6135)
  store ptr %r.6136, ptr %s.212
  %t.6137 = load i64, ptr %cn.215
  %r.6138 = call i64 @kx_list_size(i64 %t.6137)
  %ext.6139 = sext i32 1 to i64
  %t.6140 = icmp sgt i64 %r.6138, %ext.6139
  br i1 %t.6140, label %if.then.6141, label %if.merge.6142
if.then.6141:
  %t.6143 = load ptr, ptr %s.212
  %r.6145 = call ptr @kx_str_cat(ptr %t.6143, ptr @.str.8)
  store ptr %r.6145, ptr %s.212
  %k.216 = alloca i32
  store i32 1, ptr %k.216
  br label %for.cond.6146
for.cond.6146:
  %t.6150 = load i32, ptr %k.216
  %t.6151 = load i64, ptr %cn.215
  %r.6152 = call i64 @kx_list_size(i64 %t.6151)
  %ext.6153 = sext i32 %t.6150 to i64
  %t.6154 = icmp slt i64 %ext.6153, %r.6152
  br i1 %t.6154, label %for.body.6147, label %for.end.6149
for.body.6147:
  %t.6155 = load i32, ptr %k.216
  %t.6156 = icmp sgt i32 %t.6155, 1
  br i1 %t.6156, label %if.then.6157, label %if.merge.6158
if.then.6157:
  %t.6159 = load ptr, ptr %s.212
  %r.6161 = call ptr @kx_str_cat(ptr %t.6159, ptr @.str.8)
  store ptr %r.6161, ptr %s.212
  br label %if.merge.6158
if.merge.6158:
  %t.6162 = load ptr, ptr %s.212
  %t.6163 = load i64, ptr %arena.addr
  %t.6164 = load i64, ptr %cn.215
  %t.6165 = load i32, ptr %k.216
  %ext.6167 = sext i32 %t.6165 to i64
  %r.6166 = call i64 @kx_list_get(i64 %t.6164, i64 %ext.6167)
  %r.6168 = call ptr @Dump(i64 %t.6163, i64 %r.6166)
  %r.6170 = call ptr @kx_str_cat(ptr %t.6162, ptr %r.6168)
  store ptr %r.6170, ptr %s.212
  br label %for.inc.6148
for.inc.6148:
  %t.6171 = load i32, ptr %k.216
  %t.6172 = add i32 %t.6171, 1
  store i32 %t.6172, ptr %k.216
  br label %for.cond.6146
for.end.6149:
  br label %if.merge.6142
if.merge.6142:
  %t.6173 = load ptr, ptr %s.212
  %r.6175 = call ptr @kx_str_cat(ptr %t.6173, ptr @.str.148)
  store ptr %r.6175, ptr %s.212
  br label %if.merge.6124
if.else.6125:
  %t.6176 = load i64, ptr %cn.215
  %ext.6178 = inttoptr i64 %t.6176 to ptr
  %r.6179 = call i1 @kx_str_eq(ptr %ext.6178, ptr @.str.158)
  br i1 %r.6179, label %if.then.6180, label %if.merge.6181
if.then.6180:
  %t.6182 = load ptr, ptr %s.212
  %r.6184 = call ptr @kx_str_cat(ptr %t.6182, ptr @.str.8)
  %t.6185 = load i64, ptr %arena.addr
  %t.6186 = load i64, ptr %c.214
  %r.6187 = call ptr @Dump(i64 %t.6185, i64 %t.6186)
  %r.6189 = call ptr @kx_str_cat(ptr %r.6184, ptr %r.6187)
  store ptr %r.6189, ptr %s.212
  br label %if.merge.6181
if.merge.6181:
  br label %if.merge.6124
if.merge.6124:
  br label %if.merge.6110
if.merge.6110:
  br label %if.merge.6096
if.merge.6096:
  br label %for.inc.6077
for.inc.6077:
  %t.6190 = load i32, ptr %_ci.213
  %t.6191 = add i32 %t.6190, 1
  store i32 %t.6191, ptr %_ci.213
  br label %for.cond.6075
for.end.6078:
  %t.6192 = load ptr, ptr %s.212
  %r.6194 = call ptr @kx_str_cat(ptr %t.6192, ptr @.str.100)
  ret ptr %r.6194
dead.6195:
  br label %if.merge.6066
if.merge.6066:
  %t.6196 = load i64, ptr %n.205
  %ext.6198 = inttoptr i64 %t.6196 to ptr
  %r.6199 = call i1 @kx_str_eq(ptr %ext.6198, ptr @.str.208)
  %t.6200 = load i64, ptr %n.205
  %ext.6202 = inttoptr i64 %t.6200 to ptr
  %r.6203 = call i1 @kx_str_eq(ptr %ext.6202, ptr @.str.58)
  %t.6204 = or i1 %r.6199, %r.6203
  br i1 %t.6204, label %if.then.6205, label %if.merge.6206
if.then.6205:
  %t.6207 = load i64, ptr %arena.addr
  %t.6208 = load i64, ptr %n.205
  %ext.6210 = sext i32 0 to i64
  %r.6209 = call i64 @kx_list_get(i64 %t.6208, i64 %ext.6210)
  %r.6211 = call i64 @kx_list_get(i64 %t.6207, i64 %r.6209)
  %ext.6213 = call ptr @kx_int_str(i64 %r.6211)
  %r.6214 = call ptr @kx_str_cat(ptr @.str.263, ptr %ext.6213)
  %r.6216 = call ptr @kx_str_cat(ptr %r.6214, ptr @.str.8)
  %t.6217 = load i64, ptr %arena.addr
  %t.6218 = load i64, ptr %n.205
  %ext.6220 = sext i32 1 to i64
  %r.6219 = call i64 @kx_list_get(i64 %t.6218, i64 %ext.6220)
  %r.6221 = call i64 @kx_list_get(i64 %t.6217, i64 %r.6219)
  %ext.6223 = call ptr @kx_int_str(i64 %r.6221)
  %r.6224 = call ptr @kx_str_cat(ptr %r.6216, ptr %ext.6223)
  %s.217 = alloca ptr
  store ptr %r.6224, ptr %s.217
  %k.218 = alloca i32
  store i32 2, ptr %k.218
  br label %for.cond.6225
for.cond.6225:
  %t.6229 = load i32, ptr %k.218
  %t.6230 = load i64, ptr %n.205
  %r.6231 = call i64 @kx_list_size(i64 %t.6230)
  %ext.6232 = sext i32 %t.6229 to i64
  %t.6233 = icmp slt i64 %ext.6232, %r.6231
  br i1 %t.6233, label %for.body.6226, label %for.end.6228
for.body.6226:
  %t.6234 = load i64, ptr %arena.addr
  %t.6235 = load i64, ptr %n.205
  %t.6236 = load i32, ptr %k.218
  %ext.6238 = sext i32 %t.6236 to i64
  %r.6237 = call i64 @kx_list_get(i64 %t.6235, i64 %ext.6238)
  %r.6239 = call i64 @kx_list_get(i64 %t.6234, i64 %r.6237)
  %cn.219 = alloca i64
  store i64 %r.6239, ptr %cn.219
  %t.6240 = load i64, ptr %cn.219
  %ext.6242 = inttoptr i64 %t.6240 to ptr
  %r.6243 = call i1 @kx_str_eq(ptr %ext.6242, ptr @.str.211)
  br i1 %r.6243, label %if.then.6244, label %if.else.6246
if.then.6244:
  %t.6247 = load ptr, ptr %s.217
  %r.6249 = call ptr @kx_str_cat(ptr %t.6247, ptr @.str.8)
  %t.6250 = load i64, ptr %cn.219
  %ext.6252 = call ptr @kx_int_str(i64 %t.6250)
  %r.6253 = call ptr @kx_str_cat(ptr %r.6249, ptr %ext.6252)
  store ptr %r.6253, ptr %s.217
  br label %if.merge.6245
if.else.6246:
  %t.6254 = load i64, ptr %cn.219
  %ext.6256 = inttoptr i64 %t.6254 to ptr
  %r.6257 = call i1 @kx_str_eq(ptr %ext.6256, ptr @.str.158)
  br i1 %r.6257, label %if.then.6258, label %if.merge.6259
if.then.6258:
  %t.6260 = load ptr, ptr %s.217
  %r.6262 = call ptr @kx_str_cat(ptr %t.6260, ptr @.str.8)
  %t.6263 = load i64, ptr %arena.addr
  %t.6264 = load i64, ptr %n.205
  %t.6265 = load i32, ptr %k.218
  %ext.6267 = sext i32 %t.6265 to i64
  %r.6266 = call i64 @kx_list_get(i64 %t.6264, i64 %ext.6267)
  %r.6268 = call ptr @Dump(i64 %t.6263, i64 %r.6266)
  %r.6270 = call ptr @kx_str_cat(ptr %r.6262, ptr %r.6268)
  store ptr %r.6270, ptr %s.217
  br label %if.merge.6259
if.merge.6259:
  br label %if.merge.6245
if.merge.6245:
  br label %for.inc.6227
for.inc.6227:
  %t.6271 = load i32, ptr %k.218
  %t.6272 = add i32 %t.6271, 1
  store i32 %t.6272, ptr %k.218
  br label %for.cond.6225
for.end.6228:
  %t.6273 = load ptr, ptr %s.217
  %r.6275 = call ptr @kx_str_cat(ptr %t.6273, ptr @.str.100)
  ret ptr %r.6275
dead.6276:
  br label %if.merge.6206
if.merge.6206:
  %t.6277 = load i64, ptr %n.205
  %ext.6279 = call ptr @kx_int_str(i64 %t.6277)
  %r.6280 = call ptr @kx_str_cat(ptr @.str.99, ptr %ext.6279)
  %generic.220 = alloca ptr
  store ptr %r.6280, ptr %generic.220
  %_ci.221 = alloca i32
  store i32 0, ptr %_ci.221
  br label %for.cond.6281
for.cond.6281:
  %t.6285 = load i32, ptr %_ci.221
  %t.6286 = load i64, ptr %n.205
  %r.6287 = call i64 @kx_list_size(i64 %t.6286)
  %ext.6288 = sext i32 %t.6285 to i64
  %t.6289 = icmp slt i64 %ext.6288, %r.6287
  br i1 %t.6289, label %for.body.6282, label %for.end.6284
for.body.6282:
  %t.6290 = load i64, ptr %n.205
  %t.6291 = load i32, ptr %_ci.221
  %ext.6293 = sext i32 %t.6291 to i64
  %r.6292 = call i64 @kx_list_get(i64 %t.6290, i64 %ext.6293)
  %c.222 = alloca i64
  store i64 %r.6292, ptr %c.222
  %t.6294 = load ptr, ptr %generic.220
  %r.6296 = call ptr @kx_str_cat(ptr %t.6294, ptr @.str.8)
  %t.6297 = load i64, ptr %arena.addr
  %t.6298 = load i64, ptr %c.222
  %r.6299 = call ptr @Dump(i64 %t.6297, i64 %t.6298)
  %r.6301 = call ptr @kx_str_cat(ptr %r.6296, ptr %r.6299)
  store ptr %r.6301, ptr %generic.220
  br label %for.inc.6283
for.inc.6283:
  %t.6302 = load i32, ptr %_ci.221
  %t.6303 = add i32 %t.6302, 1
  store i32 %t.6303, ptr %_ci.221
  br label %for.cond.6281
for.end.6284:
  %t.6304 = load ptr, ptr %generic.220
  %r.6306 = call ptr @kx_str_cat(ptr %t.6304, ptr @.str.100)
  ret ptr %r.6306
dead.6307:
  ret ptr null
}

define i64 @Child(i64 %arena, i64 %n, i64 %i) {
entry:
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %n.addr = alloca i64
  store i64 %n, ptr %n.addr
  %i.addr = alloca i64
  store i64 %i, ptr %i.addr
  %t.6308 = load i32, ptr %i.addr
  %t.6309 = icmp slt i32 %t.6308, 0
  %t.6310 = load i32, ptr %i.addr
  %t.6311 = load i64, ptr %n.addr
  %r.6312 = call i64 @kx_struct_get(i64 %t.6311, i32 4)
  %r.6313 = call i64 @kx_list_size(i64 %r.6312)
  %ext.6314 = sext i32 %t.6310 to i64
  %t.6315 = icmp sge i64 %ext.6314, %r.6313
  %t.6316 = or i1 %t.6309, %t.6315
  br i1 %t.6316, label %if.then.6317, label %if.merge.6318
if.then.6317:
  %t.6319 = load i64, ptr %n.addr
  %r.6320 = call i64 @kx_struct_get(i64 %t.6319, i32 0)
  %field.6321 = inttoptr i64 %r.6320 to ptr
  %r.6323 = call ptr @kx_str_cat(ptr @.str.264, ptr %field.6321)
  %r.6325 = call ptr @kx_str_cat(ptr %r.6323, ptr @.str.97)
  %t.6326 = load i32, ptr %i.addr
  %ext.6327 = sext i32 %t.6326 to i64
  %r.6328 = call ptr @kx_int_str(i64 %ext.6327)
  %r.6330 = call ptr @kx_str_cat(ptr %r.6325, ptr %r.6328)
  %r.6332 = call ptr @kx_str_cat(ptr %r.6330, ptr @.str.265)
  %t.6333 = load i64, ptr %n.addr
  %r.6334 = call i64 @kx_struct_get(i64 %t.6333, i32 4)
  %r.6335 = call i64 @kx_list_size(i64 %r.6334)
  %r.6336 = call ptr @kx_int_str(i64 %r.6335)
  %r.6338 = call ptr @kx_str_cat(ptr %r.6332, ptr %r.6336)
  %r.6340 = call ptr @kx_str_cat(ptr %r.6338, ptr @.str.266)
  %t.6341 = load i64, ptr %n.addr
  %r.6342 = call i64 @kx_struct_get(i64 %t.6341, i32 2)
  %r.6343 = call ptr @kx_int_str(i64 %r.6342)
  %r.6345 = call ptr @kx_str_cat(ptr %r.6340, ptr %r.6343)
  %r.6346 = call i64 @kx_println(ptr %r.6345)
  %r.6347 = call i64 @kx_struct_new(i32 5)
  %ext.6348 = ptrtoint ptr @.str.267 to i64
  call void @kx_struct_set(i64 %r.6347, i32 0, i64 %ext.6348)
  %ext.6349 = ptrtoint ptr @.str.12 to i64
  call void @kx_struct_set(i64 %r.6347, i32 1, i64 %ext.6349)
  %ext.6350 = sext i32 0 to i64
  call void @kx_struct_set(i64 %r.6347, i32 2, i64 %ext.6350)
  %ext.6351 = sext i32 0 to i64
  call void @kx_struct_set(i64 %r.6347, i32 3, i64 %ext.6351)
  %r.6352 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.6347, i32 4, i64 %r.6352)
  ret i64 %r.6347
dead.6353:
  br label %if.merge.6318
if.merge.6318:
  %t.6354 = load i64, ptr %arena.addr
  %t.6355 = load i64, ptr %n.addr
  %r.6356 = call i64 @kx_struct_get(i64 %t.6355, i32 4)
  %t.6357 = load i32, ptr %i.addr
  %ext.6359 = sext i32 %t.6357 to i64
  %r.6358 = call i64 @kx_list_get(i64 %r.6356, i64 %ext.6359)
  %r.6360 = call i64 @kx_list_get(i64 %t.6354, i64 %r.6358)
  ret i64 %r.6360
dead.6361:
  ret i64 0
}

define i64 @SplitFirst(ptr %s, ptr %sep) {
entry:
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %sep.addr = alloca ptr
  store ptr %sep, ptr %sep.addr
  %r.6362 = call i64 @kx_list_new(i32 0)
  %out.223 = alloca i64
  store i64 %r.6362, ptr %out.223
  %i.224 = alloca i32
  store i32 0, ptr %i.224
  br label %for.cond.6363
for.cond.6363:
  %t.6367 = load i32, ptr %i.224
  %t.6368 = load ptr, ptr %s.addr
  %r.6369 = call i64 @kx_str_len(ptr %t.6368)
  %ext.6370 = sext i32 %t.6367 to i64
  %t.6371 = icmp slt i64 %ext.6370, %r.6369
  br i1 %t.6371, label %for.body.6364, label %for.end.6366
for.body.6364:
  %t.6372 = load ptr, ptr %s.addr
  %t.6373 = load i32, ptr %i.224
  %ext.6374 = sext i32 %t.6373 to i64
  %ext.6375 = sext i32 1 to i64
  %r.6376 = call ptr @kx_str_substr(ptr %t.6372, i64 %ext.6374, i64 %ext.6375)
  %t.6377 = load ptr, ptr %sep.addr
  %r.6379 = call i1 @kx_str_eq(ptr %r.6376, ptr %t.6377)
  br i1 %r.6379, label %if.then.6380, label %if.merge.6381
if.then.6380:
  %t.6382 = load i64, ptr %out.223
  %t.6383 = load ptr, ptr %s.addr
  %ext.6384 = sext i32 0 to i64
  %t.6385 = load i32, ptr %i.224
  %ext.6386 = sext i32 %t.6385 to i64
  %r.6387 = call ptr @kx_str_substr(ptr %t.6383, i64 %ext.6384, i64 %ext.6386)
  %ext.6388 = ptrtoint ptr %r.6387 to i64
  call void @kx_list_add(i64 %t.6382, i64 %ext.6388)
  %t.6389 = load i64, ptr %out.223
  %t.6390 = load ptr, ptr %s.addr
  %t.6391 = load i32, ptr %i.224
  %t.6392 = add i32 %t.6391, 1
  %ext.6393 = sext i32 %t.6392 to i64
  %t.6394 = load ptr, ptr %s.addr
  %r.6395 = call i64 @kx_str_len(ptr %t.6394)
  %t.6396 = load i32, ptr %i.224
  %ext.6397 = sext i32 %t.6396 to i64
  %t.6398 = sub i64 %r.6395, %ext.6397
  %ext.6399 = sext i32 1 to i64
  %t.6400 = sub i64 %t.6398, %ext.6399
  %r.6401 = call ptr @kx_str_substr(ptr %t.6390, i64 %ext.6393, i64 %t.6400)
  %ext.6402 = ptrtoint ptr %r.6401 to i64
  call void @kx_list_add(i64 %t.6389, i64 %ext.6402)
  %t.6403 = load i64, ptr %out.223
  ret i64 %t.6403
dead.6404:
  br label %if.merge.6381
if.merge.6381:
  br label %for.inc.6365
for.inc.6365:
  %t.6405 = load i32, ptr %i.224
  %t.6406 = add i32 %t.6405, 1
  store i32 %t.6406, ptr %i.224
  br label %for.cond.6363
for.end.6366:
  %t.6407 = load i64, ptr %out.223
  %t.6408 = load ptr, ptr %s.addr
  %ext.6409 = ptrtoint ptr %t.6408 to i64
  call void @kx_list_add(i64 %t.6407, i64 %ext.6409)
  %t.6410 = load i64, ptr %out.223
  %ext.6411 = ptrtoint ptr @.str.12 to i64
  call void @kx_list_add(i64 %t.6410, i64 %ext.6411)
  %t.6412 = load i64, ptr %out.223
  ret i64 %t.6412
dead.6413:
  ret i64 0
}

define ptr @IntStr(i64 %v) {
entry:
  %v.addr = alloca i64
  store i64 %v, ptr %v.addr
  %t.6414 = load i64, ptr %v.addr
  %ext.6415 = sext i32 0 to i64
  %t.6416 = icmp eq i64 %t.6414, %ext.6415
  br i1 %t.6416, label %if.then.6417, label %if.merge.6418
if.then.6417:
  ret ptr @.str.1
dead.6419:
  br label %if.merge.6418
if.merge.6418:
  %neg.225 = alloca i1
  store i1 false, ptr %neg.225
  %t.6420 = load i64, ptr %v.addr
  %ext.6421 = sext i32 0 to i64
  %t.6422 = icmp slt i64 %t.6420, %ext.6421
  br i1 %t.6422, label %if.then.6423, label %if.merge.6424
if.then.6423:
  store i1 true, ptr %neg.225
  %t.6425 = load i64, ptr %v.addr
  %t.6426 = sub i64 0, %t.6425
  store i64 %t.6426, ptr %v.addr
  br label %if.merge.6424
if.merge.6424:
  %d.226 = alloca ptr
  store ptr @.str.12, ptr %d.226
  br label %w.cond.6427
w.cond.6427:
  %t.6430 = load i64, ptr %v.addr
  %ext.6431 = sext i32 0 to i64
  %t.6432 = icmp sgt i64 %t.6430, %ext.6431
  br i1 %t.6432, label %w.body.6428, label %w.end.6429
w.body.6428:
  %t.6433 = load i64, ptr %v.addr
  %ext.6434 = sext i32 10 to i64
  %t.6435 = srem i64 %t.6433, %ext.6434
  %ext.6436 = sext i32 1 to i64
  %r.6437 = call ptr @kx_str_substr(ptr @.str.268, i64 %t.6435, i64 %ext.6436)
  %t.6438 = load ptr, ptr %d.226
  %r.6440 = call ptr @kx_str_cat(ptr %r.6437, ptr %t.6438)
  store ptr %r.6440, ptr %d.226
  %t.6441 = load i64, ptr %v.addr
  %ext.6442 = sext i32 10 to i64
  %t.6443 = sdiv i64 %t.6441, %ext.6442
  store i64 %t.6443, ptr %v.addr
  br label %w.cond.6427
w.end.6429:
  %t.6444 = load i1, ptr %neg.225
  br i1 %t.6444, label %if.then.6445, label %if.merge.6446
if.then.6445:
  %t.6447 = load ptr, ptr %d.226
  %r.6449 = call ptr @kx_str_cat(ptr @.str.87, ptr %t.6447)
  store ptr %r.6449, ptr %d.226
  br label %if.merge.6446
if.merge.6446:
  %t.6450 = load ptr, ptr %d.226
  ret ptr %t.6450
dead.6451:
  ret ptr null
}

define i64 @XType(ptr %val) {
entry:
  %val.addr = alloca ptr
  store ptr %val, ptr %val.addr
  %t.6452 = load ptr, ptr %val.addr
  %r.6453 = call i64 @SplitFirst(ptr %t.6452, ptr @.str.8)
  %sp.227 = alloca i64
  store i64 %r.6453, ptr %sp.227
  %t.6454 = load i64, ptr %sp.227
  %ext.6456 = sext i32 0 to i64
  %r.6455 = call i64 @kx_list_get(i64 %t.6454, i64 %ext.6456)
  ret i64 %r.6455
dead.6457:
  ret i64 0
}

define i64 @XVal(ptr %val) {
entry:
  %val.addr = alloca ptr
  store ptr %val, ptr %val.addr
  %t.6458 = load ptr, ptr %val.addr
  %r.6459 = call i64 @SplitFirst(ptr %t.6458, ptr @.str.8)
  %sp.228 = alloca i64
  store i64 %r.6459, ptr %sp.228
  %t.6460 = load i64, ptr %sp.228
  %ext.6462 = sext i32 1 to i64
  %r.6461 = call i64 @kx_list_get(i64 %t.6460, i64 %ext.6462)
  ret i64 %r.6461
dead.6463:
  ret i64 0
}

define ptr @ToI64(i64 %g, ptr %val) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %val.addr = alloca ptr
  store ptr %val, ptr %val.addr
  %t.6464 = load ptr, ptr %val.addr
  %r.6465 = call i64 @XType(ptr %t.6464)
  %ext.6467 = inttoptr i64 %r.6465 to ptr
  %r.6468 = call i1 @kx_str_eq(ptr %ext.6467, ptr @.str.269)
  br i1 %r.6468, label %if.then.6469, label %if.merge.6470
if.then.6469:
  %t.6471 = load ptr, ptr %val.addr
  %r.6472 = call i64 @XVal(ptr %t.6471)
  %ext.6473 = inttoptr i64 %r.6472 to ptr
  ret ptr %ext.6473
dead.6474:
  br label %if.merge.6470
if.merge.6470:
  %t.6475 = load i64, ptr %g.addr
  %t.6476 = load i64, ptr %g.addr
  %ext.6478 = sext i32 0 to i64
  %r.6477 = call i64 @kx_list_get(i64 %t.6476, i64 %ext.6478)
  %ext.6479 = sext i32 1 to i64
  %t.6480 = add i64 %r.6477, %ext.6479
  %ext.6481 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.6475, i64 %ext.6481, i64 %t.6480)
  %t.6482 = load i64, ptr %g.addr
  %ext.6484 = sext i32 0 to i64
  %r.6483 = call i64 @kx_list_get(i64 %t.6482, i64 %ext.6484)
  %r.6485 = call ptr @kx_int_str(i64 %r.6483)
  %r.6487 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.6485)
  %ext.229 = alloca ptr
  store ptr %r.6487, ptr %ext.229
  %t.6488 = load ptr, ptr %val.addr
  %r.6489 = call i64 @XType(ptr %t.6488)
  %ext.6491 = inttoptr i64 %r.6489 to ptr
  %r.6492 = call i1 @kx_str_eq(ptr %ext.6491, ptr @.str.271)
  br i1 %r.6492, label %if.then.6493, label %if.else.6495
if.then.6493:
  %t.6496 = load i64, ptr %g.addr
  %t.6497 = load ptr, ptr %ext.229
  %r.6499 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6497)
  %r.6501 = call ptr @kx_str_cat(ptr %r.6499, ptr @.str.273)
  %t.6502 = load ptr, ptr %val.addr
  %r.6503 = call i64 @XVal(ptr %t.6502)
  %ext.6505 = call ptr @kx_int_str(i64 %r.6503)
  %r.6506 = call ptr @kx_str_cat(ptr %r.6501, ptr %ext.6505)
  %r.6508 = call ptr @kx_str_cat(ptr %r.6506, ptr @.str.274)
  %r.6509 = call i64 @Emit(i64 %t.6496, ptr %r.6508)
  br label %if.merge.6494
if.else.6495:
  %t.6510 = load i64, ptr %g.addr
  %t.6511 = load ptr, ptr %ext.229
  %r.6513 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6511)
  %r.6515 = call ptr @kx_str_cat(ptr %r.6513, ptr @.str.275)
  %t.6516 = load ptr, ptr %val.addr
  %r.6517 = call i64 @XVal(ptr %t.6516)
  %ext.6519 = call ptr @kx_int_str(i64 %r.6517)
  %r.6520 = call ptr @kx_str_cat(ptr %r.6515, ptr %ext.6519)
  %r.6522 = call ptr @kx_str_cat(ptr %r.6520, ptr @.str.274)
  %r.6523 = call i64 @Emit(i64 %t.6510, ptr %r.6522)
  br label %if.merge.6494
if.merge.6494:
  %t.6524 = load ptr, ptr %ext.229
  ret ptr %t.6524
dead.6525:
  ret ptr null
}

define ptr @Coerce(i64 %g, ptr %val, ptr %want) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %val.addr = alloca ptr
  store ptr %val, ptr %val.addr
  %want.addr = alloca ptr
  store ptr %want, ptr %want.addr
  %t.6526 = load ptr, ptr %val.addr
  %r.6527 = call i64 @XType(ptr %t.6526)
  %have.230 = alloca i64
  store i64 %r.6527, ptr %have.230
  %t.6528 = load ptr, ptr %val.addr
  %r.6529 = call i64 @XVal(ptr %t.6528)
  %value.231 = alloca i64
  store i64 %r.6529, ptr %value.231
  %t.6530 = load i64, ptr %have.230
  %t.6531 = load ptr, ptr %want.addr
  %ext.6533 = inttoptr i64 %t.6530 to ptr
  %r.6534 = call i1 @kx_str_eq(ptr %ext.6533, ptr %t.6531)
  br i1 %r.6534, label %if.then.6535, label %if.merge.6536
if.then.6535:
  %t.6537 = load i64, ptr %value.231
  %ext.6538 = inttoptr i64 %t.6537 to ptr
  ret ptr %ext.6538
dead.6539:
  br label %if.merge.6536
if.merge.6536:
  %t.6540 = load i64, ptr %g.addr
  %t.6541 = load i64, ptr %g.addr
  %ext.6543 = sext i32 0 to i64
  %r.6542 = call i64 @kx_list_get(i64 %t.6541, i64 %ext.6543)
  %ext.6544 = sext i32 1 to i64
  %t.6545 = add i64 %r.6542, %ext.6544
  %ext.6546 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.6540, i64 %ext.6546, i64 %t.6545)
  %t.6547 = load i64, ptr %g.addr
  %ext.6549 = sext i32 0 to i64
  %r.6548 = call i64 @kx_list_get(i64 %t.6547, i64 %ext.6549)
  %r.6550 = call ptr @kx_int_str(i64 %r.6548)
  %r.6552 = call ptr @kx_str_cat(ptr @.str.276, ptr %r.6550)
  %cast.232 = alloca ptr
  store ptr %r.6552, ptr %cast.232
  %t.6553 = load ptr, ptr %want.addr
  %r.6555 = call i1 @kx_str_eq(ptr %t.6553, ptr @.str.271)
  %t.6556 = load i64, ptr %have.230
  %ext.6558 = inttoptr i64 %t.6556 to ptr
  %r.6559 = call i1 @kx_str_eq(ptr %ext.6558, ptr @.str.269)
  %t.6560 = and i1 %r.6555, %r.6559
  br i1 %t.6560, label %if.then.6561, label %if.merge.6562
if.then.6561:
  %t.6563 = load i64, ptr %g.addr
  %t.6564 = load ptr, ptr %cast.232
  %r.6566 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6564)
  %r.6568 = call ptr @kx_str_cat(ptr %r.6566, ptr @.str.277)
  %t.6569 = load i64, ptr %value.231
  %ext.6571 = call ptr @kx_int_str(i64 %t.6569)
  %r.6572 = call ptr @kx_str_cat(ptr %r.6568, ptr %ext.6571)
  %r.6574 = call ptr @kx_str_cat(ptr %r.6572, ptr @.str.278)
  %r.6575 = call i64 @Emit(i64 %t.6563, ptr %r.6574)
  %t.6576 = load ptr, ptr %cast.232
  ret ptr %t.6576
dead.6577:
  br label %if.merge.6562
if.merge.6562:
  %t.6578 = load ptr, ptr %want.addr
  %r.6580 = call i1 @kx_str_eq(ptr %t.6578, ptr @.str.269)
  %t.6581 = load i64, ptr %have.230
  %ext.6583 = inttoptr i64 %t.6581 to ptr
  %r.6584 = call i1 @kx_str_eq(ptr %ext.6583, ptr @.str.271)
  %t.6585 = and i1 %r.6580, %r.6584
  br i1 %t.6585, label %if.then.6586, label %if.merge.6587
if.then.6586:
  %t.6588 = load i64, ptr %g.addr
  %t.6589 = load ptr, ptr %cast.232
  %r.6591 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6589)
  %r.6593 = call ptr @kx_str_cat(ptr %r.6591, ptr @.str.273)
  %t.6594 = load i64, ptr %value.231
  %ext.6596 = call ptr @kx_int_str(i64 %t.6594)
  %r.6597 = call ptr @kx_str_cat(ptr %r.6593, ptr %ext.6596)
  %r.6599 = call ptr @kx_str_cat(ptr %r.6597, ptr @.str.274)
  %r.6600 = call i64 @Emit(i64 %t.6588, ptr %r.6599)
  %t.6601 = load ptr, ptr %cast.232
  ret ptr %t.6601
dead.6602:
  br label %if.merge.6587
if.merge.6587:
  %t.6603 = load ptr, ptr %want.addr
  %r.6605 = call i1 @kx_str_eq(ptr %t.6603, ptr @.str.269)
  %t.6606 = load i64, ptr %have.230
  %ext.6608 = inttoptr i64 %t.6606 to ptr
  %r.6609 = call i1 @kx_str_eq(ptr %ext.6608, ptr @.str.279)
  %t.6610 = and i1 %r.6605, %r.6609
  br i1 %t.6610, label %if.then.6611, label %if.merge.6612
if.then.6611:
  %t.6613 = load i64, ptr %g.addr
  %t.6614 = load ptr, ptr %cast.232
  %r.6616 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6614)
  %r.6618 = call ptr @kx_str_cat(ptr %r.6616, ptr @.str.275)
  %t.6619 = load i64, ptr %value.231
  %ext.6621 = call ptr @kx_int_str(i64 %t.6619)
  %r.6622 = call ptr @kx_str_cat(ptr %r.6618, ptr %ext.6621)
  %r.6624 = call ptr @kx_str_cat(ptr %r.6622, ptr @.str.274)
  %r.6625 = call i64 @Emit(i64 %t.6613, ptr %r.6624)
  %t.6626 = load ptr, ptr %cast.232
  ret ptr %t.6626
dead.6627:
  br label %if.merge.6612
if.merge.6612:
  %t.6628 = load ptr, ptr %want.addr
  %r.6630 = call i1 @kx_str_eq(ptr %t.6628, ptr @.str.280)
  %t.6631 = load i64, ptr %have.230
  %ext.6633 = inttoptr i64 %t.6631 to ptr
  %r.6634 = call i1 @kx_str_eq(ptr %ext.6633, ptr @.str.269)
  %t.6635 = and i1 %r.6630, %r.6634
  br i1 %t.6635, label %if.then.6636, label %if.merge.6637
if.then.6636:
  %t.6638 = load i64, ptr %g.addr
  %t.6639 = load ptr, ptr %cast.232
  %r.6641 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6639)
  %r.6643 = call ptr @kx_str_cat(ptr %r.6641, ptr @.str.281)
  %t.6644 = load i64, ptr %value.231
  %ext.6646 = call ptr @kx_int_str(i64 %t.6644)
  %r.6647 = call ptr @kx_str_cat(ptr %r.6643, ptr %ext.6646)
  %r.6649 = call ptr @kx_str_cat(ptr %r.6647, ptr @.str.282)
  %r.6650 = call i64 @Emit(i64 %t.6638, ptr %r.6649)
  %t.6651 = load ptr, ptr %cast.232
  ret ptr %t.6651
dead.6652:
  br label %if.merge.6637
if.merge.6637:
  %t.6653 = load ptr, ptr %want.addr
  %r.6655 = call i1 @kx_str_eq(ptr %t.6653, ptr @.str.269)
  %t.6656 = load i64, ptr %have.230
  %ext.6658 = inttoptr i64 %t.6656 to ptr
  %r.6659 = call i1 @kx_str_eq(ptr %ext.6658, ptr @.str.280)
  %t.6660 = and i1 %r.6655, %r.6659
  br i1 %t.6660, label %if.then.6661, label %if.merge.6662
if.then.6661:
  %t.6663 = load i64, ptr %g.addr
  %t.6664 = load ptr, ptr %cast.232
  %r.6666 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.6664)
  %r.6668 = call ptr @kx_str_cat(ptr %r.6666, ptr @.str.283)
  %t.6669 = load i64, ptr %value.231
  %ext.6671 = call ptr @kx_int_str(i64 %t.6669)
  %r.6672 = call ptr @kx_str_cat(ptr %r.6668, ptr %ext.6671)
  %r.6674 = call ptr @kx_str_cat(ptr %r.6672, ptr @.str.274)
  %r.6675 = call i64 @Emit(i64 %t.6663, ptr %r.6674)
  %t.6676 = load ptr, ptr %cast.232
  ret ptr %t.6676
dead.6677:
  br label %if.merge.6662
if.merge.6662:
  %t.6678 = load i64, ptr %value.231
  %ext.6679 = inttoptr i64 %t.6678 to ptr
  ret ptr %ext.6679
dead.6680:
  ret ptr null
}

define ptr @KxType(ptr %t) {
entry:
  %t.addr = alloca ptr
  store ptr %t, ptr %t.addr
  %t.6681 = load ptr, ptr %t.addr
  %r.6683 = call i1 @kx_str_eq(ptr %t.6681, ptr @.str.24)
  %t.6684 = load ptr, ptr %t.addr
  %r.6686 = call i1 @kx_str_eq(ptr %t.6684, ptr @.str.25)
  %t.6687 = or i1 %r.6683, %r.6686
  br i1 %t.6687, label %if.then.6688, label %if.merge.6689
if.then.6688:
  ret ptr @.str.269
dead.6690:
  br label %if.merge.6689
if.merge.6689:
  %t.6691 = load ptr, ptr %t.addr
  %r.6693 = call i1 @kx_str_eq(ptr %t.6691, ptr @.str.23)
  br i1 %r.6693, label %if.then.6694, label %if.merge.6695
if.then.6694:
  ret ptr @.str.23
dead.6696:
  br label %if.merge.6695
if.merge.6695:
  %t.6697 = load ptr, ptr %t.addr
  %r.6699 = call i1 @kx_str_eq(ptr %t.6697, ptr @.str.30)
  %t.6700 = load ptr, ptr %t.addr
  %r.6702 = call i1 @kx_str_eq(ptr %t.6700, ptr @.str.271)
  %t.6703 = or i1 %r.6699, %r.6702
  br i1 %t.6703, label %if.then.6704, label %if.merge.6705
if.then.6704:
  ret ptr @.str.271
dead.6706:
  br label %if.merge.6705
if.merge.6705:
  %t.6707 = load ptr, ptr %t.addr
  %r.6709 = call i1 @kx_str_eq(ptr %t.6707, ptr @.str.28)
  br i1 %r.6709, label %if.then.6710, label %if.merge.6711
if.then.6710:
  ret ptr @.str.280
dead.6712:
  br label %if.merge.6711
if.merge.6711:
  %t.6713 = load ptr, ptr %t.addr
  %r.6715 = call i1 @kx_str_eq(ptr %t.6713, ptr @.str.26)
  %t.6716 = load ptr, ptr %t.addr
  %r.6718 = call i1 @kx_str_eq(ptr %t.6716, ptr @.str.27)
  %t.6719 = or i1 %r.6715, %r.6718
  br i1 %t.6719, label %if.then.6720, label %if.merge.6721
if.then.6720:
  ret ptr @.str.27
dead.6722:
  br label %if.merge.6721
if.merge.6721:
  ret ptr @.str.269
dead.6723:
  ret ptr null
}

define i64 @SplitAll(ptr %s, ptr %sep) {
entry:
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %sep.addr = alloca ptr
  store ptr %sep, ptr %sep.addr
  %r.6724 = call i64 @kx_list_new(i32 0)
  %out.233 = alloca i64
  store i64 %r.6724, ptr %out.233
  %cur.234 = alloca ptr
  store ptr @.str.12, ptr %cur.234
  %i.235 = alloca i32
  store i32 0, ptr %i.235
  br label %for.cond.6725
for.cond.6725:
  %t.6729 = load i32, ptr %i.235
  %t.6730 = load ptr, ptr %s.addr
  %r.6731 = call i64 @kx_str_len(ptr %t.6730)
  %ext.6732 = sext i32 %t.6729 to i64
  %t.6733 = icmp slt i64 %ext.6732, %r.6731
  br i1 %t.6733, label %for.body.6726, label %for.end.6728
for.body.6726:
  %t.6734 = load ptr, ptr %s.addr
  %t.6735 = load i32, ptr %i.235
  %ext.6736 = sext i32 %t.6735 to i64
  %ext.6737 = sext i32 1 to i64
  %r.6738 = call ptr @kx_str_substr(ptr %t.6734, i64 %ext.6736, i64 %ext.6737)
  %c.236 = alloca ptr
  store ptr %r.6738, ptr %c.236
  %t.6739 = load ptr, ptr %c.236
  %t.6740 = load ptr, ptr %sep.addr
  %r.6742 = call i1 @kx_str_eq(ptr %t.6739, ptr %t.6740)
  br i1 %r.6742, label %if.then.6743, label %if.else.6745
if.then.6743:
  %t.6746 = load i64, ptr %out.233
  %t.6747 = load ptr, ptr %cur.234
  %ext.6748 = ptrtoint ptr %t.6747 to i64
  call void @kx_list_add(i64 %t.6746, i64 %ext.6748)
  store ptr @.str.12, ptr %cur.234
  br label %if.merge.6744
if.else.6745:
  %t.6749 = load ptr, ptr %cur.234
  %t.6750 = load ptr, ptr %c.236
  %r.6752 = call ptr @kx_str_cat(ptr %t.6749, ptr %t.6750)
  store ptr %r.6752, ptr %cur.234
  br label %if.merge.6744
if.merge.6744:
  br label %for.inc.6727
for.inc.6727:
  %t.6753 = load i32, ptr %i.235
  %t.6754 = add i32 %t.6753, 1
  store i32 %t.6754, ptr %i.235
  br label %for.cond.6725
for.end.6728:
  %t.6755 = load i64, ptr %out.233
  %t.6756 = load ptr, ptr %cur.234
  %ext.6757 = ptrtoint ptr %t.6756 to i64
  call void @kx_list_add(i64 %t.6755, i64 %ext.6757)
  %t.6758 = load i64, ptr %out.233
  ret i64 %t.6758
dead.6759:
  ret i64 0
}

define ptr @JoinParts(i64 %parts, ptr %sep) {
entry:
  %parts.addr = alloca i64
  store i64 %parts, ptr %parts.addr
  %sep.addr = alloca ptr
  store ptr %sep, ptr %sep.addr
  %out.237 = alloca ptr
  store ptr @.str.12, ptr %out.237
  %i.238 = alloca i32
  store i32 0, ptr %i.238
  br label %for.cond.6760
for.cond.6760:
  %t.6764 = load i32, ptr %i.238
  %t.6765 = load i64, ptr %parts.addr
  %r.6766 = call i64 @kx_list_size(i64 %t.6765)
  %ext.6767 = sext i32 %t.6764 to i64
  %t.6768 = icmp slt i64 %ext.6767, %r.6766
  br i1 %t.6768, label %for.body.6761, label %for.end.6763
for.body.6761:
  %t.6769 = load i32, ptr %i.238
  %t.6770 = icmp sgt i32 %t.6769, 0
  br i1 %t.6770, label %if.then.6771, label %if.merge.6772
if.then.6771:
  %t.6773 = load ptr, ptr %out.237
  %t.6774 = load ptr, ptr %sep.addr
  %r.6776 = call ptr @kx_str_cat(ptr %t.6773, ptr %t.6774)
  store ptr %r.6776, ptr %out.237
  br label %if.merge.6772
if.merge.6772:
  %t.6777 = load ptr, ptr %out.237
  %t.6778 = load i64, ptr %parts.addr
  %t.6779 = load i32, ptr %i.238
  %ext.6781 = sext i32 %t.6779 to i64
  %r.6780 = call i64 @kx_list_get(i64 %t.6778, i64 %ext.6781)
  %ext.6783 = call ptr @kx_int_str(i64 %r.6780)
  %r.6784 = call ptr @kx_str_cat(ptr %t.6777, ptr %ext.6783)
  store ptr %r.6784, ptr %out.237
  br label %for.inc.6762
for.inc.6762:
  %t.6785 = load i32, ptr %i.238
  %t.6786 = add i32 %t.6785, 1
  store i32 %t.6786, ptr %i.238
  br label %for.cond.6760
for.end.6763:
  %t.6787 = load ptr, ptr %out.237
  ret ptr %t.6787
dead.6788:
  ret ptr null
}

define i64 @SigRet(ptr %sig) {
entry:
  %sig.addr = alloca ptr
  store ptr %sig, ptr %sig.addr
  %t.6789 = load ptr, ptr %sig.addr
  %r.6790 = call i64 @SplitFirst(ptr %t.6789, ptr @.str.284)
  %ext.6792 = sext i32 0 to i64
  %r.6791 = call i64 @kx_list_get(i64 %r.6790, i64 %ext.6792)
  ret i64 %r.6791
dead.6793:
  ret i64 0
}

define i64 @SigParams(ptr %sig) {
entry:
  %sig.addr = alloca ptr
  store ptr %sig, ptr %sig.addr
  %t.6794 = load ptr, ptr %sig.addr
  %r.6795 = call i64 @SplitFirst(ptr %t.6794, ptr @.str.284)
  %ext.6797 = sext i32 1 to i64
  %r.6796 = call i64 @kx_list_get(i64 %r.6795, i64 %ext.6797)
  %p.239 = alloca i64
  store i64 %r.6796, ptr %p.239
  %t.6798 = load i64, ptr %p.239
  %ext.6800 = inttoptr i64 %t.6798 to ptr
  %r.6801 = call i1 @kx_str_eq(ptr %ext.6800, ptr @.str.12)
  br i1 %r.6801, label %if.then.6802, label %if.merge.6803
if.then.6802:
  %r.6804 = call i64 @kx_list_new(i32 0)
  ret i64 %r.6804
dead.6805:
  br label %if.merge.6803
if.merge.6803:
  %t.6806 = load i64, ptr %p.239
  %cast.6807 = inttoptr i64 %t.6806 to ptr
  %r.6808 = call i64 @SplitAll(ptr %cast.6807, ptr @.str.97)
  ret i64 %r.6808
dead.6809:
  ret i64 0
}

define i64 @SigSetParam(i64 %g, ptr %name, i64 %index, ptr %type) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %name.addr = alloca ptr
  store ptr %name, ptr %name.addr
  %index.addr = alloca i64
  store i64 %index, ptr %index.addr
  %type.addr = alloca ptr
  store ptr %type, ptr %type.addr
  %t.6810 = load i64, ptr %g.addr
  %t.6811 = load ptr, ptr %name.addr
  %c.6812 = ptrtoint ptr %t.6811 to i64
  %r.6813 = call i1 @kx_map_has(i64 %t.6810, i64 %c.6812)
  %t.6814 = xor i1 %r.6813, true
  br i1 %t.6814, label %if.then.6815, label %if.merge.6816
if.then.6815:
  %ext.6817 = sext i32 0 to i64
  ret i64 %ext.6817
dead.6818:
  br label %if.merge.6816
if.merge.6816:
  %t.6819 = load i64, ptr %g.addr
  %t.6820 = load ptr, ptr %name.addr
  %c.6822 = ptrtoint ptr %t.6820 to i64
  %r.6821 = call i64 @kx_map_get(i64 %t.6819, i64 %c.6822)
  %sig.240 = alloca i64
  store i64 %r.6821, ptr %sig.240
  %t.6823 = load i64, ptr %sig.240
  %cast.6824 = inttoptr i64 %t.6823 to ptr
  %r.6825 = call i64 @SigRet(ptr %cast.6824)
  %ret.241 = alloca i64
  store i64 %r.6825, ptr %ret.241
  %t.6826 = load i64, ptr %sig.240
  %cast.6827 = inttoptr i64 %t.6826 to ptr
  %r.6828 = call i64 @SigParams(ptr %cast.6827)
  %params.242 = alloca i64
  store i64 %r.6828, ptr %params.242
  %t.6829 = load i32, ptr %index.addr
  %t.6830 = load i64, ptr %params.242
  %r.6831 = call i64 @kx_list_size(i64 %t.6830)
  %ext.6832 = sext i32 %t.6829 to i64
  %t.6833 = icmp sge i64 %ext.6832, %r.6831
  br i1 %t.6833, label %if.then.6834, label %if.merge.6835
if.then.6834:
  %ext.6836 = sext i32 0 to i64
  ret i64 %ext.6836
dead.6837:
  br label %if.merge.6835
if.merge.6835:
  %t.6838 = load i64, ptr %params.242
  %t.6839 = load i32, ptr %index.addr
  %ext.6841 = sext i32 %t.6839 to i64
  %r.6840 = call i64 @kx_list_get(i64 %t.6838, i64 %ext.6841)
  %old.243 = alloca i64
  store i64 %r.6840, ptr %old.243
  %t.6842 = load i64, ptr %old.243
  %t.6843 = load ptr, ptr %type.addr
  %ext.6845 = inttoptr i64 %t.6842 to ptr
  %r.6846 = call i1 @kx_str_eq(ptr %ext.6845, ptr %t.6843)
  %t.6847 = load ptr, ptr %type.addr
  %r.6849 = call i1 @kx_str_eq(ptr %t.6847, ptr @.str.285)
  %t.6850 = or i1 %r.6846, %r.6849
  br i1 %t.6850, label %if.then.6851, label %if.merge.6852
if.then.6851:
  %ext.6853 = sext i32 0 to i64
  ret i64 %ext.6853
dead.6854:
  br label %if.merge.6852
if.merge.6852:
  %t.6855 = load i64, ptr %old.243
  %ext.6857 = inttoptr i64 %t.6855 to ptr
  %r.6858 = call i1 @kx_str_eq(ptr %ext.6857, ptr @.str.269)
  %t.6859 = load ptr, ptr %type.addr
  %r.6861 = call i1 @kx_str_eq(ptr %t.6859, ptr @.str.269)
  %t.6862 = and i1 %r.6858, %r.6861
  br i1 %t.6862, label %if.then.6863, label %if.merge.6864
if.then.6863:
  %t.6865 = load i64, ptr %params.242
  %t.6866 = load i32, ptr %index.addr
  %t.6867 = load ptr, ptr %type.addr
  %ext.6868 = sext i32 %t.6866 to i64
  %ext.6869 = ptrtoint ptr %t.6867 to i64
  call void @kx_list_set(i64 %t.6865, i64 %ext.6868, i64 %ext.6869)
  %t.6870 = load i64, ptr %g.addr
  %t.6871 = load ptr, ptr %name.addr
  %t.6872 = load i64, ptr %ret.241
  %ext.6874 = call ptr @kx_int_str(i64 %t.6872)
  %r.6875 = call ptr @kx_str_cat(ptr %ext.6874, ptr @.str.284)
  %t.6876 = load i64, ptr %params.242
  %r.6877 = call ptr @JoinParts(i64 %t.6876, ptr @.str.97)
  %r.6879 = call ptr @kx_str_cat(ptr %r.6875, ptr %r.6877)
  %c.6880 = ptrtoint ptr %t.6871 to i64
  %c.6881 = ptrtoint ptr %r.6879 to i64
  call void @kx_map_set(i64 %t.6870, i64 %c.6880, i64 %c.6881)
  br label %if.merge.6864
if.merge.6864:
  %ext.6882 = sext i32 0 to i64
  ret i64 %ext.6882
dead.6883:
  ret i64 0
}

define i64 @SigSetRet(i64 %g, ptr %name, ptr %type) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %name.addr = alloca ptr
  store ptr %name, ptr %name.addr
  %type.addr = alloca ptr
  store ptr %type, ptr %type.addr
  %t.6884 = load i64, ptr %g.addr
  %t.6885 = load ptr, ptr %name.addr
  %c.6886 = ptrtoint ptr %t.6885 to i64
  %r.6887 = call i1 @kx_map_has(i64 %t.6884, i64 %c.6886)
  %t.6888 = xor i1 %r.6887, true
  br i1 %t.6888, label %if.then.6889, label %if.merge.6890
if.then.6889:
  %ext.6891 = sext i32 0 to i64
  ret i64 %ext.6891
dead.6892:
  br label %if.merge.6890
if.merge.6890:
  %t.6893 = load i64, ptr %g.addr
  %t.6894 = load ptr, ptr %name.addr
  %c.6896 = ptrtoint ptr %t.6894 to i64
  %r.6895 = call i64 @kx_map_get(i64 %t.6893, i64 %c.6896)
  %sig.244 = alloca i64
  store i64 %r.6895, ptr %sig.244
  %t.6897 = load i64, ptr %sig.244
  %cast.6898 = inttoptr i64 %t.6897 to ptr
  %r.6899 = call i64 @SigRet(ptr %cast.6898)
  %old.245 = alloca i64
  store i64 %r.6899, ptr %old.245
  %t.6900 = load i64, ptr %old.245
  %ext.6902 = inttoptr i64 %t.6900 to ptr
  %r.6903 = call i1 @kx_str_eq(ptr %ext.6902, ptr @.str.269)
  %t.6904 = load ptr, ptr %type.addr
  %r.6906 = call i1 @kx_str_eq(ptr %t.6904, ptr @.str.285)
  %t.6907 = and i1 %r.6903, %r.6906
  br i1 %t.6907, label %if.then.6908, label %if.merge.6909
if.then.6908:
  %t.6910 = load i64, ptr %sig.244
  %cast.6911 = inttoptr i64 %t.6910 to ptr
  %r.6912 = call i64 @SigParams(ptr %cast.6911)
  %params.246 = alloca i64
  store i64 %r.6912, ptr %params.246
  %t.6913 = load i64, ptr %g.addr
  %t.6914 = load ptr, ptr %name.addr
  %t.6915 = load ptr, ptr %type.addr
  %r.6917 = call ptr @kx_str_cat(ptr %t.6915, ptr @.str.284)
  %t.6918 = load i64, ptr %params.246
  %r.6919 = call ptr @JoinParts(i64 %t.6918, ptr @.str.97)
  %r.6921 = call ptr @kx_str_cat(ptr %r.6917, ptr %r.6919)
  %c.6922 = ptrtoint ptr %t.6914 to i64
  %c.6923 = ptrtoint ptr %r.6921 to i64
  call void @kx_map_set(i64 %t.6913, i64 %c.6922, i64 %c.6923)
  br label %if.merge.6909
if.merge.6909:
  %ext.6924 = sext i32 0 to i64
  ret i64 %ext.6924
dead.6925:
  ret i64 0
}

define ptr @InferExprType(i64 %g, i64 %e, i64 %arena, i64 %locals, ptr %fnName) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %e.addr = alloca i64
  store i64 %e, ptr %e.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %locals.addr = alloca i64
  store i64 %locals, ptr %locals.addr
  %fnName.addr = alloca ptr
  store ptr %fnName, ptr %fnName.addr
  %t.6926 = load i64, ptr %e.addr
  %r.6927 = call i64 @kx_struct_get(i64 %t.6926, i32 0)
  %field.6928 = inttoptr i64 %r.6927 to ptr
  %r.6930 = call i1 @kx_str_eq(ptr %field.6928, ptr @.str.24)
  br i1 %r.6930, label %if.then.6931, label %if.merge.6932
if.then.6931:
  ret ptr @.str.279
dead.6933:
  br label %if.merge.6932
if.merge.6932:
  %t.6934 = load i64, ptr %e.addr
  %r.6935 = call i64 @kx_struct_get(i64 %t.6934, i32 0)
  %field.6936 = inttoptr i64 %r.6935 to ptr
  %r.6938 = call i1 @kx_str_eq(ptr %field.6936, ptr @.str.25)
  br i1 %r.6938, label %if.then.6939, label %if.merge.6940
if.then.6939:
  ret ptr @.str.269
dead.6941:
  br label %if.merge.6940
if.merge.6940:
  %t.6942 = load i64, ptr %e.addr
  %r.6943 = call i64 @kx_struct_get(i64 %t.6942, i32 0)
  %field.6944 = inttoptr i64 %r.6943 to ptr
  %r.6946 = call i1 @kx_str_eq(ptr %field.6944, ptr @.str.26)
  %t.6947 = load i64, ptr %e.addr
  %r.6948 = call i64 @kx_struct_get(i64 %t.6947, i32 0)
  %field.6949 = inttoptr i64 %r.6948 to ptr
  %r.6951 = call i1 @kx_str_eq(ptr %field.6949, ptr @.str.27)
  %t.6952 = or i1 %r.6946, %r.6951
  br i1 %t.6952, label %if.then.6953, label %if.merge.6954
if.then.6953:
  ret ptr @.str.27
dead.6955:
  br label %if.merge.6954
if.merge.6954:
  %t.6956 = load i64, ptr %e.addr
  %r.6957 = call i64 @kx_struct_get(i64 %t.6956, i32 0)
  %field.6958 = inttoptr i64 %r.6957 to ptr
  %r.6960 = call i1 @kx_str_eq(ptr %field.6958, ptr @.str.30)
  %t.6961 = load i64, ptr %e.addr
  %r.6962 = call i64 @kx_struct_get(i64 %t.6961, i32 0)
  %field.6963 = inttoptr i64 %r.6962 to ptr
  %r.6965 = call i1 @kx_str_eq(ptr %field.6963, ptr @.str.155)
  %t.6966 = or i1 %r.6960, %r.6965
  br i1 %t.6966, label %if.then.6967, label %if.merge.6968
if.then.6967:
  ret ptr @.str.271
dead.6969:
  br label %if.merge.6968
if.merge.6968:
  %t.6970 = load i64, ptr %e.addr
  %r.6971 = call i64 @kx_struct_get(i64 %t.6970, i32 0)
  %field.6972 = inttoptr i64 %r.6971 to ptr
  %r.6974 = call i1 @kx_str_eq(ptr %field.6972, ptr @.str.28)
  br i1 %r.6974, label %if.then.6975, label %if.merge.6976
if.then.6975:
  ret ptr @.str.280
dead.6977:
  br label %if.merge.6976
if.merge.6976:
  %t.6978 = load i64, ptr %e.addr
  %r.6979 = call i64 @kx_struct_get(i64 %t.6978, i32 0)
  %field.6980 = inttoptr i64 %r.6979 to ptr
  %r.6982 = call i1 @kx_str_eq(ptr %field.6980, ptr @.str.92)
  br i1 %r.6982, label %if.then.6983, label %if.merge.6984
if.then.6983:
  %t.6985 = load i64, ptr %locals.addr
  %t.6986 = load i64, ptr %e.addr
  %r.6987 = call i64 @kx_struct_get(i64 %t.6986, i32 1)
  %field.6988 = inttoptr i64 %r.6987 to ptr
  %c.6989 = ptrtoint ptr %field.6988 to i64
  %r.6990 = call i1 @kx_map_has(i64 %t.6985, i64 %c.6989)
  br i1 %r.6990, label %if.then.6991, label %if.merge.6992
if.then.6991:
  %t.6993 = load i64, ptr %locals.addr
  %t.6994 = load i64, ptr %e.addr
  %r.6995 = call i64 @kx_struct_get(i64 %t.6994, i32 1)
  %field.6996 = inttoptr i64 %r.6995 to ptr
  %c.6998 = ptrtoint ptr %field.6996 to i64
  %r.6997 = call i64 @kx_map_get(i64 %t.6993, i64 %c.6998)
  %ext.6999 = inttoptr i64 %r.6997 to ptr
  ret ptr %ext.6999
dead.7000:
  br label %if.merge.6992
if.merge.6992:
  ret ptr @.str.269
dead.7001:
  br label %if.merge.6984
if.merge.6984:
  %t.7002 = load i64, ptr %e.addr
  %r.7003 = call i64 @kx_struct_get(i64 %t.7002, i32 0)
  %field.7004 = inttoptr i64 %r.7003 to ptr
  %r.7006 = call i1 @kx_str_eq(ptr %field.7004, ptr @.str.93)
  br i1 %r.7006, label %if.then.7007, label %if.merge.7008
if.then.7007:
  %t.7009 = load i64, ptr %e.addr
  %r.7010 = call i64 @kx_struct_get(i64 %t.7009, i32 1)
  %field.7011 = inttoptr i64 %r.7010 to ptr
  %r.7013 = call ptr @kx_str_cat(ptr @.str.286, ptr %field.7011)
  ret ptr %r.7013
dead.7014:
  br label %if.merge.7008
if.merge.7008:
  %t.7015 = load i64, ptr %e.addr
  %r.7016 = call i64 @kx_struct_get(i64 %t.7015, i32 0)
  %field.7017 = inttoptr i64 %r.7016 to ptr
  %r.7019 = call i1 @kx_str_eq(ptr %field.7017, ptr @.str.52)
  br i1 %r.7019, label %if.then.7020, label %if.merge.7021
if.then.7020:
  %t.7022 = load i64, ptr %g.addr
  %t.7023 = load i64, ptr %arena.addr
  %t.7024 = load i64, ptr %e.addr
  %cast.7025 = sext i32 0 to i64
  %r.7026 = call i64 @Child(i64 %t.7023, i64 %t.7024, i64 %cast.7025)
  %t.7027 = load i64, ptr %arena.addr
  %t.7028 = load i64, ptr %locals.addr
  %t.7029 = load ptr, ptr %fnName.addr
  %r.7030 = call ptr @InferExprType(i64 %t.7022, i64 %r.7026, i64 %t.7027, i64 %t.7028, ptr %t.7029)
  %base.247 = alloca ptr
  store ptr %r.7030, ptr %base.247
  %t.7031 = load i64, ptr %e.addr
  %r.7032 = call i64 @kx_struct_get(i64 %t.7031, i32 4)
  %r.7033 = call i64 @kx_list_size(i64 %r.7032)
  %ext.7034 = sext i32 2 to i64
  %t.7035 = icmp sgt i64 %r.7033, %ext.7034
  br i1 %t.7035, label %if.then.7036, label %if.merge.7037
if.then.7036:
  %t.7038 = load i64, ptr %locals.addr
  %t.7039 = load i64, ptr %arena.addr
  %t.7040 = load i64, ptr %e.addr
  %cast.7041 = sext i32 2 to i64
  %r.7042 = call i64 @Child(i64 %t.7039, i64 %t.7040, i64 %cast.7041)
  %r.7043 = call i64 @kx_struct_get(i64 %r.7042, i32 1)
  %field.7044 = inttoptr i64 %r.7043 to ptr
  %t.7045 = load ptr, ptr %base.247
  %c.7046 = ptrtoint ptr %field.7044 to i64
  %c.7047 = ptrtoint ptr %t.7045 to i64
  call void @kx_map_set(i64 %t.7038, i64 %c.7046, i64 %c.7047)
  br label %if.merge.7037
if.merge.7037:
  ret ptr @.str.280
dead.7048:
  br label %if.merge.7021
if.merge.7021:
  %t.7049 = load i64, ptr %e.addr
  %r.7050 = call i64 @kx_struct_get(i64 %t.7049, i32 0)
  %field.7051 = inttoptr i64 %r.7050 to ptr
  %r.7053 = call i1 @kx_str_eq(ptr %field.7051, ptr @.str.111)
  br i1 %r.7053, label %if.then.7054, label %if.merge.7055
if.then.7054:
  %t.7056 = load i64, ptr %arena.addr
  %t.7057 = load i64, ptr %e.addr
  %cast.7058 = sext i32 0 to i64
  %r.7059 = call i64 @Child(i64 %t.7056, i64 %t.7057, i64 %cast.7058)
  %baseNode.248 = alloca i64
  store i64 %r.7059, ptr %baseNode.248
  %t.7060 = load i64, ptr %g.addr
  %t.7061 = load i64, ptr %baseNode.248
  %t.7062 = load i64, ptr %arena.addr
  %t.7063 = load i64, ptr %locals.addr
  %t.7064 = load ptr, ptr %fnName.addr
  %r.7065 = call ptr @InferExprType(i64 %t.7060, i64 %t.7061, i64 %t.7062, i64 %t.7063, ptr %t.7064)
  %base.249 = alloca ptr
  store ptr %r.7065, ptr %base.249
  %t.7066 = load i64, ptr %e.addr
  %r.7067 = call i64 @kx_struct_get(i64 %t.7066, i32 1)
  %field.7068 = inttoptr i64 %r.7067 to ptr
  %m.250 = alloca ptr
  store ptr %field.7068, ptr %m.250
  %t.7069 = load i64, ptr %baseNode.248
  %ext.7071 = inttoptr i64 %t.7069 to ptr
  %r.7072 = call i1 @kx_str_eq(ptr %ext.7071, ptr @.str.103)
  br i1 %r.7072, label %if.then.7073, label %if.merge.7074
if.then.7073:
  %t.7075 = load i64, ptr %arena.addr
  %t.7076 = load i64, ptr %baseNode.248
  %cast.7077 = sext i32 0 to i64
  %r.7078 = call i64 @Child(i64 %t.7075, i64 %t.7076, i64 %cast.7077)
  %innerCallee.251 = alloca i64
  store i64 %r.7078, ptr %innerCallee.251
  %t.7079 = load i64, ptr %innerCallee.251
  %ext.7081 = inttoptr i64 %t.7079 to ptr
  %r.7082 = call i1 @kx_str_eq(ptr %ext.7081, ptr @.str.92)
  br i1 %r.7082, label %if.then.7083, label %if.merge.7084
if.then.7083:
  %t.7085 = load ptr, ptr %m.250
  %r.7087 = call i1 @kx_str_eq(ptr %t.7085, ptr @.str.287)
  %t.7088 = load ptr, ptr %m.250
  %r.7090 = call i1 @kx_str_eq(ptr %t.7088, ptr @.str.288)
  %t.7091 = or i1 %r.7087, %r.7090
  br i1 %t.7091, label %if.then.7092, label %if.merge.7093
if.then.7092:
  %t.7094 = load i64, ptr %g.addr
  %t.7095 = load i64, ptr %innerCallee.251
  %cast.7096 = inttoptr i64 %t.7095 to ptr
  %r.7097 = call i64 @SigSetRet(i64 %t.7094, ptr %cast.7096, ptr @.str.289)
  ret ptr @.str.271
dead.7098:
  br label %if.merge.7093
if.merge.7093:
  %t.7099 = load ptr, ptr %m.250
  %r.7101 = call i1 @kx_str_eq(ptr %t.7099, ptr @.str.290)
  %t.7102 = load ptr, ptr %m.250
  %r.7104 = call i1 @kx_str_eq(ptr %t.7102, ptr @.str.291)
  %t.7105 = or i1 %r.7101, %r.7104
  br i1 %t.7105, label %if.then.7106, label %if.merge.7107
if.then.7106:
  %t.7108 = load i64, ptr %g.addr
  %t.7109 = load i64, ptr %innerCallee.251
  %cast.7110 = inttoptr i64 %t.7109 to ptr
  %r.7111 = call i64 @SigSetRet(i64 %t.7108, ptr %cast.7110, ptr @.str.292)
  %t.7112 = load ptr, ptr %m.250
  %r.7114 = call i1 @kx_str_eq(ptr %t.7112, ptr @.str.290)
  br i1 %r.7114, label %tern.then.7115, label %tern.else.7116
tern.then.7115:
  br label %tern.merge.7117
tern.else.7116:
  br label %tern.merge.7117
tern.merge.7117:
  %phi.7118 = phi ptr [@.str.271, %tern.then.7115], [@.str.269, %tern.else.7116]
  ret ptr %phi.7118
dead.7119:
  br label %if.merge.7107
if.merge.7107:
  br label %if.merge.7084
if.merge.7084:
  br label %if.merge.7074
if.merge.7074:
  %t.7120 = load i64, ptr %baseNode.248
  %ext.7122 = inttoptr i64 %t.7120 to ptr
  %r.7123 = call i1 @kx_str_eq(ptr %ext.7122, ptr @.str.92)
  %t.7124 = load i64, ptr %locals.addr
  %t.7125 = load i64, ptr %baseNode.248
  %r.7126 = call i1 @kx_map_has(i64 %t.7124, i64 %t.7125)
  %t.7127 = and i1 %r.7123, %r.7126
  %t.7128 = load i64, ptr %locals.addr
  %t.7129 = load i64, ptr %baseNode.248
  %r.7130 = call i64 @kx_list_get(i64 %t.7128, i64 %t.7129)
  %ext.7131 = inttoptr i64 %r.7130 to ptr
  %r.7132 = call i1 @kx_str_starts_with(ptr %ext.7131, ptr @.str.286)
  %t.7133 = and i1 %t.7127, %r.7132
  br i1 %t.7133, label %if.then.7134, label %if.merge.7135
if.then.7134:
  %t.7136 = load ptr, ptr %m.250
  %r.7138 = call i1 @kx_str_eq(ptr %t.7136, ptr @.str.287)
  %t.7139 = load ptr, ptr %m.250
  %r.7141 = call i1 @kx_str_eq(ptr %t.7139, ptr @.str.288)
  %t.7142 = or i1 %r.7138, %r.7141
  %t.7143 = load ptr, ptr %m.250
  %r.7145 = call i1 @kx_str_eq(ptr %t.7143, ptr @.str.290)
  %t.7146 = or i1 %t.7142, %r.7145
  br i1 %t.7146, label %if.then.7147, label %if.merge.7148
if.then.7147:
  ret ptr @.str.271
dead.7149:
  br label %if.merge.7148
if.merge.7148:
  ret ptr @.str.269
dead.7150:
  br label %if.merge.7135
if.merge.7135:
  %t.7151 = load i64, ptr %baseNode.248
  %ext.7153 = inttoptr i64 %t.7151 to ptr
  %r.7154 = call i1 @kx_str_eq(ptr %ext.7153, ptr @.str.92)
  %t.7155 = load ptr, ptr %m.250
  %r.7157 = call i1 @kx_str_eq(ptr %t.7155, ptr @.str.293)
  %t.7158 = load ptr, ptr %m.250
  %r.7160 = call i1 @kx_str_eq(ptr %t.7158, ptr @.str.294)
  %t.7161 = or i1 %r.7157, %r.7160
  %t.7162 = load ptr, ptr %m.250
  %r.7164 = call i1 @kx_str_eq(ptr %t.7162, ptr @.str.295)
  %t.7165 = or i1 %t.7161, %r.7164
  %t.7166 = load ptr, ptr %m.250
  %r.7168 = call i1 @kx_str_eq(ptr %t.7166, ptr @.str.296)
  %t.7169 = or i1 %t.7165, %r.7168
  %t.7170 = load ptr, ptr %m.250
  %r.7172 = call i1 @kx_str_eq(ptr %t.7170, ptr @.str.297)
  %t.7173 = or i1 %t.7169, %r.7172
  %t.7174 = load ptr, ptr %m.250
  %r.7176 = call i1 @kx_str_eq(ptr %t.7174, ptr @.str.298)
  %t.7177 = or i1 %t.7173, %r.7176
  %t.7178 = load ptr, ptr %m.250
  %r.7180 = call i1 @kx_str_eq(ptr %t.7178, ptr @.str.299)
  %t.7181 = or i1 %t.7177, %r.7180
  %t.7182 = and i1 %r.7154, %t.7181
  br i1 %t.7182, label %if.then.7183, label %if.merge.7184
if.then.7183:
  %t.7185 = load i64, ptr %locals.addr
  %t.7186 = load i64, ptr %baseNode.248
  %ext.7187 = ptrtoint ptr @.str.271 to i64
  call void @kx_list_set(i64 %t.7185, i64 %t.7186, i64 %ext.7187)
  br label %if.merge.7184
if.merge.7184:
  %t.7188 = load ptr, ptr %m.250
  %r.7190 = call i1 @kx_str_eq(ptr %t.7188, ptr @.str.293)
  %t.7191 = load ptr, ptr %m.250
  %r.7193 = call i1 @kx_str_eq(ptr %t.7191, ptr @.str.300)
  %t.7194 = or i1 %r.7190, %r.7193
  br i1 %t.7194, label %if.then.7195, label %if.merge.7196
if.then.7195:
  ret ptr @.str.269
dead.7197:
  br label %if.merge.7196
if.merge.7196:
  %t.7198 = load ptr, ptr %base.249
  ret ptr %t.7198
dead.7199:
  br label %if.merge.7055
if.merge.7055:
  %t.7200 = load i64, ptr %e.addr
  %r.7201 = call i64 @kx_struct_get(i64 %t.7200, i32 0)
  %field.7202 = inttoptr i64 %r.7201 to ptr
  %r.7204 = call i1 @kx_str_eq(ptr %field.7202, ptr @.str.117)
  br i1 %r.7204, label %if.then.7205, label %if.merge.7206
if.then.7205:
  %t.7207 = load i64, ptr %arena.addr
  %t.7208 = load i64, ptr %e.addr
  %cast.7209 = sext i32 0 to i64
  %r.7210 = call i64 @Child(i64 %t.7207, i64 %t.7208, i64 %cast.7209)
  %left.252 = alloca i64
  store i64 %r.7210, ptr %left.252
  %t.7211 = load i64, ptr %arena.addr
  %t.7212 = load i64, ptr %e.addr
  %cast.7213 = sext i32 1 to i64
  %r.7214 = call i64 @Child(i64 %t.7211, i64 %t.7212, i64 %cast.7213)
  %right.253 = alloca i64
  store i64 %r.7214, ptr %right.253
  %t.7215 = load i64, ptr %g.addr
  %t.7216 = load i64, ptr %left.252
  %t.7217 = load i64, ptr %arena.addr
  %t.7218 = load i64, ptr %locals.addr
  %t.7219 = load ptr, ptr %fnName.addr
  %r.7220 = call ptr @InferExprType(i64 %t.7215, i64 %t.7216, i64 %t.7217, i64 %t.7218, ptr %t.7219)
  %lt.254 = alloca ptr
  store ptr %r.7220, ptr %lt.254
  %t.7221 = load i64, ptr %g.addr
  %t.7222 = load i64, ptr %right.253
  %t.7223 = load i64, ptr %arena.addr
  %t.7224 = load i64, ptr %locals.addr
  %t.7225 = load ptr, ptr %fnName.addr
  %r.7226 = call ptr @InferExprType(i64 %t.7221, i64 %t.7222, i64 %t.7223, i64 %t.7224, ptr %t.7225)
  %rt.255 = alloca ptr
  store ptr %r.7226, ptr %rt.255
  %t.7227 = load ptr, ptr %lt.254
  %r.7229 = call i1 @kx_str_eq(ptr %t.7227, ptr @.str.271)
  %t.7230 = load ptr, ptr %rt.255
  %r.7232 = call i1 @kx_str_eq(ptr %t.7230, ptr @.str.271)
  %t.7233 = or i1 %r.7229, %r.7232
  br i1 %t.7233, label %if.then.7234, label %if.merge.7235
if.then.7234:
  %t.7236 = load i64, ptr %left.252
  %ext.7238 = inttoptr i64 %t.7236 to ptr
  %r.7239 = call i1 @kx_str_eq(ptr %ext.7238, ptr @.str.92)
  br i1 %r.7239, label %if.then.7240, label %if.merge.7241
if.then.7240:
  %t.7242 = load i64, ptr %locals.addr
  %t.7243 = load i64, ptr %left.252
  %ext.7244 = ptrtoint ptr @.str.271 to i64
  call void @kx_list_set(i64 %t.7242, i64 %t.7243, i64 %ext.7244)
  br label %if.merge.7241
if.merge.7241:
  %t.7245 = load i64, ptr %right.253
  %ext.7247 = inttoptr i64 %t.7245 to ptr
  %r.7248 = call i1 @kx_str_eq(ptr %ext.7247, ptr @.str.92)
  br i1 %r.7248, label %if.then.7249, label %if.merge.7250
if.then.7249:
  %t.7251 = load i64, ptr %locals.addr
  %t.7252 = load i64, ptr %right.253
  %ext.7253 = ptrtoint ptr @.str.271 to i64
  call void @kx_list_set(i64 %t.7251, i64 %t.7252, i64 %ext.7253)
  br label %if.merge.7250
if.merge.7250:
  %t.7254 = load i64, ptr %e.addr
  %r.7255 = call i64 @kx_struct_get(i64 %t.7254, i32 1)
  %field.7256 = inttoptr i64 %r.7255 to ptr
  %r.7258 = call i1 @kx_str_eq(ptr %field.7256, ptr @.str.126)
  br i1 %r.7258, label %if.then.7259, label %if.merge.7260
if.then.7259:
  ret ptr @.str.271
dead.7261:
  br label %if.merge.7260
if.merge.7260:
  %t.7262 = load i64, ptr %e.addr
  %r.7263 = call i64 @kx_struct_get(i64 %t.7262, i32 1)
  %field.7264 = inttoptr i64 %r.7263 to ptr
  %r.7266 = call i1 @kx_str_eq(ptr %field.7264, ptr @.str.132)
  %t.7267 = load i64, ptr %e.addr
  %r.7268 = call i64 @kx_struct_get(i64 %t.7267, i32 1)
  %field.7269 = inttoptr i64 %r.7268 to ptr
  %r.7271 = call i1 @kx_str_eq(ptr %field.7269, ptr @.str.133)
  %t.7272 = or i1 %r.7266, %r.7271
  %t.7273 = load i64, ptr %e.addr
  %r.7274 = call i64 @kx_struct_get(i64 %t.7273, i32 1)
  %field.7275 = inttoptr i64 %r.7274 to ptr
  %r.7277 = call i1 @kx_str_eq(ptr %field.7275, ptr @.str.128)
  %t.7278 = or i1 %t.7272, %r.7277
  %t.7279 = load i64, ptr %e.addr
  %r.7280 = call i64 @kx_struct_get(i64 %t.7279, i32 1)
  %field.7281 = inttoptr i64 %r.7280 to ptr
  %r.7283 = call i1 @kx_str_eq(ptr %field.7281, ptr @.str.130)
  %t.7284 = or i1 %t.7278, %r.7283
  %t.7285 = load i64, ptr %e.addr
  %r.7286 = call i64 @kx_struct_get(i64 %t.7285, i32 1)
  %field.7287 = inttoptr i64 %r.7286 to ptr
  %r.7289 = call i1 @kx_str_eq(ptr %field.7287, ptr @.str.129)
  %t.7290 = or i1 %t.7284, %r.7289
  %t.7291 = load i64, ptr %e.addr
  %r.7292 = call i64 @kx_struct_get(i64 %t.7291, i32 1)
  %field.7293 = inttoptr i64 %r.7292 to ptr
  %r.7295 = call i1 @kx_str_eq(ptr %field.7293, ptr @.str.131)
  %t.7296 = or i1 %t.7290, %r.7295
  br i1 %t.7296, label %if.then.7297, label %if.merge.7298
if.then.7297:
  ret ptr @.str.280
dead.7299:
  br label %if.merge.7298
if.merge.7298:
  br label %if.merge.7235
if.merge.7235:
  %t.7300 = load i64, ptr %e.addr
  %r.7301 = call i64 @kx_struct_get(i64 %t.7300, i32 1)
  %field.7302 = inttoptr i64 %r.7301 to ptr
  %r.7304 = call i1 @kx_str_eq(ptr %field.7302, ptr @.str.134)
  %t.7305 = load i64, ptr %e.addr
  %r.7306 = call i64 @kx_struct_get(i64 %t.7305, i32 1)
  %field.7307 = inttoptr i64 %r.7306 to ptr
  %r.7309 = call i1 @kx_str_eq(ptr %field.7307, ptr @.str.135)
  %t.7310 = or i1 %r.7304, %r.7309
  %t.7311 = load i64, ptr %e.addr
  %r.7312 = call i64 @kx_struct_get(i64 %t.7311, i32 1)
  %field.7313 = inttoptr i64 %r.7312 to ptr
  %r.7315 = call i1 @kx_str_eq(ptr %field.7313, ptr @.str.132)
  %t.7316 = or i1 %t.7310, %r.7315
  %t.7317 = load i64, ptr %e.addr
  %r.7318 = call i64 @kx_struct_get(i64 %t.7317, i32 1)
  %field.7319 = inttoptr i64 %r.7318 to ptr
  %r.7321 = call i1 @kx_str_eq(ptr %field.7319, ptr @.str.133)
  %t.7322 = or i1 %t.7316, %r.7321
  %t.7323 = load i64, ptr %e.addr
  %r.7324 = call i64 @kx_struct_get(i64 %t.7323, i32 1)
  %field.7325 = inttoptr i64 %r.7324 to ptr
  %r.7327 = call i1 @kx_str_eq(ptr %field.7325, ptr @.str.128)
  %t.7328 = or i1 %t.7322, %r.7327
  %t.7329 = load i64, ptr %e.addr
  %r.7330 = call i64 @kx_struct_get(i64 %t.7329, i32 1)
  %field.7331 = inttoptr i64 %r.7330 to ptr
  %r.7333 = call i1 @kx_str_eq(ptr %field.7331, ptr @.str.130)
  %t.7334 = or i1 %t.7328, %r.7333
  %t.7335 = load i64, ptr %e.addr
  %r.7336 = call i64 @kx_struct_get(i64 %t.7335, i32 1)
  %field.7337 = inttoptr i64 %r.7336 to ptr
  %r.7339 = call i1 @kx_str_eq(ptr %field.7337, ptr @.str.129)
  %t.7340 = or i1 %t.7334, %r.7339
  %t.7341 = load i64, ptr %e.addr
  %r.7342 = call i64 @kx_struct_get(i64 %t.7341, i32 1)
  %field.7343 = inttoptr i64 %r.7342 to ptr
  %r.7345 = call i1 @kx_str_eq(ptr %field.7343, ptr @.str.131)
  %t.7346 = or i1 %t.7340, %r.7345
  br i1 %t.7346, label %if.then.7347, label %if.merge.7348
if.then.7347:
  ret ptr @.str.280
dead.7349:
  br label %if.merge.7348
if.merge.7348:
  ret ptr @.str.269
dead.7350:
  br label %if.merge.7206
if.merge.7206:
  %t.7351 = load i64, ptr %e.addr
  %r.7352 = call i64 @kx_struct_get(i64 %t.7351, i32 0)
  %field.7353 = inttoptr i64 %r.7352 to ptr
  %r.7355 = call i1 @kx_str_eq(ptr %field.7353, ptr @.str.114)
  br i1 %r.7355, label %if.then.7356, label %if.merge.7357
if.then.7356:
  %t.7358 = load i64, ptr %g.addr
  %t.7359 = load i64, ptr %arena.addr
  %t.7360 = load i64, ptr %e.addr
  %cast.7361 = sext i32 0 to i64
  %r.7362 = call i64 @Child(i64 %t.7359, i64 %t.7360, i64 %cast.7361)
  %t.7363 = load i64, ptr %arena.addr
  %t.7364 = load i64, ptr %locals.addr
  %t.7365 = load ptr, ptr %fnName.addr
  %r.7366 = call ptr @InferExprType(i64 %t.7358, i64 %r.7362, i64 %t.7363, i64 %t.7364, ptr %t.7365)
  %t.256 = alloca ptr
  store ptr %r.7366, ptr %t.256
  %t.7367 = load i64, ptr %e.addr
  %r.7368 = call i64 @kx_struct_get(i64 %t.7367, i32 1)
  %field.7369 = inttoptr i64 %r.7368 to ptr
  %r.7371 = call i1 @kx_str_eq(ptr %field.7369, ptr @.str.119)
  br i1 %r.7371, label %if.then.7372, label %if.merge.7373
if.then.7372:
  ret ptr @.str.280
dead.7374:
  br label %if.merge.7373
if.merge.7373:
  %t.7375 = load ptr, ptr %t.256
  ret ptr %t.7375
dead.7376:
  br label %if.merge.7357
if.merge.7357:
  %t.7377 = load i64, ptr %e.addr
  %r.7378 = call i64 @kx_struct_get(i64 %t.7377, i32 0)
  %field.7379 = inttoptr i64 %r.7378 to ptr
  %r.7381 = call i1 @kx_str_eq(ptr %field.7379, ptr @.str.137)
  br i1 %r.7381, label %if.then.7382, label %if.merge.7383
if.then.7382:
  %t.7384 = load i64, ptr %g.addr
  %t.7385 = load i64, ptr %arena.addr
  %t.7386 = load i64, ptr %e.addr
  %cast.7387 = sext i32 0 to i64
  %r.7388 = call i64 @Child(i64 %t.7385, i64 %t.7386, i64 %cast.7387)
  %t.7389 = load i64, ptr %arena.addr
  %t.7390 = load i64, ptr %locals.addr
  %t.7391 = load ptr, ptr %fnName.addr
  %r.7392 = call ptr @InferExprType(i64 %t.7384, i64 %r.7388, i64 %t.7389, i64 %t.7390, ptr %t.7391)
  %t.7393 = load i64, ptr %g.addr
  %t.7394 = load i64, ptr %arena.addr
  %t.7395 = load i64, ptr %e.addr
  %cast.7396 = sext i32 1 to i64
  %r.7397 = call i64 @Child(i64 %t.7394, i64 %t.7395, i64 %cast.7396)
  %t.7398 = load i64, ptr %arena.addr
  %t.7399 = load i64, ptr %locals.addr
  %t.7400 = load ptr, ptr %fnName.addr
  %r.7401 = call ptr @InferExprType(i64 %t.7393, i64 %r.7397, i64 %t.7398, i64 %t.7399, ptr %t.7400)
  %a.257 = alloca ptr
  store ptr %r.7401, ptr %a.257
  %t.7402 = load i64, ptr %g.addr
  %t.7403 = load i64, ptr %arena.addr
  %t.7404 = load i64, ptr %e.addr
  %cast.7405 = sext i32 2 to i64
  %r.7406 = call i64 @Child(i64 %t.7403, i64 %t.7404, i64 %cast.7405)
  %t.7407 = load i64, ptr %arena.addr
  %t.7408 = load i64, ptr %locals.addr
  %t.7409 = load ptr, ptr %fnName.addr
  %r.7410 = call ptr @InferExprType(i64 %t.7402, i64 %r.7406, i64 %t.7407, i64 %t.7408, ptr %t.7409)
  %b.258 = alloca ptr
  store ptr %r.7410, ptr %b.258
  %t.7411 = load ptr, ptr %a.257
  %t.7412 = load ptr, ptr %b.258
  %r.7414 = call i1 @kx_str_eq(ptr %t.7411, ptr %t.7412)
  br i1 %r.7414, label %if.then.7415, label %if.merge.7416
if.then.7415:
  %t.7417 = load ptr, ptr %a.257
  ret ptr %t.7417
dead.7418:
  br label %if.merge.7416
if.merge.7416:
  %t.7419 = load ptr, ptr %a.257
  %r.7421 = call i1 @kx_str_eq(ptr %t.7419, ptr @.str.271)
  %t.7422 = load ptr, ptr %b.258
  %r.7424 = call i1 @kx_str_eq(ptr %t.7422, ptr @.str.271)
  %t.7425 = or i1 %r.7421, %r.7424
  br i1 %t.7425, label %if.then.7426, label %if.merge.7427
if.then.7426:
  ret ptr @.str.271
dead.7428:
  br label %if.merge.7427
if.merge.7427:
  ret ptr @.str.269
dead.7429:
  br label %if.merge.7383
if.merge.7383:
  %t.7430 = load i64, ptr %e.addr
  %r.7431 = call i64 @kx_struct_get(i64 %t.7430, i32 0)
  %field.7432 = inttoptr i64 %r.7431 to ptr
  %r.7434 = call i1 @kx_str_eq(ptr %field.7432, ptr @.str.103)
  br i1 %r.7434, label %if.then.7435, label %if.merge.7436
if.then.7435:
  %t.7437 = load i64, ptr %arena.addr
  %t.7438 = load i64, ptr %e.addr
  %cast.7439 = sext i32 0 to i64
  %r.7440 = call i64 @Child(i64 %t.7437, i64 %t.7438, i64 %cast.7439)
  %callee.259 = alloca i64
  store i64 %r.7440, ptr %callee.259
  %t.7441 = load i64, ptr %callee.259
  %ext.7443 = inttoptr i64 %t.7441 to ptr
  %r.7444 = call i1 @kx_str_eq(ptr %ext.7443, ptr @.str.111)
  br i1 %r.7444, label %if.then.7445, label %if.merge.7446
if.then.7445:
  %t.7447 = load i64, ptr %arena.addr
  %t.7448 = load i64, ptr %callee.259
  %cast.7449 = sext i32 0 to i64
  %r.7450 = call i64 @Child(i64 %t.7447, i64 %t.7448, i64 %cast.7449)
  %base.260 = alloca i64
  store i64 %r.7450, ptr %base.260
  %t.7451 = load i64, ptr %callee.259
  %m.261 = alloca i64
  store i64 %t.7451, ptr %m.261
  %t.7452 = load i64, ptr %base.260
  %ext.7454 = inttoptr i64 %t.7452 to ptr
  %r.7455 = call i1 @kx_str_eq(ptr %ext.7454, ptr @.str.92)
  %t.7456 = load i64, ptr %base.260
  %ext.7458 = inttoptr i64 %t.7456 to ptr
  %r.7459 = call i1 @kx_str_eq(ptr %ext.7458, ptr @.str.301)
  %t.7460 = and i1 %r.7455, %r.7459
  br i1 %t.7460, label %if.then.7461, label %if.merge.7462
if.then.7461:
  %t.7463 = load i64, ptr %m.261
  %ext.7465 = inttoptr i64 %t.7463 to ptr
  %r.7466 = call i1 @kx_str_eq(ptr %ext.7465, ptr @.str.302)
  %t.7467 = load i64, ptr %m.261
  %ext.7469 = inttoptr i64 %t.7467 to ptr
  %r.7470 = call i1 @kx_str_eq(ptr %ext.7469, ptr @.str.303)
  %t.7471 = or i1 %r.7466, %r.7470
  br i1 %t.7471, label %if.then.7472, label %if.merge.7473
if.then.7472:
  ret ptr @.str.271
dead.7474:
  br label %if.merge.7473
if.merge.7473:
  %t.7475 = load i64, ptr %m.261
  %ext.7477 = inttoptr i64 %t.7475 to ptr
  %r.7478 = call i1 @kx_str_eq(ptr %ext.7477, ptr @.str.304)
  %t.7479 = load i64, ptr %m.261
  %ext.7481 = inttoptr i64 %t.7479 to ptr
  %r.7482 = call i1 @kx_str_eq(ptr %ext.7481, ptr @.str.305)
  %t.7483 = or i1 %r.7478, %r.7482
  br i1 %t.7483, label %if.then.7484, label %if.merge.7485
if.then.7484:
  ret ptr @.str.269
dead.7486:
  br label %if.merge.7485
if.merge.7485:
  %t.7487 = load i64, ptr %m.261
  %ext.7489 = inttoptr i64 %t.7487 to ptr
  %r.7490 = call i1 @kx_str_eq(ptr %ext.7489, ptr @.str.306)
  %t.7491 = load i64, ptr %m.261
  %ext.7493 = inttoptr i64 %t.7491 to ptr
  %r.7494 = call i1 @kx_str_eq(ptr %ext.7493, ptr @.str.307)
  %t.7495 = or i1 %r.7490, %r.7494
  %t.7496 = load i64, ptr %m.261
  %ext.7498 = inttoptr i64 %t.7496 to ptr
  %r.7499 = call i1 @kx_str_eq(ptr %ext.7498, ptr @.str.308)
  %t.7500 = or i1 %t.7495, %r.7499
  %t.7501 = load i64, ptr %m.261
  %ext.7503 = inttoptr i64 %t.7501 to ptr
  %r.7504 = call i1 @kx_str_eq(ptr %ext.7503, ptr @.str.309)
  %t.7505 = or i1 %t.7500, %r.7504
  br i1 %t.7505, label %if.then.7506, label %if.merge.7507
if.then.7506:
  ret ptr @.str.23
dead.7508:
  br label %if.merge.7507
if.merge.7507:
  br label %if.merge.7462
if.merge.7462:
  %t.7509 = load i64, ptr %g.addr
  %t.7510 = load i64, ptr %base.260
  %t.7511 = load i64, ptr %arena.addr
  %t.7512 = load i64, ptr %locals.addr
  %t.7513 = load ptr, ptr %fnName.addr
  %r.7514 = call ptr @InferExprType(i64 %t.7509, i64 %t.7510, i64 %t.7511, i64 %t.7512, ptr %t.7513)
  %bt.262 = alloca ptr
  store ptr %r.7514, ptr %bt.262
  %t.7515 = load i64, ptr %base.260
  %ext.7517 = inttoptr i64 %t.7515 to ptr
  %r.7518 = call i1 @kx_str_eq(ptr %ext.7517, ptr @.str.103)
  br i1 %r.7518, label %if.then.7519, label %if.merge.7520
if.then.7519:
  %t.7521 = load i64, ptr %arena.addr
  %t.7522 = load i64, ptr %base.260
  %cast.7523 = sext i32 0 to i64
  %r.7524 = call i64 @Child(i64 %t.7521, i64 %t.7522, i64 %cast.7523)
  %innerCallee.263 = alloca i64
  store i64 %r.7524, ptr %innerCallee.263
  %t.7525 = load i64, ptr %innerCallee.263
  %ext.7527 = inttoptr i64 %t.7525 to ptr
  %r.7528 = call i1 @kx_str_eq(ptr %ext.7527, ptr @.str.92)
  br i1 %r.7528, label %if.then.7529, label %if.merge.7530
if.then.7529:
  %t.7531 = load i64, ptr %m.261
  %ext.7533 = inttoptr i64 %t.7531 to ptr
  %r.7534 = call i1 @kx_str_eq(ptr %ext.7533, ptr @.str.287)
  %t.7535 = load i64, ptr %m.261
  %ext.7537 = inttoptr i64 %t.7535 to ptr
  %r.7538 = call i1 @kx_str_eq(ptr %ext.7537, ptr @.str.288)
  %t.7539 = or i1 %r.7534, %r.7538
  br i1 %t.7539, label %if.then.7540, label %if.merge.7541
if.then.7540:
  %t.7542 = load i64, ptr %g.addr
  %t.7543 = load i64, ptr %innerCallee.263
  %cast.7544 = inttoptr i64 %t.7543 to ptr
  %r.7545 = call i64 @SigSetRet(i64 %t.7542, ptr %cast.7544, ptr @.str.289)
  ret ptr @.str.271
dead.7546:
  br label %if.merge.7541
if.merge.7541:
  %t.7547 = load i64, ptr %m.261
  %ext.7549 = inttoptr i64 %t.7547 to ptr
  %r.7550 = call i1 @kx_str_eq(ptr %ext.7549, ptr @.str.290)
  %t.7551 = load i64, ptr %m.261
  %ext.7553 = inttoptr i64 %t.7551 to ptr
  %r.7554 = call i1 @kx_str_eq(ptr %ext.7553, ptr @.str.291)
  %t.7555 = or i1 %r.7550, %r.7554
  br i1 %t.7555, label %if.then.7556, label %if.merge.7557
if.then.7556:
  %t.7558 = load i64, ptr %g.addr
  %t.7559 = load i64, ptr %innerCallee.263
  %cast.7560 = inttoptr i64 %t.7559 to ptr
  %r.7561 = call i64 @SigSetRet(i64 %t.7558, ptr %cast.7560, ptr @.str.292)
  %t.7562 = load i64, ptr %m.261
  %ext.7564 = inttoptr i64 %t.7562 to ptr
  %r.7565 = call i1 @kx_str_eq(ptr %ext.7564, ptr @.str.290)
  br i1 %r.7565, label %tern.then.7566, label %tern.else.7567
tern.then.7566:
  br label %tern.merge.7568
tern.else.7567:
  br label %tern.merge.7568
tern.merge.7568:
  %phi.7569 = phi ptr [@.str.271, %tern.then.7566], [@.str.269, %tern.else.7567]
  ret ptr %phi.7569
dead.7570:
  br label %if.merge.7557
if.merge.7557:
  br label %if.merge.7530
if.merge.7530:
  br label %if.merge.7520
if.merge.7520:
  %t.7571 = load i64, ptr %base.260
  %ext.7573 = inttoptr i64 %t.7571 to ptr
  %r.7574 = call i1 @kx_str_eq(ptr %ext.7573, ptr @.str.92)
  %t.7575 = load i64, ptr %locals.addr
  %t.7576 = load i64, ptr %base.260
  %r.7577 = call i1 @kx_map_has(i64 %t.7575, i64 %t.7576)
  %t.7578 = and i1 %r.7574, %r.7577
  %t.7579 = load i64, ptr %locals.addr
  %t.7580 = load i64, ptr %base.260
  %r.7581 = call i64 @kx_list_get(i64 %t.7579, i64 %t.7580)
  %ext.7582 = inttoptr i64 %r.7581 to ptr
  %r.7583 = call i1 @kx_str_starts_with(ptr %ext.7582, ptr @.str.286)
  %t.7584 = and i1 %t.7578, %r.7583
  br i1 %t.7584, label %if.then.7585, label %if.merge.7586
if.then.7585:
  %t.7587 = load i64, ptr %m.261
  %ext.7589 = inttoptr i64 %t.7587 to ptr
  %r.7590 = call i1 @kx_str_eq(ptr %ext.7589, ptr @.str.287)
  %t.7591 = load i64, ptr %m.261
  %ext.7593 = inttoptr i64 %t.7591 to ptr
  %r.7594 = call i1 @kx_str_eq(ptr %ext.7593, ptr @.str.288)
  %t.7595 = or i1 %r.7590, %r.7594
  %t.7596 = load i64, ptr %m.261
  %ext.7598 = inttoptr i64 %t.7596 to ptr
  %r.7599 = call i1 @kx_str_eq(ptr %ext.7598, ptr @.str.290)
  %t.7600 = or i1 %t.7595, %r.7599
  br i1 %t.7600, label %if.then.7601, label %if.merge.7602
if.then.7601:
  ret ptr @.str.271
dead.7603:
  br label %if.merge.7602
if.merge.7602:
  ret ptr @.str.269
dead.7604:
  br label %if.merge.7586
if.merge.7586:
  %t.7605 = load i64, ptr %base.260
  %ext.7607 = inttoptr i64 %t.7605 to ptr
  %r.7608 = call i1 @kx_str_eq(ptr %ext.7607, ptr @.str.92)
  %t.7609 = load i64, ptr %m.261
  %ext.7611 = inttoptr i64 %t.7609 to ptr
  %r.7612 = call i1 @kx_str_eq(ptr %ext.7611, ptr @.str.294)
  %t.7613 = load i64, ptr %m.261
  %ext.7615 = inttoptr i64 %t.7613 to ptr
  %r.7616 = call i1 @kx_str_eq(ptr %ext.7615, ptr @.str.295)
  %t.7617 = or i1 %r.7612, %r.7616
  %t.7618 = load i64, ptr %m.261
  %ext.7620 = inttoptr i64 %t.7618 to ptr
  %r.7621 = call i1 @kx_str_eq(ptr %ext.7620, ptr @.str.296)
  %t.7622 = or i1 %t.7617, %r.7621
  %t.7623 = load i64, ptr %m.261
  %ext.7625 = inttoptr i64 %t.7623 to ptr
  %r.7626 = call i1 @kx_str_eq(ptr %ext.7625, ptr @.str.297)
  %t.7627 = or i1 %t.7622, %r.7626
  %t.7628 = load i64, ptr %m.261
  %ext.7630 = inttoptr i64 %t.7628 to ptr
  %r.7631 = call i1 @kx_str_eq(ptr %ext.7630, ptr @.str.298)
  %t.7632 = or i1 %t.7627, %r.7631
  %t.7633 = load i64, ptr %m.261
  %ext.7635 = inttoptr i64 %t.7633 to ptr
  %r.7636 = call i1 @kx_str_eq(ptr %ext.7635, ptr @.str.299)
  %t.7637 = or i1 %t.7632, %r.7636
  %t.7638 = and i1 %r.7608, %t.7637
  br i1 %t.7638, label %if.then.7639, label %if.merge.7640
if.then.7639:
  %t.7641 = load i64, ptr %locals.addr
  %t.7642 = load i64, ptr %base.260
  %ext.7643 = ptrtoint ptr @.str.271 to i64
  call void @kx_list_set(i64 %t.7641, i64 %t.7642, i64 %ext.7643)
  br label %if.merge.7640
if.merge.7640:
  %t.7644 = load i64, ptr %m.261
  %ext.7646 = inttoptr i64 %t.7644 to ptr
  %r.7647 = call i1 @kx_str_eq(ptr %ext.7646, ptr @.str.294)
  %t.7648 = load i64, ptr %m.261
  %ext.7650 = inttoptr i64 %t.7648 to ptr
  %r.7651 = call i1 @kx_str_eq(ptr %ext.7650, ptr @.str.298)
  %t.7652 = or i1 %r.7647, %r.7651
  %t.7653 = load i64, ptr %m.261
  %ext.7655 = inttoptr i64 %t.7653 to ptr
  %r.7656 = call i1 @kx_str_eq(ptr %ext.7655, ptr @.str.299)
  %t.7657 = or i1 %t.7652, %r.7656
  br i1 %t.7657, label %if.then.7658, label %if.merge.7659
if.then.7658:
  ret ptr @.str.271
dead.7660:
  br label %if.merge.7659
if.merge.7659:
  %t.7661 = load i64, ptr %m.261
  %ext.7663 = inttoptr i64 %t.7661 to ptr
  %r.7664 = call i1 @kx_str_eq(ptr %ext.7663, ptr @.str.295)
  %t.7665 = load i64, ptr %m.261
  %ext.7667 = inttoptr i64 %t.7665 to ptr
  %r.7668 = call i1 @kx_str_eq(ptr %ext.7667, ptr @.str.296)
  %t.7669 = or i1 %r.7664, %r.7668
  %t.7670 = load i64, ptr %m.261
  %ext.7672 = inttoptr i64 %t.7670 to ptr
  %r.7673 = call i1 @kx_str_eq(ptr %ext.7672, ptr @.str.297)
  %t.7674 = or i1 %t.7669, %r.7673
  br i1 %t.7674, label %if.then.7675, label %if.merge.7676
if.then.7675:
  ret ptr @.str.280
dead.7677:
  br label %if.merge.7676
if.merge.7676:
  %t.7678 = load i64, ptr %m.261
  %ext.7680 = inttoptr i64 %t.7678 to ptr
  %r.7681 = call i1 @kx_str_eq(ptr %ext.7680, ptr @.str.310)
  %t.7682 = load i64, ptr %m.261
  %ext.7684 = inttoptr i64 %t.7682 to ptr
  %r.7685 = call i1 @kx_str_eq(ptr %ext.7684, ptr @.str.311)
  %t.7686 = or i1 %r.7681, %r.7685
  %t.7687 = load i64, ptr %m.261
  %ext.7689 = inttoptr i64 %t.7687 to ptr
  %r.7690 = call i1 @kx_str_eq(ptr %ext.7689, ptr @.str.312)
  %t.7691 = or i1 %t.7686, %r.7690
  %t.7692 = load i64, ptr %m.261
  %ext.7694 = inttoptr i64 %t.7692 to ptr
  %r.7695 = call i1 @kx_str_eq(ptr %ext.7694, ptr @.str.313)
  %t.7696 = or i1 %t.7691, %r.7695
  br i1 %t.7696, label %if.then.7697, label %if.merge.7698
if.then.7697:
  ret ptr @.str.269
dead.7699:
  br label %if.merge.7698
if.merge.7698:
  br label %if.merge.7446
if.merge.7446:
  %t.7700 = load i64, ptr %callee.259
  %ext.7702 = inttoptr i64 %t.7700 to ptr
  %r.7703 = call i1 @kx_str_eq(ptr %ext.7702, ptr @.str.92)
  br i1 %r.7703, label %if.then.7704, label %if.merge.7705
if.then.7704:
  %t.7706 = load i64, ptr %callee.259
  %name.264 = alloca i64
  store i64 %t.7706, ptr %name.264
  %t.7707 = load i64, ptr %name.264
  %ext.7709 = inttoptr i64 %t.7707 to ptr
  %r.7710 = call i1 @kx_str_eq(ptr %ext.7709, ptr @.str.314)
  %t.7711 = load i64, ptr %name.264
  %ext.7713 = inttoptr i64 %t.7711 to ptr
  %r.7714 = call i1 @kx_str_eq(ptr %ext.7713, ptr @.str.315)
  %t.7715 = or i1 %r.7710, %r.7714
  br i1 %t.7715, label %if.then.7716, label %if.merge.7717
if.then.7716:
  ret ptr @.str.269
dead.7718:
  br label %if.merge.7717
if.merge.7717:
  %t.7719 = load i64, ptr %name.264
  %ext.7721 = inttoptr i64 %t.7719 to ptr
  %r.7722 = call i1 @kx_str_eq(ptr %ext.7721, ptr @.str.316)
  %t.7723 = load i64, ptr %name.264
  %ext.7725 = inttoptr i64 %t.7723 to ptr
  %r.7726 = call i1 @kx_str_eq(ptr %ext.7725, ptr @.str.317)
  %t.7727 = or i1 %r.7722, %r.7726
  br i1 %t.7727, label %if.then.7728, label %if.merge.7729
if.then.7728:
  ret ptr @.str.271
dead.7730:
  br label %if.merge.7729
if.merge.7729:
  %t.7731 = load i64, ptr %g.addr
  %t.7732 = load i64, ptr %name.264
  %r.7733 = call i1 @kx_map_has(i64 %t.7731, i64 %t.7732)
  br i1 %r.7733, label %if.then.7734, label %if.merge.7735
if.then.7734:
  %t.7736 = load i64, ptr %g.addr
  %t.7737 = load i64, ptr %name.264
  %r.7738 = call i64 @kx_list_get(i64 %t.7736, i64 %t.7737)
  %cast.7739 = inttoptr i64 %r.7738 to ptr
  %r.7740 = call i64 @SigParams(ptr %cast.7739)
  %ps.265 = alloca i64
  store i64 %r.7740, ptr %ps.265
  %i.266 = alloca i32
  store i32 1, ptr %i.266
  br label %for.cond.7741
for.cond.7741:
  %t.7745 = load i32, ptr %i.266
  %t.7746 = load i64, ptr %e.addr
  %r.7747 = call i64 @kx_struct_get(i64 %t.7746, i32 4)
  %r.7748 = call i64 @kx_list_size(i64 %r.7747)
  %ext.7749 = sext i32 %t.7745 to i64
  %t.7750 = icmp slt i64 %ext.7749, %r.7748
  %t.7751 = load i32, ptr %i.266
  %t.7752 = load i64, ptr %ps.265
  %r.7753 = call i64 @kx_list_size(i64 %t.7752)
  %ext.7754 = sext i32 %t.7751 to i64
  %t.7755 = icmp sle i64 %ext.7754, %r.7753
  %t.7756 = and i1 %t.7750, %t.7755
  br i1 %t.7756, label %for.body.7742, label %for.end.7744
for.body.7742:
  %t.7757 = load i64, ptr %arena.addr
  %t.7758 = load i64, ptr %e.addr
  %t.7759 = load i32, ptr %i.266
  %cast.7760 = sext i32 %t.7759 to i64
  %r.7761 = call i64 @Child(i64 %t.7757, i64 %t.7758, i64 %cast.7760)
  %arg.267 = alloca i64
  store i64 %r.7761, ptr %arg.267
  %t.7762 = load i64, ptr %arg.267
  %ext.7764 = inttoptr i64 %t.7762 to ptr
  %r.7765 = call i1 @kx_str_eq(ptr %ext.7764, ptr @.str.106)
  br i1 %r.7765, label %if.then.7766, label %if.merge.7767
if.then.7766:
  %t.7768 = load i64, ptr %arena.addr
  %t.7769 = load i64, ptr %arg.267
  %cast.7770 = sext i32 0 to i64
  %r.7771 = call i64 @Child(i64 %t.7768, i64 %t.7769, i64 %cast.7770)
  store i64 %r.7771, ptr %arg.267
  br label %if.merge.7767
if.merge.7767:
  %t.7772 = load i64, ptr %g.addr
  %t.7773 = load i64, ptr %arg.267
  %t.7774 = load i64, ptr %arena.addr
  %t.7775 = load i64, ptr %locals.addr
  %t.7776 = load ptr, ptr %fnName.addr
  %r.7777 = call ptr @InferExprType(i64 %t.7772, i64 %t.7773, i64 %t.7774, i64 %t.7775, ptr %t.7776)
  %at.268 = alloca ptr
  store ptr %r.7777, ptr %at.268
  %t.7778 = load i64, ptr %g.addr
  %t.7779 = load i64, ptr %name.264
  %cast.7780 = inttoptr i64 %t.7779 to ptr
  %t.7781 = load i32, ptr %i.266
  %t.7782 = sub i32 %t.7781, 1
  %cast.7783 = sext i32 %t.7782 to i64
  %t.7784 = load ptr, ptr %at.268
  %r.7785 = call i64 @SigSetParam(i64 %t.7778, ptr %cast.7780, i64 %cast.7783, ptr %t.7784)
  br label %for.inc.7743
for.inc.7743:
  %t.7786 = load i32, ptr %i.266
  %t.7787 = add i32 %t.7786, 1
  store i32 %t.7787, ptr %i.266
  br label %for.cond.7741
for.end.7744:
  %t.7788 = load i64, ptr %g.addr
  %t.7789 = load i64, ptr %name.264
  %r.7790 = call i64 @kx_list_get(i64 %t.7788, i64 %t.7789)
  %cast.7791 = inttoptr i64 %r.7790 to ptr
  %r.7792 = call i64 @SigRet(ptr %cast.7791)
  %ext.7793 = inttoptr i64 %r.7792 to ptr
  ret ptr %ext.7793
dead.7794:
  br label %if.merge.7735
if.merge.7735:
  br label %if.merge.7705
if.merge.7705:
  ret ptr @.str.269
dead.7795:
  br label %if.merge.7436
if.merge.7436:
  %t.7796 = load i64, ptr %e.addr
  %r.7797 = call i64 @kx_struct_get(i64 %t.7796, i32 0)
  %field.7798 = inttoptr i64 %r.7797 to ptr
  %r.7800 = call i1 @kx_str_eq(ptr %field.7798, ptr @.str.139)
  br i1 %r.7800, label %if.then.7801, label %if.merge.7802
if.then.7801:
  %t.7803 = load i64, ptr %g.addr
  %t.7804 = load i64, ptr %arena.addr
  %t.7805 = load i64, ptr %e.addr
  %cast.7806 = sext i32 1 to i64
  %r.7807 = call i64 @Child(i64 %t.7804, i64 %t.7805, i64 %cast.7806)
  %t.7808 = load i64, ptr %arena.addr
  %t.7809 = load i64, ptr %locals.addr
  %t.7810 = load ptr, ptr %fnName.addr
  %r.7811 = call ptr @InferExprType(i64 %t.7803, i64 %r.7807, i64 %t.7808, i64 %t.7809, ptr %t.7810)
  %value.269 = alloca ptr
  store ptr %r.7811, ptr %value.269
  %t.7812 = load i64, ptr %arena.addr
  %t.7813 = load i64, ptr %e.addr
  %cast.7814 = sext i32 0 to i64
  %r.7815 = call i64 @Child(i64 %t.7812, i64 %t.7813, i64 %cast.7814)
  %lhs.270 = alloca i64
  store i64 %r.7815, ptr %lhs.270
  %t.7816 = load i64, ptr %lhs.270
  %ext.7818 = inttoptr i64 %t.7816 to ptr
  %r.7819 = call i1 @kx_str_eq(ptr %ext.7818, ptr @.str.92)
  br i1 %r.7819, label %if.then.7820, label %if.merge.7821
if.then.7820:
  %t.7822 = load i64, ptr %locals.addr
  %t.7823 = load i64, ptr %lhs.270
  %t.7824 = load ptr, ptr %value.269
  %ext.7825 = ptrtoint ptr %t.7824 to i64
  call void @kx_list_set(i64 %t.7822, i64 %t.7823, i64 %ext.7825)
  br label %if.merge.7821
if.merge.7821:
  %t.7826 = load ptr, ptr %value.269
  ret ptr %t.7826
dead.7827:
  br label %if.merge.7802
if.merge.7802:
  ret ptr @.str.269
dead.7828:
  ret ptr null
}

define i64 @InferStmt(i64 %g, i64 %s, i64 %arena, i64 %locals, ptr %fnName) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %s.addr = alloca i64
  store i64 %s, ptr %s.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %locals.addr = alloca i64
  store i64 %locals, ptr %locals.addr
  %fnName.addr = alloca ptr
  store ptr %fnName, ptr %fnName.addr
  %t.7829 = load i64, ptr %s.addr
  %r.7830 = call i64 @kx_struct_get(i64 %t.7829, i32 0)
  %field.7831 = inttoptr i64 %r.7830 to ptr
  %r.7833 = call i1 @kx_str_eq(ptr %field.7831, ptr @.str.161)
  br i1 %r.7833, label %if.then.7834, label %if.merge.7835
if.then.7834:
  %t.7836 = load i64, ptr %arena.addr
  %t.7837 = load i64, ptr %s.addr
  %cast.7838 = sext i32 0 to i64
  %r.7839 = call i64 @Child(i64 %t.7836, i64 %t.7837, i64 %cast.7838)
  %r.7840 = call i64 @kx_struct_get(i64 %r.7839, i32 1)
  %field.7841 = inttoptr i64 %r.7840 to ptr
  %name.271 = alloca ptr
  store ptr %field.7841, ptr %name.271
  %t.7842 = load i64, ptr %locals.addr
  %t.7843 = load ptr, ptr %name.271
  %t.7844 = load i64, ptr %g.addr
  %t.7845 = load i64, ptr %arena.addr
  %t.7846 = load i64, ptr %s.addr
  %cast.7847 = sext i32 1 to i64
  %r.7848 = call i64 @Child(i64 %t.7845, i64 %t.7846, i64 %cast.7847)
  %t.7849 = load i64, ptr %arena.addr
  %t.7850 = load i64, ptr %locals.addr
  %t.7851 = load ptr, ptr %fnName.addr
  %r.7852 = call ptr @InferExprType(i64 %t.7844, i64 %r.7848, i64 %t.7849, i64 %t.7850, ptr %t.7851)
  %c.7853 = ptrtoint ptr %t.7843 to i64
  %c.7854 = ptrtoint ptr %r.7852 to i64
  call void @kx_map_set(i64 %t.7842, i64 %c.7853, i64 %c.7854)
  %ext.7855 = sext i32 0 to i64
  ret i64 %ext.7855
dead.7856:
  br label %if.merge.7835
if.merge.7835:
  %t.7857 = load i64, ptr %s.addr
  %r.7858 = call i64 @kx_struct_get(i64 %t.7857, i32 0)
  %field.7859 = inttoptr i64 %r.7858 to ptr
  %r.7861 = call i1 @kx_str_eq(ptr %field.7859, ptr @.str.198)
  br i1 %r.7861, label %if.then.7862, label %if.merge.7863
if.then.7862:
  %t.7864 = load i64, ptr %g.addr
  %t.7865 = load i64, ptr %arena.addr
  %t.7866 = load i64, ptr %s.addr
  %cast.7867 = sext i32 0 to i64
  %r.7868 = call i64 @Child(i64 %t.7865, i64 %t.7866, i64 %cast.7867)
  %t.7869 = load i64, ptr %arena.addr
  %t.7870 = load i64, ptr %locals.addr
  %t.7871 = load ptr, ptr %fnName.addr
  %r.7872 = call ptr @InferExprType(i64 %t.7864, i64 %r.7868, i64 %t.7869, i64 %t.7870, ptr %t.7871)
  %ext.7873 = sext i32 0 to i64
  ret i64 %ext.7873
dead.7874:
  br label %if.merge.7863
if.merge.7863:
  %t.7875 = load i64, ptr %s.addr
  %r.7876 = call i64 @kx_struct_get(i64 %t.7875, i32 0)
  %field.7877 = inttoptr i64 %r.7876 to ptr
  %r.7879 = call i1 @kx_str_eq(ptr %field.7877, ptr @.str.39)
  br i1 %r.7879, label %if.then.7880, label %if.merge.7881
if.then.7880:
  %t.7882 = load i64, ptr %s.addr
  %r.7883 = call i64 @kx_struct_get(i64 %t.7882, i32 4)
  %r.7884 = call i64 @kx_list_size(i64 %r.7883)
  %ext.7885 = sext i32 0 to i64
  %t.7886 = icmp sgt i64 %r.7884, %ext.7885
  br i1 %t.7886, label %if.then.7887, label %if.merge.7888
if.then.7887:
  %t.7889 = load i64, ptr %g.addr
  %t.7890 = load ptr, ptr %fnName.addr
  %t.7891 = load i64, ptr %g.addr
  %t.7892 = load i64, ptr %arena.addr
  %t.7893 = load i64, ptr %s.addr
  %cast.7894 = sext i32 0 to i64
  %r.7895 = call i64 @Child(i64 %t.7892, i64 %t.7893, i64 %cast.7894)
  %t.7896 = load i64, ptr %arena.addr
  %t.7897 = load i64, ptr %locals.addr
  %t.7898 = load ptr, ptr %fnName.addr
  %r.7899 = call ptr @InferExprType(i64 %t.7891, i64 %r.7895, i64 %t.7896, i64 %t.7897, ptr %t.7898)
  %r.7900 = call i64 @SigSetRet(i64 %t.7889, ptr %t.7890, ptr %r.7899)
  br label %if.merge.7888
if.merge.7888:
  %ext.7901 = sext i32 0 to i64
  ret i64 %ext.7901
dead.7902:
  br label %if.merge.7881
if.merge.7881:
  %t.7903 = load i64, ptr %s.addr
  %r.7904 = call i64 @kx_struct_get(i64 %t.7903, i32 0)
  %field.7905 = inttoptr i64 %r.7904 to ptr
  %r.7907 = call i1 @kx_str_eq(ptr %field.7905, ptr @.str.158)
  br i1 %r.7907, label %if.then.7908, label %if.merge.7909
if.then.7908:
  %i.272 = alloca i32
  store i32 0, ptr %i.272
  br label %for.cond.7910
for.cond.7910:
  %t.7914 = load i32, ptr %i.272
  %t.7915 = load i64, ptr %s.addr
  %r.7916 = call i64 @kx_struct_get(i64 %t.7915, i32 4)
  %r.7917 = call i64 @kx_list_size(i64 %r.7916)
  %ext.7918 = sext i32 %t.7914 to i64
  %t.7919 = icmp slt i64 %ext.7918, %r.7917
  br i1 %t.7919, label %for.body.7911, label %for.end.7913
for.body.7911:
  %t.7920 = load i64, ptr %g.addr
  %t.7921 = load i64, ptr %arena.addr
  %t.7922 = load i64, ptr %s.addr
  %t.7923 = load i32, ptr %i.272
  %cast.7924 = sext i32 %t.7923 to i64
  %r.7925 = call i64 @Child(i64 %t.7921, i64 %t.7922, i64 %cast.7924)
  %t.7926 = load i64, ptr %arena.addr
  %t.7927 = load i64, ptr %locals.addr
  %t.7928 = load ptr, ptr %fnName.addr
  %r.7929 = call i64 @InferStmt(i64 %t.7920, i64 %r.7925, i64 %t.7926, i64 %t.7927, ptr %t.7928)
  br label %for.inc.7912
for.inc.7912:
  %t.7930 = load i32, ptr %i.272
  %t.7931 = add i32 %t.7930, 1
  store i32 %t.7931, ptr %i.272
  br label %for.cond.7910
for.end.7913:
  %ext.7932 = sext i32 0 to i64
  ret i64 %ext.7932
dead.7933:
  br label %if.merge.7909
if.merge.7909:
  %t.7934 = load i64, ptr %s.addr
  %r.7935 = call i64 @kx_struct_get(i64 %t.7934, i32 0)
  %field.7936 = inttoptr i64 %r.7935 to ptr
  %r.7938 = call i1 @kx_str_eq(ptr %field.7936, ptr @.str.31)
  %t.7939 = load i64, ptr %s.addr
  %r.7940 = call i64 @kx_struct_get(i64 %t.7939, i32 0)
  %field.7941 = inttoptr i64 %r.7940 to ptr
  %r.7943 = call i1 @kx_str_eq(ptr %field.7941, ptr @.str.33)
  %t.7944 = or i1 %r.7938, %r.7943
  br i1 %t.7944, label %if.then.7945, label %if.merge.7946
if.then.7945:
  %t.7947 = load i64, ptr %g.addr
  %t.7948 = load i64, ptr %arena.addr
  %t.7949 = load i64, ptr %s.addr
  %cast.7950 = sext i32 0 to i64
  %r.7951 = call i64 @Child(i64 %t.7948, i64 %t.7949, i64 %cast.7950)
  %t.7952 = load i64, ptr %arena.addr
  %t.7953 = load i64, ptr %locals.addr
  %t.7954 = load ptr, ptr %fnName.addr
  %r.7955 = call ptr @InferExprType(i64 %t.7947, i64 %r.7951, i64 %t.7952, i64 %t.7953, ptr %t.7954)
  %i.273 = alloca i32
  store i32 1, ptr %i.273
  br label %for.cond.7956
for.cond.7956:
  %t.7960 = load i32, ptr %i.273
  %t.7961 = load i64, ptr %s.addr
  %r.7962 = call i64 @kx_struct_get(i64 %t.7961, i32 4)
  %r.7963 = call i64 @kx_list_size(i64 %r.7962)
  %ext.7964 = sext i32 %t.7960 to i64
  %t.7965 = icmp slt i64 %ext.7964, %r.7963
  br i1 %t.7965, label %for.body.7957, label %for.end.7959
for.body.7957:
  %t.7966 = load i64, ptr %g.addr
  %t.7967 = load i64, ptr %arena.addr
  %t.7968 = load i64, ptr %s.addr
  %t.7969 = load i32, ptr %i.273
  %cast.7970 = sext i32 %t.7969 to i64
  %r.7971 = call i64 @Child(i64 %t.7967, i64 %t.7968, i64 %cast.7970)
  %t.7972 = load i64, ptr %arena.addr
  %t.7973 = load i64, ptr %locals.addr
  %t.7974 = load ptr, ptr %fnName.addr
  %r.7975 = call i64 @InferStmt(i64 %t.7966, i64 %r.7971, i64 %t.7972, i64 %t.7973, ptr %t.7974)
  br label %for.inc.7958
for.inc.7958:
  %t.7976 = load i32, ptr %i.273
  %t.7977 = add i32 %t.7976, 1
  store i32 %t.7977, ptr %i.273
  br label %for.cond.7956
for.end.7959:
  %ext.7978 = sext i32 0 to i64
  ret i64 %ext.7978
dead.7979:
  br label %if.merge.7946
if.merge.7946:
  %t.7980 = load i64, ptr %s.addr
  %r.7981 = call i64 @kx_struct_get(i64 %t.7980, i32 0)
  %field.7982 = inttoptr i64 %r.7981 to ptr
  %r.7984 = call i1 @kx_str_eq(ptr %field.7982, ptr @.str.34)
  br i1 %r.7984, label %if.then.7985, label %if.merge.7986
if.then.7985:
  %i.274 = alloca i32
  store i32 0, ptr %i.274
  br label %for.cond.7987
for.cond.7987:
  %t.7991 = load i32, ptr %i.274
  %t.7992 = load i64, ptr %s.addr
  %r.7993 = call i64 @kx_struct_get(i64 %t.7992, i32 4)
  %r.7994 = call i64 @kx_list_size(i64 %r.7993)
  %ext.7995 = sext i32 %t.7991 to i64
  %t.7996 = icmp slt i64 %ext.7995, %r.7994
  br i1 %t.7996, label %for.body.7988, label %for.end.7990
for.body.7988:
  %t.7997 = load i64, ptr %g.addr
  %t.7998 = load i64, ptr %arena.addr
  %t.7999 = load i64, ptr %s.addr
  %t.8000 = load i32, ptr %i.274
  %cast.8001 = sext i32 %t.8000 to i64
  %r.8002 = call i64 @Child(i64 %t.7998, i64 %t.7999, i64 %cast.8001)
  %t.8003 = load i64, ptr %arena.addr
  %t.8004 = load i64, ptr %locals.addr
  %t.8005 = load ptr, ptr %fnName.addr
  %r.8006 = call i64 @InferStmt(i64 %t.7997, i64 %r.8002, i64 %t.8003, i64 %t.8004, ptr %t.8005)
  br label %for.inc.7989
for.inc.7989:
  %t.8007 = load i32, ptr %i.274
  %t.8008 = add i32 %t.8007, 1
  store i32 %t.8008, ptr %i.274
  br label %for.cond.7987
for.end.7990:
  %ext.8009 = sext i32 0 to i64
  ret i64 %ext.8009
dead.8010:
  br label %if.merge.7986
if.merge.7986:
  %t.8011 = load i64, ptr %s.addr
  %r.8012 = call i64 @kx_struct_get(i64 %t.8011, i32 0)
  %field.8013 = inttoptr i64 %r.8012 to ptr
  %r.8015 = call i1 @kx_str_eq(ptr %field.8013, ptr @.str.35)
  br i1 %r.8015, label %if.then.8016, label %if.merge.8017
if.then.8016:
  %t.8018 = load i64, ptr %locals.addr
  %t.8019 = load i64, ptr %arena.addr
  %t.8020 = load i64, ptr %s.addr
  %cast.8021 = sext i32 0 to i64
  %r.8022 = call i64 @Child(i64 %t.8019, i64 %t.8020, i64 %cast.8021)
  %r.8023 = call i64 @kx_struct_get(i64 %r.8022, i32 1)
  %field.8024 = inttoptr i64 %r.8023 to ptr
  %c.8025 = ptrtoint ptr %field.8024 to i64
  %c.8026 = ptrtoint ptr @.str.269 to i64
  call void @kx_map_set(i64 %t.8018, i64 %c.8025, i64 %c.8026)
  %t.8027 = load i64, ptr %g.addr
  %t.8028 = load i64, ptr %arena.addr
  %t.8029 = load i64, ptr %s.addr
  %cast.8030 = sext i32 1 to i64
  %r.8031 = call i64 @Child(i64 %t.8028, i64 %t.8029, i64 %cast.8030)
  %t.8032 = load i64, ptr %arena.addr
  %t.8033 = load i64, ptr %locals.addr
  %t.8034 = load ptr, ptr %fnName.addr
  %r.8035 = call ptr @InferExprType(i64 %t.8027, i64 %r.8031, i64 %t.8032, i64 %t.8033, ptr %t.8034)
  %t.8036 = load i64, ptr %g.addr
  %t.8037 = load i64, ptr %arena.addr
  %t.8038 = load i64, ptr %s.addr
  %cast.8039 = sext i32 2 to i64
  %r.8040 = call i64 @Child(i64 %t.8037, i64 %t.8038, i64 %cast.8039)
  %t.8041 = load i64, ptr %arena.addr
  %t.8042 = load i64, ptr %locals.addr
  %t.8043 = load ptr, ptr %fnName.addr
  %r.8044 = call i64 @InferStmt(i64 %t.8036, i64 %r.8040, i64 %t.8041, i64 %t.8042, ptr %t.8043)
  %ext.8045 = sext i32 0 to i64
  ret i64 %ext.8045
dead.8046:
  br label %if.merge.8017
if.merge.8017:
  %ext.8047 = sext i32 0 to i64
  ret i64 %ext.8047
dead.8048:
  ret i64 0
}

define i64 @InferSignatures(i64 %g, i64 %root, i64 %arena) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %root.addr = alloca i64
  store i64 %root, ptr %root.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %i.275 = alloca i32
  store i32 0, ptr %i.275
  br label %for.cond.8049
for.cond.8049:
  %t.8053 = load i32, ptr %i.275
  %t.8054 = load i64, ptr %root.addr
  %r.8055 = call i64 @kx_list_size(i64 %t.8054)
  %ext.8056 = sext i32 %t.8053 to i64
  %t.8057 = icmp slt i64 %ext.8056, %r.8055
  br i1 %t.8057, label %for.body.8050, label %for.end.8052
for.body.8050:
  %t.8058 = load i64, ptr %arena.addr
  %t.8059 = load i64, ptr %root.addr
  %t.8060 = load i32, ptr %i.275
  %cast.8061 = sext i32 %t.8060 to i64
  %r.8062 = call i64 @Child(i64 %t.8058, i64 %t.8059, i64 %cast.8061)
  %d.276 = alloca i64
  store i64 %r.8062, ptr %d.276
  %t.8063 = load i64, ptr %d.276
  %ext.8065 = inttoptr i64 %t.8063 to ptr
  %r.8066 = call i1 @kx_str_eq(ptr %ext.8065, ptr @.str.208)
  br i1 %r.8066, label %if.then.8067, label %if.merge.8068
if.then.8067:
  %t.8069 = load i64, ptr %arena.addr
  %t.8070 = load i64, ptr %d.276
  %cast.8071 = sext i32 0 to i64
  %r.8072 = call i64 @Child(i64 %t.8069, i64 %t.8070, i64 %cast.8071)
  %r.8073 = call i64 @kx_struct_get(i64 %r.8072, i32 1)
  %field.8074 = inttoptr i64 %r.8073 to ptr
  %name.277 = alloca ptr
  store ptr %field.8074, ptr %name.277
  %t.8075 = load i64, ptr %arena.addr
  %t.8076 = load i64, ptr %d.276
  %cast.8077 = sext i32 1 to i64
  %r.8078 = call i64 @Child(i64 %t.8075, i64 %t.8076, i64 %cast.8077)
  %r.8079 = call i64 @kx_struct_get(i64 %r.8078, i32 1)
  %field.8080 = inttoptr i64 %r.8079 to ptr
  %ret.278 = alloca ptr
  store ptr %field.8080, ptr %ret.278
  %params.279 = alloca ptr
  store ptr @.str.12, ptr %params.279
  %j.280 = alloca i32
  store i32 2, ptr %j.280
  br label %for.cond.8081
for.cond.8081:
  %t.8085 = load i32, ptr %j.280
  %t.8086 = load i64, ptr %d.276
  %r.8087 = call i64 @kx_list_size(i64 %t.8086)
  %ext.8088 = sext i32 %t.8085 to i64
  %t.8089 = icmp slt i64 %ext.8088, %r.8087
  br i1 %t.8089, label %for.body.8082, label %for.end.8084
for.body.8082:
  %t.8090 = load i64, ptr %arena.addr
  %t.8091 = load i64, ptr %d.276
  %t.8092 = load i32, ptr %j.280
  %cast.8093 = sext i32 %t.8092 to i64
  %r.8094 = call i64 @Child(i64 %t.8090, i64 %t.8091, i64 %cast.8093)
  %c.281 = alloca i64
  store i64 %r.8094, ptr %c.281
  %t.8095 = load i64, ptr %c.281
  %ext.8097 = inttoptr i64 %t.8095 to ptr
  %r.8098 = call i1 @kx_str_eq(ptr %ext.8097, ptr @.str.211)
  br i1 %r.8098, label %if.then.8099, label %if.merge.8100
if.then.8099:
  %t.8101 = load ptr, ptr %params.279
  %r.8103 = call i1 @kx_str_eq(ptr %t.8101, ptr @.str.12)
  br i1 %r.8103, label %if.then.8104, label %if.merge.8105
if.then.8104:
  %t.8106 = load ptr, ptr %params.279
  %r.8108 = call ptr @kx_str_cat(ptr %t.8106, ptr @.str.97)
  store ptr %r.8108, ptr %params.279
  br label %if.merge.8105
if.merge.8105:
  %t.8109 = load ptr, ptr %params.279
  %r.8111 = call ptr @kx_str_cat(ptr %t.8109, ptr @.str.269)
  store ptr %r.8111, ptr %params.279
  br label %if.merge.8100
if.merge.8100:
  br label %for.inc.8083
for.inc.8083:
  %t.8112 = load i32, ptr %j.280
  %t.8113 = add i32 %t.8112, 1
  store i32 %t.8113, ptr %j.280
  br label %for.cond.8081
for.end.8084:
  %t.8114 = load i64, ptr %g.addr
  %t.8115 = load ptr, ptr %name.277
  %t.8116 = load ptr, ptr %ret.278
  %r.8118 = call i1 @kx_str_eq(ptr %t.8116, ptr @.str.23)
  br i1 %r.8118, label %tern.then.8119, label %tern.else.8120
tern.then.8119:
  br label %tern.merge.8121
tern.else.8120:
  br label %tern.merge.8121
tern.merge.8121:
  %phi.8122 = phi ptr [@.str.23, %tern.then.8119], [@.str.269, %tern.else.8120]
  %r.8124 = call ptr @kx_str_cat(ptr %phi.8122, ptr @.str.284)
  %t.8125 = load ptr, ptr %params.279
  %r.8127 = call ptr @kx_str_cat(ptr %r.8124, ptr %t.8125)
  %c.8128 = ptrtoint ptr %t.8115 to i64
  %c.8129 = ptrtoint ptr %r.8127 to i64
  call void @kx_map_set(i64 %t.8114, i64 %c.8128, i64 %c.8129)
  br label %if.merge.8068
if.merge.8068:
  br label %for.inc.8051
for.inc.8051:
  %t.8130 = load i32, ptr %i.275
  %t.8131 = add i32 %t.8130, 1
  store i32 %t.8131, ptr %i.275
  br label %for.cond.8049
for.end.8052:
  %pass.282 = alloca i32
  store i32 0, ptr %pass.282
  br label %for.cond.8132
for.cond.8132:
  %t.8136 = load i32, ptr %pass.282
  %t.8137 = icmp slt i32 %t.8136, 8
  br i1 %t.8137, label %for.body.8133, label %for.end.8135
for.body.8133:
  %i.283 = alloca i32
  store i32 0, ptr %i.283
  br label %for.cond.8138
for.cond.8138:
  %t.8142 = load i32, ptr %i.283
  %t.8143 = load i64, ptr %root.addr
  %r.8144 = call i64 @kx_list_size(i64 %t.8143)
  %ext.8145 = sext i32 %t.8142 to i64
  %t.8146 = icmp slt i64 %ext.8145, %r.8144
  br i1 %t.8146, label %for.body.8139, label %for.end.8141
for.body.8139:
  %t.8147 = load i64, ptr %arena.addr
  %t.8148 = load i64, ptr %root.addr
  %t.8149 = load i32, ptr %i.283
  %cast.8150 = sext i32 %t.8149 to i64
  %r.8151 = call i64 @Child(i64 %t.8147, i64 %t.8148, i64 %cast.8150)
  %d.284 = alloca i64
  store i64 %r.8151, ptr %d.284
  %t.8152 = load i64, ptr %d.284
  %ext.8154 = inttoptr i64 %t.8152 to ptr
  %r.8155 = call i1 @kx_str_eq(ptr %ext.8154, ptr @.str.208)
  br i1 %r.8155, label %if.then.8156, label %if.merge.8157
if.then.8156:
  %t.8158 = load i64, ptr %arena.addr
  %t.8159 = load i64, ptr %d.284
  %cast.8160 = sext i32 0 to i64
  %r.8161 = call i64 @Child(i64 %t.8158, i64 %t.8159, i64 %cast.8160)
  %r.8162 = call i64 @kx_struct_get(i64 %r.8161, i32 1)
  %field.8163 = inttoptr i64 %r.8162 to ptr
  %name.285 = alloca ptr
  store ptr %field.8163, ptr %name.285
  %r.8164 = call i64 @kx_map_new(i32 0, i32 0)
  %locals.286 = alloca i64
  store i64 %r.8164, ptr %locals.286
  %t.8165 = load i64, ptr %g.addr
  %t.8166 = load ptr, ptr %name.285
  %c.8168 = ptrtoint ptr %t.8166 to i64
  %r.8167 = call i64 @kx_map_get(i64 %t.8165, i64 %c.8168)
  %cast.8169 = inttoptr i64 %r.8167 to ptr
  %r.8170 = call i64 @SigParams(ptr %cast.8169)
  %ps.287 = alloca i64
  store i64 %r.8170, ptr %ps.287
  %pidx.288 = alloca i32
  store i32 0, ptr %pidx.288
  %j.289 = alloca i32
  store i32 2, ptr %j.289
  br label %for.cond.8171
for.cond.8171:
  %t.8175 = load i32, ptr %j.289
  %t.8176 = load i64, ptr %d.284
  %r.8177 = call i64 @kx_list_size(i64 %t.8176)
  %ext.8178 = sext i32 %t.8175 to i64
  %t.8179 = icmp slt i64 %ext.8178, %r.8177
  br i1 %t.8179, label %for.body.8172, label %for.end.8174
for.body.8172:
  %t.8180 = load i64, ptr %arena.addr
  %t.8181 = load i64, ptr %d.284
  %t.8182 = load i32, ptr %j.289
  %cast.8183 = sext i32 %t.8182 to i64
  %r.8184 = call i64 @Child(i64 %t.8180, i64 %t.8181, i64 %cast.8183)
  %c.290 = alloca i64
  store i64 %r.8184, ptr %c.290
  %t.8185 = load i64, ptr %c.290
  %ext.8187 = inttoptr i64 %t.8185 to ptr
  %r.8188 = call i1 @kx_str_eq(ptr %ext.8187, ptr @.str.211)
  br i1 %r.8188, label %if.then.8189, label %if.merge.8190
if.then.8189:
  %t.8191 = load i64, ptr %locals.286
  %t.8192 = load i64, ptr %c.290
  %t.8193 = load i64, ptr %ps.287
  %t.8194 = load i32, ptr %pidx.288
  %ext.8196 = sext i32 %t.8194 to i64
  %r.8195 = call i64 @kx_list_get(i64 %t.8193, i64 %ext.8196)
  call void @kx_list_set(i64 %t.8191, i64 %t.8192, i64 %r.8195)
  %t.8197 = load i32, ptr %pidx.288
  %t.8198 = add i32 %t.8197, 1
  store i32 %t.8198, ptr %pidx.288
  br label %if.merge.8190
if.merge.8190:
  br label %for.inc.8173
for.inc.8173:
  %t.8199 = load i32, ptr %j.289
  %t.8200 = add i32 %t.8199, 1
  store i32 %t.8200, ptr %j.289
  br label %for.cond.8171
for.end.8174:
  %t.8201 = load i64, ptr %g.addr
  %t.8202 = load i64, ptr %arena.addr
  %t.8203 = load i64, ptr %d.284
  %t.8204 = load i64, ptr %d.284
  %r.8205 = call i64 @kx_list_size(i64 %t.8204)
  %ext.8206 = sext i32 1 to i64
  %t.8207 = sub i64 %r.8205, %ext.8206
  %r.8208 = call i64 @Child(i64 %t.8202, i64 %t.8203, i64 %t.8207)
  %t.8209 = load i64, ptr %arena.addr
  %t.8210 = load i64, ptr %locals.286
  %t.8211 = load ptr, ptr %name.285
  %r.8212 = call i64 @InferStmt(i64 %t.8201, i64 %r.8208, i64 %t.8209, i64 %t.8210, ptr %t.8211)
  store i32 0, ptr %pidx.288
  %j.291 = alloca i32
  store i32 2, ptr %j.291
  br label %for.cond.8213
for.cond.8213:
  %t.8217 = load i32, ptr %j.291
  %t.8218 = load i64, ptr %d.284
  %r.8219 = call i64 @kx_list_size(i64 %t.8218)
  %ext.8220 = sext i32 %t.8217 to i64
  %t.8221 = icmp slt i64 %ext.8220, %r.8219
  br i1 %t.8221, label %for.body.8214, label %for.end.8216
for.body.8214:
  %t.8222 = load i64, ptr %arena.addr
  %t.8223 = load i64, ptr %d.284
  %t.8224 = load i32, ptr %j.291
  %cast.8225 = sext i32 %t.8224 to i64
  %r.8226 = call i64 @Child(i64 %t.8222, i64 %t.8223, i64 %cast.8225)
  %c.292 = alloca i64
  store i64 %r.8226, ptr %c.292
  %t.8227 = load i64, ptr %c.292
  %ext.8229 = inttoptr i64 %t.8227 to ptr
  %r.8230 = call i1 @kx_str_eq(ptr %ext.8229, ptr @.str.211)
  br i1 %r.8230, label %if.then.8231, label %if.merge.8232
if.then.8231:
  %t.8233 = load i64, ptr %locals.286
  %t.8234 = load i64, ptr %c.292
  %r.8235 = call i1 @kx_map_has(i64 %t.8233, i64 %t.8234)
  br i1 %r.8235, label %if.then.8236, label %if.merge.8237
if.then.8236:
  %t.8238 = load i64, ptr %g.addr
  %t.8239 = load ptr, ptr %name.285
  %t.8240 = load i32, ptr %pidx.288
  %cast.8241 = sext i32 %t.8240 to i64
  %t.8242 = load i64, ptr %locals.286
  %t.8243 = load i64, ptr %c.292
  %r.8244 = call i64 @kx_list_get(i64 %t.8242, i64 %t.8243)
  %cast.8245 = inttoptr i64 %r.8244 to ptr
  %r.8246 = call i64 @SigSetParam(i64 %t.8238, ptr %t.8239, i64 %cast.8241, ptr %cast.8245)
  br label %if.merge.8237
if.merge.8237:
  %t.8247 = load i32, ptr %pidx.288
  %t.8248 = add i32 %t.8247, 1
  store i32 %t.8248, ptr %pidx.288
  br label %if.merge.8232
if.merge.8232:
  br label %for.inc.8215
for.inc.8215:
  %t.8249 = load i32, ptr %j.291
  %t.8250 = add i32 %t.8249, 1
  store i32 %t.8250, ptr %j.291
  br label %for.cond.8213
for.end.8216:
  %t.8251 = load i64, ptr %g.addr
  %t.8252 = load ptr, ptr %name.285
  %c.8254 = ptrtoint ptr %t.8252 to i64
  %r.8253 = call i64 @kx_map_get(i64 %t.8251, i64 %c.8254)
  %sig.293 = alloca i64
  store i64 %r.8253, ptr %sig.293
  %t.8255 = load i64, ptr %sig.293
  %cast.8256 = inttoptr i64 %t.8255 to ptr
  %r.8257 = call i64 @SigParams(ptr %cast.8256)
  %currentParams.294 = alloca i64
  store i64 %r.8257, ptr %currentParams.294
  %t.8258 = load i64, ptr %g.addr
  %t.8259 = load ptr, ptr %name.285
  %t.8260 = load i64, ptr %sig.293
  %cast.8261 = inttoptr i64 %t.8260 to ptr
  %r.8262 = call i64 @SigRet(ptr %cast.8261)
  %ext.8264 = call ptr @kx_int_str(i64 %r.8262)
  %r.8265 = call ptr @kx_str_cat(ptr %ext.8264, ptr @.str.284)
  %t.8266 = load i64, ptr %currentParams.294
  %r.8267 = call ptr @JoinParts(i64 %t.8266, ptr @.str.97)
  %r.8269 = call ptr @kx_str_cat(ptr %r.8265, ptr %r.8267)
  %c.8270 = ptrtoint ptr %t.8259 to i64
  %c.8271 = ptrtoint ptr %r.8269 to i64
  call void @kx_map_set(i64 %t.8258, i64 %c.8270, i64 %c.8271)
  br label %if.merge.8157
if.merge.8157:
  br label %for.inc.8140
for.inc.8140:
  %t.8272 = load i32, ptr %i.283
  %t.8273 = add i32 %t.8272, 1
  store i32 %t.8273, ptr %i.283
  br label %for.cond.8138
for.end.8141:
  br label %for.inc.8134
for.inc.8134:
  %t.8274 = load i32, ptr %pass.282
  %t.8275 = add i32 %t.8274, 1
  store i32 %t.8275, ptr %pass.282
  br label %for.cond.8132
for.end.8135:
  %ext.8276 = sext i32 0 to i64
  ret i64 %ext.8276
dead.8277:
  ret i64 0
}

define i64 @NewIR() {
entry:
  %r.8278 = call i64 @kx_list_new(i32 0)
  %sc.295 = alloca i64
  store i64 %r.8278, ptr %sc.295
  %t.8279 = load i64, ptr %sc.295
  %ext.8280 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.8279, i64 %ext.8280)
  %r.8281 = call i64 @kx_list_new(i32 0)
  %lc.296 = alloca i64
  store i64 %r.8281, ptr %lc.296
  %t.8282 = load i64, ptr %lc.296
  %ext.8283 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.8282, i64 %ext.8283)
  %r.8284 = call i64 @kx_list_new(i32 0)
  %vc.297 = alloca i64
  store i64 %r.8284, ptr %vc.297
  %t.8285 = load i64, ptr %vc.297
  %ext.8286 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.8285, i64 %ext.8286)
  %r.8287 = call i64 @kx_list_new(i32 0)
  %terminated.298 = alloca i64
  store i64 %r.8287, ptr %terminated.298
  %t.8288 = load i64, ptr %terminated.298
  %ext.8289 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.8288, i64 %ext.8289)
  %r.8290 = call i64 @kx_struct_new(i32 17)
  %r.8291 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 0, i64 %r.8291)
  %r.8292 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 1, i64 %r.8292)
  %r.8293 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 2, i64 %r.8293)
  %t.8294 = load i64, ptr %sc.295
  call void @kx_struct_set(i64 %r.8290, i32 3, i64 %t.8294)
  %t.8295 = load i64, ptr %lc.296
  call void @kx_struct_set(i64 %r.8290, i32 4, i64 %t.8295)
  %t.8296 = load i64, ptr %vc.297
  call void @kx_struct_set(i64 %r.8290, i32 5, i64 %t.8296)
  %r.8297 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 6, i64 %r.8297)
  %r.8298 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 7, i64 %r.8298)
  %r.8299 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 8, i64 %r.8299)
  %r.8300 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 9, i64 %r.8300)
  %ext.8301 = ptrtoint ptr @.str.12 to i64
  call void @kx_struct_set(i64 %r.8290, i32 10, i64 %ext.8301)
  %ext.8302 = ptrtoint ptr @.str.12 to i64
  call void @kx_struct_set(i64 %r.8290, i32 11, i64 %ext.8302)
  %r.8303 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 12, i64 %r.8303)
  %t.8304 = load i64, ptr %terminated.298
  call void @kx_struct_set(i64 %r.8290, i32 13, i64 %t.8304)
  %r.8305 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 14, i64 %r.8305)
  %r.8306 = call i64 @kx_list_new(i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 15, i64 %r.8306)
  %r.8307 = call i64 @kx_map_new(i32 0, i32 0)
  call void @kx_struct_set(i64 %r.8290, i32 16, i64 %r.8307)
  ret i64 %r.8290
dead.8308:
  ret i64 0
}

define i64 @Emit(i64 %g, ptr %s) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %t.8309 = load i64, ptr %g.addr
  %r.8310 = call i64 @kx_struct_get(i64 %t.8309, i32 13)
  %r.8311 = call i64 @kx_list_size(i64 %r.8310)
  %ext.8312 = sext i32 0 to i64
  %t.8313 = icmp sgt i64 %r.8311, %ext.8312
  %t.8314 = load i64, ptr %g.addr
  %r.8315 = call i64 @kx_struct_get(i64 %t.8314, i32 13)
  %ext.8317 = sext i32 0 to i64
  %r.8316 = call i64 @kx_list_get(i64 %r.8315, i64 %ext.8317)
  %ext.8318 = sext i32 1 to i64
  %t.8319 = icmp eq i64 %r.8316, %ext.8318
  %t.8320 = and i1 %t.8313, %t.8319
  %t.8321 = load ptr, ptr %s.addr
  %r.8323 = call i1 @kx_str_eq(ptr %t.8321, ptr @.str.64)
  %t.8324 = and i1 %t.8320, %r.8323
  %t.8325 = load ptr, ptr %s.addr
  %r.8326 = call i1 @kx_str_ends_with(ptr %t.8325, ptr @.str.89)
  %t.8327 = xor i1 %r.8326, true
  %t.8328 = and i1 %t.8324, %t.8327
  br i1 %t.8328, label %if.then.8329, label %if.merge.8330
if.then.8329:
  %t.8331 = load i64, ptr %g.addr
  %r.8332 = call i64 @kx_struct_get(i64 %t.8331, i32 4)
  %t.8333 = load i64, ptr %g.addr
  %r.8334 = call i64 @kx_struct_get(i64 %t.8333, i32 4)
  %ext.8336 = sext i32 0 to i64
  %r.8335 = call i64 @kx_list_get(i64 %r.8334, i64 %ext.8336)
  %ext.8337 = sext i32 1 to i64
  %t.8338 = add i64 %r.8335, %ext.8337
  %ext.8339 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.8332, i64 %ext.8339, i64 %t.8338)
  %t.8340 = load i64, ptr %g.addr
  %r.8341 = call i64 @kx_struct_get(i64 %t.8340, i32 0)
  %t.8342 = load i64, ptr %g.addr
  %r.8343 = call i64 @kx_struct_get(i64 %t.8342, i32 4)
  %ext.8345 = sext i32 0 to i64
  %r.8344 = call i64 @kx_list_get(i64 %r.8343, i64 %ext.8345)
  %r.8346 = call ptr @kx_int_str(i64 %r.8344)
  %r.8348 = call ptr @kx_str_cat(ptr @.str.318, ptr %r.8346)
  %r.8350 = call ptr @kx_str_cat(ptr %r.8348, ptr @.str.89)
  %ext.8351 = ptrtoint ptr %r.8350 to i64
  call void @kx_list_add(i64 %r.8341, i64 %ext.8351)
  %t.8352 = load i64, ptr %g.addr
  %r.8353 = call i64 @kx_struct_get(i64 %t.8352, i32 13)
  %ext.8354 = sext i32 0 to i64
  %ext.8355 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.8353, i64 %ext.8354, i64 %ext.8355)
  br label %if.merge.8330
if.merge.8330:
  %t.8356 = load i64, ptr %g.addr
  %r.8357 = call i64 @kx_struct_get(i64 %t.8356, i32 0)
  %t.8358 = load ptr, ptr %s.addr
  %ext.8359 = ptrtoint ptr %t.8358 to i64
  call void @kx_list_add(i64 %r.8357, i64 %ext.8359)
  %t.8360 = load ptr, ptr %s.addr
  %r.8361 = call i1 @kx_str_starts_with(ptr %t.8360, ptr @.str.319)
  %t.8362 = load ptr, ptr %s.addr
  %r.8363 = call i1 @kx_str_starts_with(ptr %t.8362, ptr @.str.320)
  %t.8364 = or i1 %r.8361, %r.8363
  %t.8365 = load ptr, ptr %s.addr
  %r.8367 = call i1 @kx_str_eq(ptr %t.8365, ptr @.str.321)
  %t.8368 = or i1 %t.8364, %r.8367
  br i1 %t.8368, label %if.then.8369, label %if.else.8371
if.then.8369:
  %t.8372 = load i64, ptr %g.addr
  %r.8373 = call i64 @kx_struct_get(i64 %t.8372, i32 13)
  %ext.8374 = sext i32 0 to i64
  %ext.8375 = sext i32 1 to i64
  call void @kx_list_set(i64 %r.8373, i64 %ext.8374, i64 %ext.8375)
  br label %if.merge.8370
if.else.8371:
  %t.8376 = load ptr, ptr %s.addr
  %r.8378 = call i1 @kx_str_eq(ptr %t.8376, ptr @.str.64)
  %t.8379 = load ptr, ptr %s.addr
  %r.8380 = call i1 @kx_str_ends_with(ptr %t.8379, ptr @.str.89)
  %t.8381 = or i1 %r.8378, %r.8380
  br i1 %t.8381, label %if.then.8382, label %if.merge.8383
if.then.8382:
  %t.8384 = load i64, ptr %g.addr
  %r.8385 = call i64 @kx_struct_get(i64 %t.8384, i32 13)
  %ext.8386 = sext i32 0 to i64
  %ext.8387 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.8385, i64 %ext.8386, i64 %ext.8387)
  br label %if.merge.8383
if.merge.8383:
  br label %if.merge.8370
if.merge.8370:
  %ext.8388 = sext i32 0 to i64
  ret i64 %ext.8388
dead.8389:
  ret i64 0
}

define ptr @Lbl(i64 %g, ptr %p) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %p.addr = alloca ptr
  store ptr %p, ptr %p.addr
  %t.8390 = load i64, ptr %g.addr
  %t.8391 = load i64, ptr %g.addr
  %ext.8393 = sext i32 0 to i64
  %r.8392 = call i64 @kx_list_get(i64 %t.8391, i64 %ext.8393)
  %ext.8394 = sext i32 1 to i64
  %t.8395 = add i64 %r.8392, %ext.8394
  %ext.8396 = sext i32 0 to i64
  call void @kx_list_set(i64 %t.8390, i64 %ext.8396, i64 %t.8395)
  %t.8397 = load ptr, ptr %p.addr
  %r.8399 = call ptr @kx_str_cat(ptr %t.8397, ptr @.str.60)
  %t.8400 = load i64, ptr %g.addr
  %ext.8402 = sext i32 0 to i64
  %r.8401 = call i64 @kx_list_get(i64 %t.8400, i64 %ext.8402)
  %r.8403 = call ptr @kx_int_str(i64 %r.8401)
  %r.8405 = call ptr @kx_str_cat(ptr %r.8399, ptr %r.8403)
  ret ptr %r.8405
dead.8406:
  ret ptr null
}

define ptr @EscStr(ptr %s) {
entry:
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %o.299 = alloca ptr
  store ptr @.str.12, ptr %o.299
  %i.300 = alloca i32
  store i32 0, ptr %i.300
  br label %w.cond.8407
w.cond.8407:
  %t.8410 = load i32, ptr %i.300
  %t.8411 = load ptr, ptr %s.addr
  %r.8412 = call i64 @kx_str_len(ptr %t.8411)
  %ext.8413 = sext i32 %t.8410 to i64
  %t.8414 = icmp slt i64 %ext.8413, %r.8412
  br i1 %t.8414, label %w.body.8408, label %w.end.8409
w.body.8408:
  %t.8415 = load ptr, ptr %s.addr
  %t.8416 = load i32, ptr %i.300
  %ext.8417 = sext i32 %t.8416 to i64
  %ext.8418 = sext i32 1 to i64
  %r.8419 = call ptr @kx_str_substr(ptr %t.8415, i64 %ext.8417, i64 %ext.8418)
  %c.301 = alloca ptr
  store ptr %r.8419, ptr %c.301
  %t.8420 = load ptr, ptr %c.301
  %r.8422 = call i1 @kx_str_eq(ptr %t.8420, ptr @.str.65)
  %t.8423 = load i32, ptr %i.300
  %t.8424 = add i32 %t.8423, 1
  %t.8425 = load ptr, ptr %s.addr
  %r.8426 = call i64 @kx_str_len(ptr %t.8425)
  %ext.8427 = sext i32 %t.8424 to i64
  %t.8428 = icmp slt i64 %ext.8427, %r.8426
  %t.8429 = and i1 %r.8422, %t.8428
  br i1 %t.8429, label %if.then.8430, label %if.merge.8431
if.then.8430:
  %t.8432 = load ptr, ptr %s.addr
  %t.8433 = load i32, ptr %i.300
  %t.8434 = add i32 %t.8433, 1
  %ext.8435 = sext i32 %t.8434 to i64
  %ext.8436 = sext i32 1 to i64
  %r.8437 = call ptr @kx_str_substr(ptr %t.8432, i64 %ext.8435, i64 %ext.8436)
  %n.302 = alloca ptr
  store ptr %r.8437, ptr %n.302
  %t.8438 = load ptr, ptr %n.302
  %r.8440 = call i1 @kx_str_eq(ptr %t.8438, ptr @.str.67)
  br i1 %r.8440, label %if.then.8441, label %if.merge.8442
if.then.8441:
  %t.8443 = load ptr, ptr %o.299
  %r.8445 = call ptr @kx_str_cat(ptr %t.8443, ptr @.str.322)
  store ptr %r.8445, ptr %o.299
  %t.8446 = load i32, ptr %i.300
  %t.8447 = add i32 %t.8446, 2
  store i32 %t.8447, ptr %i.300
  br label %w.cond.8407
dead.8448:
  br label %if.merge.8442
if.merge.8442:
  %t.8449 = load ptr, ptr %n.302
  %r.8451 = call i1 @kx_str_eq(ptr %t.8449, ptr @.str.68)
  br i1 %r.8451, label %if.then.8452, label %if.merge.8453
if.then.8452:
  %t.8454 = load ptr, ptr %o.299
  %r.8456 = call ptr @kx_str_cat(ptr %t.8454, ptr @.str.323)
  store ptr %r.8456, ptr %o.299
  %t.8457 = load i32, ptr %i.300
  %t.8458 = add i32 %t.8457, 2
  store i32 %t.8458, ptr %i.300
  br label %w.cond.8407
dead.8459:
  br label %if.merge.8453
if.merge.8453:
  %t.8460 = load ptr, ptr %n.302
  %r.8462 = call i1 @kx_str_eq(ptr %t.8460, ptr @.str.65)
  br i1 %r.8462, label %if.then.8463, label %if.merge.8464
if.then.8463:
  %t.8465 = load ptr, ptr %o.299
  %r.8467 = call ptr @kx_str_cat(ptr %t.8465, ptr @.str.324)
  store ptr %r.8467, ptr %o.299
  %t.8468 = load i32, ptr %i.300
  %t.8469 = add i32 %t.8468, 2
  store i32 %t.8469, ptr %i.300
  br label %w.cond.8407
dead.8470:
  br label %if.merge.8464
if.merge.8464:
  %t.8471 = load ptr, ptr %n.302
  %r.8473 = call i1 @kx_str_eq(ptr %t.8471, ptr @.str.1)
  br i1 %r.8473, label %if.then.8474, label %if.merge.8475
if.then.8474:
  %t.8476 = load ptr, ptr %o.299
  %r.8478 = call ptr @kx_str_cat(ptr %t.8476, ptr @.str.325)
  store ptr %r.8478, ptr %o.299
  %t.8479 = load i32, ptr %i.300
  %t.8480 = add i32 %t.8479, 2
  store i32 %t.8480, ptr %i.300
  br label %w.cond.8407
dead.8481:
  br label %if.merge.8475
if.merge.8475:
  %t.8482 = load ptr, ptr %n.302
  %r.8484 = call i1 @kx_str_eq(ptr %t.8482, ptr @.str.62)
  br i1 %r.8484, label %if.then.8485, label %if.merge.8486
if.then.8485:
  %t.8487 = load ptr, ptr %o.299
  %r.8489 = call ptr @kx_str_cat(ptr %t.8487, ptr @.str.326)
  store ptr %r.8489, ptr %o.299
  %t.8490 = load i32, ptr %i.300
  %t.8491 = add i32 %t.8490, 2
  store i32 %t.8491, ptr %i.300
  br label %w.cond.8407
dead.8492:
  br label %if.merge.8486
if.merge.8486:
  br label %if.merge.8431
if.merge.8431:
  %t.8493 = load ptr, ptr %c.301
  %r.8495 = call i1 @kx_str_eq(ptr %t.8493, ptr @.str.62)
  br i1 %r.8495, label %if.then.8496, label %if.merge.8497
if.then.8496:
  %t.8498 = load i32, ptr %i.300
  %t.8499 = add i32 %t.8498, 1
  store i32 %t.8499, ptr %i.300
  br label %w.cond.8407
dead.8500:
  br label %if.merge.8497
if.merge.8497:
  %t.8501 = load ptr, ptr %c.301
  %r.8503 = call i1 @kx_str_eq(ptr %t.8501, ptr @.str.10)
  br i1 %r.8503, label %if.then.8504, label %if.merge.8505
if.then.8504:
  %t.8506 = load ptr, ptr %o.299
  %r.8508 = call ptr @kx_str_cat(ptr %t.8506, ptr @.str.322)
  store ptr %r.8508, ptr %o.299
  %t.8509 = load i32, ptr %i.300
  %t.8510 = add i32 %t.8509, 1
  store i32 %t.8510, ptr %i.300
  br label %w.cond.8407
dead.8511:
  br label %if.merge.8505
if.merge.8505:
  %t.8512 = load ptr, ptr %c.301
  %r.8514 = call i1 @kx_str_eq(ptr %t.8512, ptr @.str.9)
  br i1 %r.8514, label %if.then.8515, label %if.merge.8516
if.then.8515:
  %t.8517 = load ptr, ptr %o.299
  %r.8519 = call ptr @kx_str_cat(ptr %t.8517, ptr @.str.323)
  store ptr %r.8519, ptr %o.299
  %t.8520 = load i32, ptr %i.300
  %t.8521 = add i32 %t.8520, 1
  store i32 %t.8521, ptr %i.300
  br label %w.cond.8407
dead.8522:
  br label %if.merge.8516
if.merge.8516:
  %t.8523 = load ptr, ptr %c.301
  %r.8525 = call i1 @kx_str_eq(ptr %t.8523, ptr @.str.327)
  br i1 %r.8525, label %if.then.8526, label %if.merge.8527
if.then.8526:
  %t.8528 = load ptr, ptr %o.299
  %r.8530 = call ptr @kx_str_cat(ptr %t.8528, ptr @.str.325)
  store ptr %r.8530, ptr %o.299
  %t.8531 = load i32, ptr %i.300
  %t.8532 = add i32 %t.8531, 1
  store i32 %t.8532, ptr %i.300
  br label %w.cond.8407
dead.8533:
  br label %if.merge.8527
if.merge.8527:
  %t.8534 = load ptr, ptr %o.299
  %t.8535 = load ptr, ptr %c.301
  %r.8537 = call ptr @kx_str_cat(ptr %t.8534, ptr %t.8535)
  store ptr %r.8537, ptr %o.299
  %t.8538 = load i32, ptr %i.300
  %t.8539 = add i32 %t.8538, 1
  store i32 %t.8539, ptr %i.300
  br label %w.cond.8407
w.end.8409:
  %t.8540 = load ptr, ptr %o.299
  ret ptr %t.8540
dead.8541:
  ret ptr null
}

define ptr @GetStr(i64 %g, ptr %s) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %s.addr = alloca ptr
  store ptr %s, ptr %s.addr
  %t.8542 = load i64, ptr %g.addr
  %r.8543 = call i64 @kx_struct_get(i64 %t.8542, i32 1)
  %t.8544 = load ptr, ptr %s.addr
  %c.8545 = ptrtoint ptr %t.8544 to i64
  %r.8546 = call i1 @kx_map_has(i64 %r.8543, i64 %c.8545)
  br i1 %r.8546, label %if.then.8547, label %if.merge.8548
if.then.8547:
  %t.8549 = load i64, ptr %g.addr
  %r.8550 = call i64 @kx_struct_get(i64 %t.8549, i32 1)
  %t.8551 = load ptr, ptr %s.addr
  %c.8553 = ptrtoint ptr %t.8551 to i64
  %r.8552 = call i64 @kx_map_get(i64 %r.8550, i64 %c.8553)
  %ext.8554 = inttoptr i64 %r.8552 to ptr
  ret ptr %ext.8554
dead.8555:
  br label %if.merge.8548
if.merge.8548:
  %t.8556 = load i64, ptr %g.addr
  %r.8557 = call i64 @kx_struct_get(i64 %t.8556, i32 3)
  %t.8558 = load i64, ptr %g.addr
  %r.8559 = call i64 @kx_struct_get(i64 %t.8558, i32 3)
  %ext.8561 = sext i32 0 to i64
  %r.8560 = call i64 @kx_list_get(i64 %r.8559, i64 %ext.8561)
  %ext.8562 = sext i32 1 to i64
  %t.8563 = add i64 %r.8560, %ext.8562
  %ext.8564 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.8557, i64 %ext.8564, i64 %t.8563)
  %t.8565 = load i64, ptr %g.addr
  %r.8566 = call i64 @kx_struct_get(i64 %t.8565, i32 3)
  %ext.8568 = sext i32 0 to i64
  %r.8567 = call i64 @kx_list_get(i64 %r.8566, i64 %ext.8568)
  %r.8569 = call ptr @kx_int_str(i64 %r.8567)
  %r.8571 = call ptr @kx_str_cat(ptr @.str.328, ptr %r.8569)
  %nm.303 = alloca ptr
  store ptr %r.8571, ptr %nm.303
  %t.8572 = load i64, ptr %g.addr
  %r.8573 = call i64 @kx_struct_get(i64 %t.8572, i32 1)
  %t.8574 = load ptr, ptr %s.addr
  %t.8575 = load ptr, ptr %nm.303
  %c.8576 = ptrtoint ptr %t.8574 to i64
  %c.8577 = ptrtoint ptr %t.8575 to i64
  call void @kx_map_set(i64 %r.8573, i64 %c.8576, i64 %c.8577)
  %raw.304 = alloca ptr
  store ptr @.str.12, ptr %raw.304
  %i.305 = alloca i32
  store i32 0, ptr %i.305
  br label %w.cond.8578
w.cond.8578:
  %t.8581 = load i32, ptr %i.305
  %t.8582 = load ptr, ptr %s.addr
  %r.8583 = call i64 @kx_str_len(ptr %t.8582)
  %ext.8584 = sext i32 %t.8581 to i64
  %t.8585 = icmp slt i64 %ext.8584, %r.8583
  br i1 %t.8585, label %w.body.8579, label %w.end.8580
w.body.8579:
  %t.8586 = load ptr, ptr %s.addr
  %t.8587 = load i32, ptr %i.305
  %ext.8588 = sext i32 %t.8587 to i64
  %ext.8589 = sext i32 1 to i64
  %r.8590 = call ptr @kx_str_substr(ptr %t.8586, i64 %ext.8588, i64 %ext.8589)
  %c.306 = alloca ptr
  store ptr %r.8590, ptr %c.306
  %t.8591 = load ptr, ptr %c.306
  %r.8593 = call i1 @kx_str_eq(ptr %t.8591, ptr @.str.62)
  br i1 %r.8593, label %if.then.8594, label %if.else.8596
if.then.8594:
  %t.8597 = load ptr, ptr %raw.304
  %r.8599 = call ptr @kx_str_cat(ptr %t.8597, ptr @.str.326)
  store ptr %r.8599, ptr %raw.304
  br label %if.merge.8595
if.else.8596:
  %t.8600 = load ptr, ptr %c.306
  %r.8602 = call i1 @kx_str_eq(ptr %t.8600, ptr @.str.10)
  br i1 %r.8602, label %if.then.8603, label %if.else.8605
if.then.8603:
  %t.8606 = load ptr, ptr %raw.304
  %r.8608 = call ptr @kx_str_cat(ptr %t.8606, ptr @.str.322)
  store ptr %r.8608, ptr %raw.304
  br label %if.merge.8604
if.else.8605:
  %t.8609 = load ptr, ptr %c.306
  %r.8611 = call i1 @kx_str_eq(ptr %t.8609, ptr @.str.9)
  br i1 %r.8611, label %if.then.8612, label %if.else.8614
if.then.8612:
  %t.8615 = load ptr, ptr %raw.304
  %r.8617 = call ptr @kx_str_cat(ptr %t.8615, ptr @.str.323)
  store ptr %r.8617, ptr %raw.304
  br label %if.merge.8613
if.else.8614:
  %t.8618 = load ptr, ptr %c.306
  %r.8620 = call i1 @kx_str_eq(ptr %t.8618, ptr @.str.65)
  br i1 %r.8620, label %if.then.8621, label %if.else.8623
if.then.8621:
  %t.8624 = load ptr, ptr %raw.304
  %r.8626 = call ptr @kx_str_cat(ptr %t.8624, ptr @.str.329)
  store ptr %r.8626, ptr %raw.304
  br label %if.merge.8622
if.else.8623:
  %t.8627 = load ptr, ptr %raw.304
  %t.8628 = load ptr, ptr %c.306
  %r.8630 = call ptr @kx_str_cat(ptr %t.8627, ptr %t.8628)
  store ptr %r.8630, ptr %raw.304
  br label %if.merge.8622
if.merge.8622:
  br label %if.merge.8613
if.merge.8613:
  br label %if.merge.8604
if.merge.8604:
  br label %if.merge.8595
if.merge.8595:
  %t.8631 = load i32, ptr %i.305
  %t.8632 = add i32 %t.8631, 1
  store i32 %t.8632, ptr %i.305
  br label %w.cond.8578
w.end.8580:
  %t.8633 = load ptr, ptr %s.addr
  %r.8634 = call i64 @kx_str_len(ptr %t.8633)
  %ext.8635 = sext i32 1 to i64
  %t.8636 = add i64 %r.8634, %ext.8635
  %size.307 = alloca i64
  store i64 %t.8636, ptr %size.307
  %t.8637 = load i64, ptr %g.addr
  %r.8638 = call i64 @kx_struct_get(i64 %t.8637, i32 2)
  %t.8639 = load ptr, ptr %nm.303
  %r.8641 = call ptr @kx_str_cat(ptr %t.8639, ptr @.str.330)
  %t.8642 = load i64, ptr %size.307
  %r.8643 = call ptr @kx_int_str(i64 %t.8642)
  %r.8645 = call ptr @kx_str_cat(ptr %r.8641, ptr %r.8643)
  %r.8647 = call ptr @kx_str_cat(ptr %r.8645, ptr @.str.331)
  %t.8648 = load ptr, ptr %raw.304
  %r.8650 = call ptr @kx_str_cat(ptr %r.8647, ptr %t.8648)
  %r.8652 = call ptr @kx_str_cat(ptr %r.8650, ptr @.str.332)
  %ext.8653 = ptrtoint ptr %r.8652 to i64
  call void @kx_list_add(i64 %r.8638, i64 %ext.8653)
  %t.8654 = load ptr, ptr %nm.303
  ret ptr %t.8654
dead.8655:
  ret ptr null
}

define i64 @EmitDecls(i64 %g) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %t.8656 = load i64, ptr %g.addr
  %r.8657 = call i64 @Emit(i64 %t.8656, ptr @.str.333)
  %t.8658 = load i64, ptr %g.addr
  %r.8659 = call i64 @Emit(i64 %t.8658, ptr @.str.334)
  %t.8660 = load i64, ptr %g.addr
  %r.8661 = call i64 @Emit(i64 %t.8660, ptr @.str.335)
  %t.8662 = load i64, ptr %g.addr
  %r.8663 = call i64 @Emit(i64 %t.8662, ptr @.str.336)
  %t.8664 = load i64, ptr %g.addr
  %r.8665 = call i64 @Emit(i64 %t.8664, ptr @.str.337)
  %t.8666 = load i64, ptr %g.addr
  %r.8667 = call i64 @Emit(i64 %t.8666, ptr @.str.338)
  %t.8668 = load i64, ptr %g.addr
  %r.8669 = call i64 @Emit(i64 %t.8668, ptr @.str.339)
  %t.8670 = load i64, ptr %g.addr
  %r.8671 = call i64 @Emit(i64 %t.8670, ptr @.str.340)
  %t.8672 = load i64, ptr %g.addr
  %r.8673 = call i64 @Emit(i64 %t.8672, ptr @.str.341)
  %t.8674 = load i64, ptr %g.addr
  %r.8675 = call i64 @Emit(i64 %t.8674, ptr @.str.342)
  %t.8676 = load i64, ptr %g.addr
  %r.8677 = call i64 @Emit(i64 %t.8676, ptr @.str.343)
  %t.8678 = load i64, ptr %g.addr
  %r.8679 = call i64 @Emit(i64 %t.8678, ptr @.str.344)
  %t.8680 = load i64, ptr %g.addr
  %r.8681 = call i64 @Emit(i64 %t.8680, ptr @.str.345)
  %t.8682 = load i64, ptr %g.addr
  %r.8683 = call i64 @Emit(i64 %t.8682, ptr @.str.346)
  %t.8684 = load i64, ptr %g.addr
  %r.8685 = call i64 @Emit(i64 %t.8684, ptr @.str.347)
  %t.8686 = load i64, ptr %g.addr
  %r.8687 = call i64 @Emit(i64 %t.8686, ptr @.str.348)
  %t.8688 = load i64, ptr %g.addr
  %r.8689 = call i64 @Emit(i64 %t.8688, ptr @.str.349)
  %t.8690 = load i64, ptr %g.addr
  %r.8691 = call i64 @Emit(i64 %t.8690, ptr @.str.350)
  %t.8692 = load i64, ptr %g.addr
  %r.8693 = call i64 @Emit(i64 %t.8692, ptr @.str.351)
  %t.8694 = load i64, ptr %g.addr
  %r.8695 = call i64 @Emit(i64 %t.8694, ptr @.str.352)
  %t.8696 = load i64, ptr %g.addr
  %r.8697 = call i64 @Emit(i64 %t.8696, ptr @.str.353)
  %t.8698 = load i64, ptr %g.addr
  %r.8699 = call i64 @Emit(i64 %t.8698, ptr @.str.354)
  %t.8700 = load i64, ptr %g.addr
  %r.8701 = call i64 @Emit(i64 %t.8700, ptr @.str.355)
  %t.8702 = load i64, ptr %g.addr
  %r.8703 = call i64 @Emit(i64 %t.8702, ptr @.str.356)
  %t.8704 = load i64, ptr %g.addr
  %r.8705 = call i64 @Emit(i64 %t.8704, ptr @.str.357)
  %t.8706 = load i64, ptr %g.addr
  %r.8707 = call i64 @Emit(i64 %t.8706, ptr @.str.358)
  %t.8708 = load i64, ptr %g.addr
  %r.8709 = call i64 @Emit(i64 %t.8708, ptr @.str.359)
  %t.8710 = load i64, ptr %g.addr
  %r.8711 = call i64 @Emit(i64 %t.8710, ptr @.str.360)
  %t.8712 = load i64, ptr %g.addr
  %r.8713 = call i64 @Emit(i64 %t.8712, ptr @.str.361)
  %t.8714 = load i64, ptr %g.addr
  %r.8715 = call i64 @Emit(i64 %t.8714, ptr @.str.362)
  %t.8716 = load i64, ptr %g.addr
  %r.8717 = call i64 @Emit(i64 %t.8716, ptr @.str.363)
  %t.8718 = load i64, ptr %g.addr
  %r.8719 = call i64 @Emit(i64 %t.8718, ptr @.str.364)
  %t.8720 = load i64, ptr %g.addr
  %r.8721 = call i64 @Emit(i64 %t.8720, ptr @.str.365)
  %t.8722 = load i64, ptr %g.addr
  %r.8723 = call i64 @Emit(i64 %t.8722, ptr @.str.366)
  %t.8724 = load i64, ptr %g.addr
  %r.8725 = call i64 @Emit(i64 %t.8724, ptr @.str.367)
  %t.8726 = load i64, ptr %g.addr
  %r.8727 = call i64 @Emit(i64 %t.8726, ptr @.str.368)
  %t.8728 = load i64, ptr %g.addr
  %r.8729 = call i64 @Emit(i64 %t.8728, ptr @.str.369)
  %t.8730 = load i64, ptr %g.addr
  %r.8731 = call i64 @Emit(i64 %t.8730, ptr @.str.370)
  %t.8732 = load i64, ptr %g.addr
  %r.8733 = call i64 @Emit(i64 %t.8732, ptr @.str.371)
  %t.8734 = load i64, ptr %g.addr
  %r.8735 = call i64 @Emit(i64 %t.8734, ptr @.str.372)
  %t.8736 = load i64, ptr %g.addr
  %r.8737 = call i64 @Emit(i64 %t.8736, ptr @.str.373)
  %t.8738 = load i64, ptr %g.addr
  %r.8739 = call i64 @Emit(i64 %t.8738, ptr @.str.374)
  %t.8740 = load i64, ptr %g.addr
  %r.8741 = call i64 @Emit(i64 %t.8740, ptr @.str.375)
  %t.8742 = load i64, ptr %g.addr
  %r.8743 = call i64 @Emit(i64 %t.8742, ptr @.str.376)
  %t.8744 = load i64, ptr %g.addr
  %r.8745 = call i64 @Emit(i64 %t.8744, ptr @.str.377)
  %t.8746 = load i64, ptr %g.addr
  %r.8747 = call i64 @Emit(i64 %t.8746, ptr @.str.378)
  %t.8748 = load i64, ptr %g.addr
  %r.8749 = call i64 @Emit(i64 %t.8748, ptr @.str.379)
  %t.8750 = load i64, ptr %g.addr
  %r.8751 = call i64 @Emit(i64 %t.8750, ptr @.str.380)
  %t.8752 = load i64, ptr %g.addr
  %r.8753 = call i64 @Emit(i64 %t.8752, ptr @.str.381)
  %t.8754 = load i64, ptr %g.addr
  %r.8755 = call i64 @Emit(i64 %t.8754, ptr @.str.382)
  %t.8756 = load i64, ptr %g.addr
  %r.8757 = call i64 @Emit(i64 %t.8756, ptr @.str.383)
  %t.8758 = load i64, ptr %g.addr
  %r.8759 = call i64 @Emit(i64 %t.8758, ptr @.str.384)
  %t.8760 = load i64, ptr %g.addr
  %r.8761 = call i64 @Emit(i64 %t.8760, ptr @.str.12)
  %ext.8762 = sext i32 0 to i64
  ret i64 %ext.8762
dead.8763:
  ret i64 0
}

define ptr @GenExpr(i64 %g, i64 %e, i64 %arena) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %e.addr = alloca i64
  store i64 %e, ptr %e.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %t.8764 = load i64, ptr %e.addr
  %r.8765 = call i64 @kx_struct_get(i64 %t.8764, i32 0)
  %field.8766 = inttoptr i64 %r.8765 to ptr
  %r.8768 = call i1 @kx_str_eq(ptr %field.8766, ptr @.str.24)
  br i1 %r.8768, label %if.then.8769, label %if.merge.8770
if.then.8769:
  %t.8771 = load i64, ptr %e.addr
  %r.8772 = call i64 @kx_struct_get(i64 %t.8771, i32 1)
  %field.8773 = inttoptr i64 %r.8772 to ptr
  %r.8775 = call ptr @kx_str_cat(ptr @.str.385, ptr %field.8773)
  ret ptr %r.8775
dead.8776:
  br label %if.merge.8770
if.merge.8770:
  %t.8777 = load i64, ptr %e.addr
  %r.8778 = call i64 @kx_struct_get(i64 %t.8777, i32 0)
  %field.8779 = inttoptr i64 %r.8778 to ptr
  %r.8781 = call i1 @kx_str_eq(ptr %field.8779, ptr @.str.25)
  br i1 %r.8781, label %if.then.8782, label %if.merge.8783
if.then.8782:
  %t.8784 = load i64, ptr %e.addr
  %r.8785 = call i64 @kx_struct_get(i64 %t.8784, i32 1)
  %field.8786 = inttoptr i64 %r.8785 to ptr
  %r.8788 = call ptr @kx_str_cat(ptr @.str.386, ptr %field.8786)
  ret ptr %r.8788
dead.8789:
  br label %if.merge.8783
if.merge.8783:
  %t.8790 = load i64, ptr %e.addr
  %r.8791 = call i64 @kx_struct_get(i64 %t.8790, i32 0)
  %field.8792 = inttoptr i64 %r.8791 to ptr
  %r.8794 = call i1 @kx_str_eq(ptr %field.8792, ptr @.str.30)
  br i1 %r.8794, label %if.then.8795, label %if.merge.8796
if.then.8795:
  %t.8797 = load i64, ptr %g.addr
  %t.8798 = load i64, ptr %e.addr
  %r.8799 = call i64 @kx_struct_get(i64 %t.8798, i32 1)
  %field.8800 = inttoptr i64 %r.8799 to ptr
  %r.8801 = call ptr @GetStr(i64 %t.8797, ptr %field.8800)
  %r.8803 = call ptr @kx_str_cat(ptr @.str.387, ptr %r.8801)
  ret ptr %r.8803
dead.8804:
  br label %if.merge.8796
if.merge.8796:
  %t.8805 = load i64, ptr %e.addr
  %r.8806 = call i64 @kx_struct_get(i64 %t.8805, i32 0)
  %field.8807 = inttoptr i64 %r.8806 to ptr
  %r.8809 = call i1 @kx_str_eq(ptr %field.8807, ptr @.str.93)
  br i1 %r.8809, label %if.then.8810, label %if.merge.8811
if.then.8810:
  %t.8812 = load i64, ptr %e.addr
  %r.8813 = call i64 @kx_struct_get(i64 %t.8812, i32 1)
  %field.8814 = inttoptr i64 %r.8813 to ptr
  %structName.308 = alloca ptr
  store ptr %field.8814, ptr %structName.308
  %t.8815 = load i64, ptr %g.addr
  %r.8816 = call i64 @kx_struct_get(i64 %t.8815, i32 8)
  %t.8817 = load ptr, ptr %structName.308
  %c.8818 = ptrtoint ptr %t.8817 to i64
  %r.8819 = call i1 @kx_map_has(i64 %r.8816, i64 %c.8818)
  br i1 %r.8819, label %if.then.8820, label %if.merge.8821
if.then.8820:
  %t.8822 = load i64, ptr %g.addr
  %r.8823 = call i64 @kx_struct_get(i64 %t.8822, i32 8)
  %t.8824 = load ptr, ptr %structName.308
  %c.8826 = ptrtoint ptr %t.8824 to i64
  %r.8825 = call i64 @kx_map_get(i64 %r.8823, i64 %c.8826)
  %fieldStr.309 = alloca i64
  store i64 %r.8825, ptr %fieldStr.309
  %t.8827 = load i64, ptr %fieldStr.309
  %cast.8828 = inttoptr i64 %t.8827 to ptr
  %r.8829 = call i64 @SplitAll(ptr %cast.8828, ptr @.str.97)
  %fields.310 = alloca i64
  store i64 %r.8829, ptr %fields.310
  %t.8830 = load i64, ptr %fields.310
  %ext.8832 = sext i32 0 to i64
  %r.8831 = call i64 @kx_list_get(i64 %t.8830, i64 %ext.8832)
  %ext.8834 = inttoptr i64 %r.8831 to ptr
  %r.8835 = call i1 @kx_str_eq(ptr %ext.8834, ptr @.str.12)
  br i1 %r.8835, label %if.then.8836, label %if.merge.8837
if.then.8836:
  %r.8838 = call i64 @kx_list_new(i32 0)
  store i64 %r.8838, ptr %fields.310
  br label %if.merge.8837
if.merge.8837:
  %t.8839 = load i64, ptr %fields.310
  %r.8840 = call i64 @kx_list_size(i64 %t.8839)
  %size.311 = alloca i64
  store i64 %r.8840, ptr %size.311
  %t.8841 = load i64, ptr %size.311
  %ext.8842 = sext i32 0 to i64
  %t.8843 = icmp eq i64 %t.8841, %ext.8842
  br i1 %t.8843, label %if.then.8844, label %if.merge.8845
if.then.8844:
  %ext.8846 = sext i32 1 to i64
  store i64 %ext.8846, ptr %size.311
  br label %if.merge.8845
if.merge.8845:
  %t.8847 = load i64, ptr %g.addr
  %r.8848 = call i64 @kx_struct_get(i64 %t.8847, i32 4)
  %t.8849 = load i64, ptr %g.addr
  %r.8850 = call i64 @kx_struct_get(i64 %t.8849, i32 4)
  %ext.8852 = sext i32 0 to i64
  %r.8851 = call i64 @kx_list_get(i64 %r.8850, i64 %ext.8852)
  %ext.8853 = sext i32 1 to i64
  %t.8854 = add i64 %r.8851, %ext.8853
  %ext.8855 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.8848, i64 %ext.8855, i64 %t.8854)
  %t.8856 = load i64, ptr %g.addr
  %r.8857 = call i64 @kx_struct_get(i64 %t.8856, i32 4)
  %ext.8859 = sext i32 0 to i64
  %r.8858 = call i64 @kx_list_get(i64 %r.8857, i64 %ext.8859)
  %r.8860 = call ptr @kx_int_str(i64 %r.8858)
  %r.8862 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.8860)
  %r.312 = alloca ptr
  store ptr %r.8862, ptr %r.312
  %t.8863 = load i64, ptr %g.addr
  %t.8864 = load ptr, ptr %r.312
  %r.8866 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.8864)
  %r.8868 = call ptr @kx_str_cat(ptr %r.8866, ptr @.str.389)
  %t.8869 = load i64, ptr %size.311
  %r.8870 = call ptr @kx_int_str(i64 %t.8869)
  %r.8872 = call ptr @kx_str_cat(ptr %r.8868, ptr %r.8870)
  %r.8874 = call ptr @kx_str_cat(ptr %r.8872, ptr @.str.100)
  %r.8875 = call i64 @Emit(i64 %t.8863, ptr %r.8874)
  %fi.313 = alloca i32
  store i32 0, ptr %fi.313
  br label %for.cond.8876
for.cond.8876:
  %t.8880 = load i32, ptr %fi.313
  %t.8881 = load i64, ptr %e.addr
  %r.8882 = call i64 @kx_struct_get(i64 %t.8881, i32 4)
  %r.8883 = call i64 @kx_list_size(i64 %r.8882)
  %ext.8884 = sext i32 %t.8880 to i64
  %t.8885 = icmp slt i64 %ext.8884, %r.8883
  br i1 %t.8885, label %for.body.8877, label %for.end.8879
for.body.8877:
  %t.8886 = load i64, ptr %arena.addr
  %t.8887 = load i64, ptr %e.addr
  %t.8888 = load i32, ptr %fi.313
  %cast.8889 = sext i32 %t.8888 to i64
  %r.8890 = call i64 @Child(i64 %t.8886, i64 %t.8887, i64 %cast.8889)
  %field.314 = alloca i64
  store i64 %r.8890, ptr %field.314
  %t.8891 = load i64, ptr %field.314
  %ext.8893 = inttoptr i64 %t.8891 to ptr
  %r.8894 = call i1 @kx_str_eq(ptr %ext.8893, ptr @.str.96)
  br i1 %r.8894, label %if.then.8895, label %if.merge.8896
if.then.8895:
  %t.8897 = load i64, ptr %field.314
  %fname.315 = alloca i64
  store i64 %t.8897, ptr %fname.315
  %t.8898 = sub i32 0, 1
  %fidx.316 = alloca i32
  store i32 %t.8898, ptr %fidx.316
  %fj.317 = alloca i32
  store i32 0, ptr %fj.317
  br label %for.cond.8899
for.cond.8899:
  %t.8903 = load i32, ptr %fj.317
  %t.8904 = load i64, ptr %fields.310
  %r.8905 = call i64 @kx_list_size(i64 %t.8904)
  %ext.8906 = sext i32 %t.8903 to i64
  %t.8907 = icmp slt i64 %ext.8906, %r.8905
  br i1 %t.8907, label %for.body.8900, label %for.end.8902
for.body.8900:
  %t.8908 = load i64, ptr %fields.310
  %t.8909 = load i32, ptr %fj.317
  %ext.8911 = sext i32 %t.8909 to i64
  %r.8910 = call i64 @kx_list_get(i64 %t.8908, i64 %ext.8911)
  %t.8912 = load i64, ptr %fname.315
  %t.8913 = icmp eq i64 %r.8910, %t.8912
  br i1 %t.8913, label %if.then.8914, label %if.merge.8915
if.then.8914:
  %t.8916 = load i32, ptr %fj.317
  store i32 %t.8916, ptr %fidx.316
  br label %for.end.8902
dead.8917:
  br label %if.merge.8915
if.merge.8915:
  br label %for.inc.8901
for.inc.8901:
  %t.8918 = load i32, ptr %fj.317
  %t.8919 = add i32 %t.8918, 1
  store i32 %t.8919, ptr %fj.317
  br label %for.cond.8899
for.end.8902:
  %t.8920 = load i32, ptr %fidx.316
  %t.8921 = icmp sge i32 %t.8920, 0
  br i1 %t.8921, label %if.then.8922, label %if.merge.8923
if.then.8922:
  %t.8924 = load i64, ptr %g.addr
  %t.8925 = load i64, ptr %arena.addr
  %t.8926 = load i64, ptr %field.314
  %cast.8927 = sext i32 0 to i64
  %r.8928 = call i64 @Child(i64 %t.8925, i64 %t.8926, i64 %cast.8927)
  %t.8929 = load i64, ptr %arena.addr
  %r.8930 = call ptr @GenExpr(i64 %t.8924, i64 %r.8928, i64 %t.8929)
  %fv.318 = alloca ptr
  store ptr %r.8930, ptr %fv.318
  %t.8931 = load i64, ptr %g.addr
  %t.8932 = load ptr, ptr %r.312
  %r.8934 = call ptr @kx_str_cat(ptr @.str.390, ptr %t.8932)
  %r.8936 = call ptr @kx_str_cat(ptr %r.8934, ptr @.str.391)
  %t.8937 = load i32, ptr %fidx.316
  %ext.8938 = sext i32 %t.8937 to i64
  %r.8939 = call ptr @kx_int_str(i64 %ext.8938)
  %r.8941 = call ptr @kx_str_cat(ptr %r.8936, ptr %r.8939)
  %r.8943 = call ptr @kx_str_cat(ptr %r.8941, ptr @.str.392)
  %t.8944 = load i64, ptr %g.addr
  %t.8945 = load ptr, ptr %fv.318
  %r.8946 = call ptr @ToI64(i64 %t.8944, ptr %t.8945)
  %r.8948 = call ptr @kx_str_cat(ptr %r.8943, ptr %r.8946)
  %r.8950 = call ptr @kx_str_cat(ptr %r.8948, ptr @.str.100)
  %r.8951 = call i64 @Emit(i64 %t.8931, ptr %r.8950)
  br label %if.merge.8923
if.merge.8923:
  br label %if.merge.8896
if.merge.8896:
  br label %for.inc.8878
for.inc.8878:
  %t.8952 = load i32, ptr %fi.313
  %t.8953 = add i32 %t.8952, 1
  store i32 %t.8953, ptr %fi.313
  br label %for.cond.8876
for.end.8879:
  %t.8954 = load ptr, ptr %r.312
  %r.8956 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.8954)
  ret ptr %r.8956
dead.8957:
  br label %if.merge.8821
if.merge.8821:
  ret ptr @.str.393
dead.8958:
  br label %if.merge.8811
if.merge.8811:
  %t.8959 = load i64, ptr %e.addr
  %r.8960 = call i64 @kx_struct_get(i64 %t.8959, i32 0)
  %field.8961 = inttoptr i64 %r.8960 to ptr
  %r.8963 = call i1 @kx_str_eq(ptr %field.8961, ptr @.str.155)
  br i1 %r.8963, label %if.then.8964, label %if.merge.8965
if.then.8964:
  %t.8966 = load i64, ptr %g.addr
  %t.8967 = load i64, ptr %e.addr
  %r.8968 = call i64 @kx_struct_get(i64 %t.8967, i32 1)
  %field.8969 = inttoptr i64 %r.8968 to ptr
  %r.8970 = call ptr @GetStr(i64 %t.8966, ptr %field.8969)
  %result.319 = alloca ptr
  store ptr %r.8970, ptr %result.319
  %i.320 = alloca i32
  store i32 0, ptr %i.320
  br label %for.cond.8971
for.cond.8971:
  %t.8975 = load i32, ptr %i.320
  %t.8976 = load i64, ptr %e.addr
  %r.8977 = call i64 @kx_struct_get(i64 %t.8976, i32 4)
  %r.8978 = call i64 @kx_list_size(i64 %r.8977)
  %ext.8979 = sext i32 %t.8975 to i64
  %t.8980 = icmp slt i64 %ext.8979, %r.8978
  br i1 %t.8980, label %for.body.8972, label %for.end.8974
for.body.8972:
  %t.8981 = load i64, ptr %arena.addr
  %t.8982 = load i64, ptr %e.addr
  %t.8983 = load i32, ptr %i.320
  %cast.8984 = sext i32 %t.8983 to i64
  %r.8985 = call i64 @Child(i64 %t.8981, i64 %t.8982, i64 %cast.8984)
  %child.321 = alloca i64
  store i64 %r.8985, ptr %child.321
  %part.322 = alloca ptr
  store ptr @.str.12, ptr %part.322
  %t.8986 = load i64, ptr %child.321
  %ext.8988 = inttoptr i64 %t.8986 to ptr
  %r.8989 = call i1 @kx_str_eq(ptr %ext.8988, ptr @.str.156)
  br i1 %r.8989, label %if.then.8990, label %if.else.8992
if.then.8990:
  %t.8993 = load i64, ptr %g.addr
  %t.8994 = load i64, ptr %child.321
  %cast.8995 = inttoptr i64 %t.8994 to ptr
  %r.8996 = call ptr @GetStr(i64 %t.8993, ptr %cast.8995)
  store ptr %r.8996, ptr %part.322
  br label %if.merge.8991
if.else.8992:
  %t.8997 = load i64, ptr %child.321
  %ext.8999 = inttoptr i64 %t.8997 to ptr
  %r.9000 = call i1 @kx_str_eq(ptr %ext.8999, ptr @.str.157)
  br i1 %r.9000, label %if.then.9001, label %if.merge.9002
if.then.9001:
  %t.9003 = load i64, ptr %arena.addr
  %t.9004 = load i64, ptr %child.321
  %cast.9005 = sext i32 0 to i64
  %r.9006 = call i64 @Child(i64 %t.9003, i64 %t.9004, i64 %cast.9005)
  %expr.323 = alloca i64
  store i64 %r.9006, ptr %expr.323
  %t.9007 = load i64, ptr %g.addr
  %t.9008 = load i64, ptr %expr.323
  %t.9009 = load i64, ptr %arena.addr
  %r.9010 = call ptr @GenExpr(i64 %t.9007, i64 %t.9008, i64 %t.9009)
  %ev.324 = alloca ptr
  store ptr %r.9010, ptr %ev.324
  %t.9011 = load ptr, ptr %ev.324
  %r.9012 = call i64 @XType(ptr %t.9011)
  %ext.9014 = inttoptr i64 %r.9012 to ptr
  %r.9015 = call i1 @kx_str_eq(ptr %ext.9014, ptr @.str.269)
  br i1 %r.9015, label %if.then.9016, label %if.else.9018
if.then.9016:
  %t.9019 = load i64, ptr %g.addr
  %r.9020 = call i64 @kx_struct_get(i64 %t.9019, i32 4)
  %t.9021 = load i64, ptr %g.addr
  %r.9022 = call i64 @kx_struct_get(i64 %t.9021, i32 4)
  %ext.9024 = sext i32 0 to i64
  %r.9023 = call i64 @kx_list_get(i64 %r.9022, i64 %ext.9024)
  %ext.9025 = sext i32 1 to i64
  %t.9026 = add i64 %r.9023, %ext.9025
  %ext.9027 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9020, i64 %ext.9027, i64 %t.9026)
  %t.9028 = load i64, ptr %g.addr
  %r.9029 = call i64 @kx_struct_get(i64 %t.9028, i32 4)
  %ext.9031 = sext i32 0 to i64
  %r.9030 = call i64 @kx_list_get(i64 %r.9029, i64 %ext.9031)
  %r.9032 = call ptr @kx_int_str(i64 %r.9030)
  %r.9034 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.9032)
  %r.325 = alloca ptr
  store ptr %r.9034, ptr %r.325
  %t.9035 = load i64, ptr %g.addr
  %t.9036 = load ptr, ptr %r.325
  %r.9038 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9036)
  %r.9040 = call ptr @kx_str_cat(ptr %r.9038, ptr @.str.394)
  %t.9041 = load ptr, ptr %ev.324
  %r.9042 = call i64 @XVal(ptr %t.9041)
  %ext.9044 = call ptr @kx_int_str(i64 %r.9042)
  %r.9045 = call ptr @kx_str_cat(ptr %r.9040, ptr %ext.9044)
  %r.9047 = call ptr @kx_str_cat(ptr %r.9045, ptr @.str.100)
  %r.9048 = call i64 @Emit(i64 %t.9035, ptr %r.9047)
  %t.9049 = load ptr, ptr %r.325
  store ptr %t.9049, ptr %part.322
  br label %if.merge.9017
if.else.9018:
  %t.9050 = load ptr, ptr %ev.324
  %r.9051 = call i64 @XType(ptr %t.9050)
  %ext.9053 = inttoptr i64 %r.9051 to ptr
  %r.9054 = call i1 @kx_str_eq(ptr %ext.9053, ptr @.str.279)
  br i1 %r.9054, label %if.then.9055, label %if.else.9057
if.then.9055:
  %t.9058 = load i64, ptr %g.addr
  %r.9059 = call i64 @kx_struct_get(i64 %t.9058, i32 4)
  %t.9060 = load i64, ptr %g.addr
  %r.9061 = call i64 @kx_struct_get(i64 %t.9060, i32 4)
  %ext.9063 = sext i32 0 to i64
  %r.9062 = call i64 @kx_list_get(i64 %r.9061, i64 %ext.9063)
  %ext.9064 = sext i32 1 to i64
  %t.9065 = add i64 %r.9062, %ext.9064
  %ext.9066 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9059, i64 %ext.9066, i64 %t.9065)
  %t.9067 = load i64, ptr %g.addr
  %r.9068 = call i64 @kx_struct_get(i64 %t.9067, i32 4)
  %ext.9070 = sext i32 0 to i64
  %r.9069 = call i64 @kx_list_get(i64 %r.9068, i64 %ext.9070)
  %r.9071 = call ptr @kx_int_str(i64 %r.9069)
  %r.9073 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9071)
  %ext.326 = alloca ptr
  store ptr %r.9073, ptr %ext.326
  %t.9074 = load i64, ptr %g.addr
  %t.9075 = load ptr, ptr %ext.326
  %r.9077 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9075)
  %r.9079 = call ptr @kx_str_cat(ptr %r.9077, ptr @.str.275)
  %t.9080 = load ptr, ptr %ev.324
  %r.9081 = call i64 @XVal(ptr %t.9080)
  %ext.9083 = call ptr @kx_int_str(i64 %r.9081)
  %r.9084 = call ptr @kx_str_cat(ptr %r.9079, ptr %ext.9083)
  %r.9086 = call ptr @kx_str_cat(ptr %r.9084, ptr @.str.274)
  %r.9087 = call i64 @Emit(i64 %t.9074, ptr %r.9086)
  %t.9088 = load i64, ptr %g.addr
  %r.9089 = call i64 @kx_struct_get(i64 %t.9088, i32 4)
  %t.9090 = load i64, ptr %g.addr
  %r.9091 = call i64 @kx_struct_get(i64 %t.9090, i32 4)
  %ext.9093 = sext i32 0 to i64
  %r.9092 = call i64 @kx_list_get(i64 %r.9091, i64 %ext.9093)
  %ext.9094 = sext i32 1 to i64
  %t.9095 = add i64 %r.9092, %ext.9094
  %ext.9096 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9089, i64 %ext.9096, i64 %t.9095)
  %t.9097 = load i64, ptr %g.addr
  %r.9098 = call i64 @kx_struct_get(i64 %t.9097, i32 4)
  %ext.9100 = sext i32 0 to i64
  %r.9099 = call i64 @kx_list_get(i64 %r.9098, i64 %ext.9100)
  %r.9101 = call ptr @kx_int_str(i64 %r.9099)
  %r.9103 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.9101)
  %r.327 = alloca ptr
  store ptr %r.9103, ptr %r.327
  %t.9104 = load i64, ptr %g.addr
  %t.9105 = load ptr, ptr %r.327
  %r.9107 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9105)
  %r.9109 = call ptr @kx_str_cat(ptr %r.9107, ptr @.str.394)
  %t.9110 = load ptr, ptr %ext.326
  %r.9112 = call ptr @kx_str_cat(ptr %r.9109, ptr %t.9110)
  %r.9114 = call ptr @kx_str_cat(ptr %r.9112, ptr @.str.100)
  %r.9115 = call i64 @Emit(i64 %t.9104, ptr %r.9114)
  %t.9116 = load ptr, ptr %r.327
  store ptr %t.9116, ptr %part.322
  br label %if.merge.9056
if.else.9057:
  %t.9117 = load ptr, ptr %ev.324
  %r.9118 = call i64 @XVal(ptr %t.9117)
  %inttoptr.9119 = inttoptr i64 %r.9118 to ptr
  store ptr %inttoptr.9119, ptr %part.322
  br label %if.merge.9056
if.merge.9056:
  br label %if.merge.9017
if.merge.9017:
  br label %if.merge.9002
if.merge.9002:
  br label %if.merge.8991
if.merge.8991:
  %t.9120 = load ptr, ptr %part.322
  %r.9122 = call i1 @kx_str_eq(ptr %t.9120, ptr @.str.12)
  br i1 %r.9122, label %if.then.9123, label %if.merge.9124
if.then.9123:
  %t.9125 = load i64, ptr %g.addr
  %r.9126 = call i64 @kx_struct_get(i64 %t.9125, i32 4)
  %t.9127 = load i64, ptr %g.addr
  %r.9128 = call i64 @kx_struct_get(i64 %t.9127, i32 4)
  %ext.9130 = sext i32 0 to i64
  %r.9129 = call i64 @kx_list_get(i64 %r.9128, i64 %ext.9130)
  %ext.9131 = sext i32 1 to i64
  %t.9132 = add i64 %r.9129, %ext.9131
  %ext.9133 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9126, i64 %ext.9133, i64 %t.9132)
  %t.9134 = load i64, ptr %g.addr
  %r.9135 = call i64 @kx_struct_get(i64 %t.9134, i32 4)
  %ext.9137 = sext i32 0 to i64
  %r.9136 = call i64 @kx_list_get(i64 %r.9135, i64 %ext.9137)
  %r.9138 = call ptr @kx_int_str(i64 %r.9136)
  %r.9140 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.9138)
  %r.328 = alloca ptr
  store ptr %r.9140, ptr %r.328
  %t.9141 = load i64, ptr %g.addr
  %t.9142 = load ptr, ptr %r.328
  %r.9144 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9142)
  %r.9146 = call ptr @kx_str_cat(ptr %r.9144, ptr @.str.395)
  %t.9147 = load ptr, ptr %result.319
  %r.9149 = call ptr @kx_str_cat(ptr %r.9146, ptr %t.9147)
  %r.9151 = call ptr @kx_str_cat(ptr %r.9149, ptr @.str.396)
  %t.9152 = load ptr, ptr %part.322
  %r.9154 = call ptr @kx_str_cat(ptr %r.9151, ptr %t.9152)
  %r.9156 = call ptr @kx_str_cat(ptr %r.9154, ptr @.str.100)
  %r.9157 = call i64 @Emit(i64 %t.9141, ptr %r.9156)
  %t.9158 = load ptr, ptr %r.328
  store ptr %t.9158, ptr %result.319
  br label %if.merge.9124
if.merge.9124:
  br label %for.inc.8973
for.inc.8973:
  %t.9159 = load i32, ptr %i.320
  %t.9160 = add i32 %t.9159, 1
  store i32 %t.9160, ptr %i.320
  br label %for.cond.8971
for.end.8974:
  %t.9161 = load ptr, ptr %result.319
  %r.9163 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.9161)
  ret ptr %r.9163
dead.9164:
  br label %if.merge.8965
if.merge.8965:
  %t.9165 = load i64, ptr %e.addr
  %r.9166 = call i64 @kx_struct_get(i64 %t.9165, i32 0)
  %field.9167 = inttoptr i64 %r.9166 to ptr
  %r.9169 = call i1 @kx_str_eq(ptr %field.9167, ptr @.str.28)
  br i1 %r.9169, label %if.then.9170, label %if.merge.9171
if.then.9170:
  %t.9172 = load i64, ptr %e.addr
  %r.9173 = call i64 @kx_struct_get(i64 %t.9172, i32 1)
  %field.9174 = inttoptr i64 %r.9173 to ptr
  %r.9176 = call i1 @kx_str_eq(ptr %field.9174, ptr @.str.50)
  br i1 %r.9176, label %tern.then.9177, label %tern.else.9178
tern.then.9177:
  br label %tern.merge.9179
tern.else.9178:
  br label %tern.merge.9179
tern.merge.9179:
  %phi.9180 = phi ptr [@.str.50, %tern.then.9177], [@.str.51, %tern.else.9178]
  %r.9182 = call ptr @kx_str_cat(ptr @.str.397, ptr %phi.9180)
  ret ptr %r.9182
dead.9183:
  br label %if.merge.9171
if.merge.9171:
  %t.9184 = load i64, ptr %e.addr
  %r.9185 = call i64 @kx_struct_get(i64 %t.9184, i32 0)
  %field.9186 = inttoptr i64 %r.9185 to ptr
  %r.9188 = call i1 @kx_str_eq(ptr %field.9186, ptr @.str.92)
  br i1 %r.9188, label %if.then.9189, label %if.merge.9190
if.then.9189:
  %t.9191 = load i64, ptr %e.addr
  %r.9192 = call i64 @kx_struct_get(i64 %t.9191, i32 1)
  %field.9193 = inttoptr i64 %r.9192 to ptr
  %r.9195 = call i1 @kx_str_eq(ptr %field.9193, ptr @.str.50)
  br i1 %r.9195, label %if.then.9196, label %if.merge.9197
if.then.9196:
  ret ptr @.str.398
dead.9198:
  br label %if.merge.9197
if.merge.9197:
  %t.9199 = load i64, ptr %e.addr
  %r.9200 = call i64 @kx_struct_get(i64 %t.9199, i32 1)
  %field.9201 = inttoptr i64 %r.9200 to ptr
  %r.9203 = call i1 @kx_str_eq(ptr %field.9201, ptr @.str.51)
  br i1 %r.9203, label %if.then.9204, label %if.merge.9205
if.then.9204:
  ret ptr @.str.399
dead.9206:
  br label %if.merge.9205
if.merge.9205:
  %t.9207 = load i64, ptr %g.addr
  %r.9208 = call i64 @kx_struct_get(i64 %t.9207, i32 7)
  %t.9209 = load i64, ptr %e.addr
  %r.9210 = call i64 @kx_struct_get(i64 %t.9209, i32 1)
  %field.9211 = inttoptr i64 %r.9210 to ptr
  %c.9212 = ptrtoint ptr %field.9211 to i64
  %r.9213 = call i1 @kx_map_has(i64 %r.9208, i64 %c.9212)
  br i1 %r.9213, label %if.then.9214, label %if.merge.9215
if.then.9214:
  %t.9216 = load i64, ptr %g.addr
  %r.9217 = call i64 @kx_struct_get(i64 %t.9216, i32 6)
  %t.9218 = load i64, ptr %e.addr
  %r.9219 = call i64 @kx_struct_get(i64 %t.9218, i32 1)
  %field.9220 = inttoptr i64 %r.9219 to ptr
  %c.9222 = ptrtoint ptr %field.9220 to i64
  %r.9221 = call i64 @kx_map_get(i64 %r.9217, i64 %c.9222)
  %varType.329 = alloca i64
  store i64 %r.9221, ptr %varType.329
  %t.9223 = load i64, ptr %varType.329
  %irType.330 = alloca i64
  store i64 %t.9223, ptr %irType.330
  %t.9224 = load i64, ptr %varType.329
  %ext.9225 = inttoptr i64 %t.9224 to ptr
  %r.9226 = call i1 @kx_str_starts_with(ptr %ext.9225, ptr @.str.286)
  br i1 %r.9226, label %if.then.9227, label %if.merge.9228
if.then.9227:
  %ptrtoint.9229 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9229, ptr %irType.330
  br label %if.merge.9228
if.merge.9228:
  %t.9230 = load i64, ptr %g.addr
  %r.9231 = call i64 @kx_struct_get(i64 %t.9230, i32 4)
  %t.9232 = load i64, ptr %g.addr
  %r.9233 = call i64 @kx_struct_get(i64 %t.9232, i32 4)
  %ext.9235 = sext i32 0 to i64
  %r.9234 = call i64 @kx_list_get(i64 %r.9233, i64 %ext.9235)
  %ext.9236 = sext i32 1 to i64
  %t.9237 = add i64 %r.9234, %ext.9236
  %ext.9238 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9231, i64 %ext.9238, i64 %t.9237)
  %t.9239 = load i64, ptr %g.addr
  %r.9240 = call i64 @kx_struct_get(i64 %t.9239, i32 4)
  %ext.9242 = sext i32 0 to i64
  %r.9241 = call i64 @kx_list_get(i64 %r.9240, i64 %ext.9242)
  %r.9243 = call ptr @kx_int_str(i64 %r.9241)
  %r.9245 = call ptr @kx_str_cat(ptr @.str.400, ptr %r.9243)
  %t.331 = alloca ptr
  store ptr %r.9245, ptr %t.331
  %t.9246 = load i64, ptr %g.addr
  %t.9247 = load ptr, ptr %t.331
  %r.9249 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9247)
  %r.9251 = call ptr @kx_str_cat(ptr %r.9249, ptr @.str.401)
  %t.9252 = load i64, ptr %irType.330
  %ext.9254 = call ptr @kx_int_str(i64 %t.9252)
  %r.9255 = call ptr @kx_str_cat(ptr %r.9251, ptr %ext.9254)
  %r.9257 = call ptr @kx_str_cat(ptr %r.9255, ptr @.str.396)
  %t.9258 = load i64, ptr %g.addr
  %r.9259 = call i64 @kx_struct_get(i64 %t.9258, i32 7)
  %t.9260 = load i64, ptr %e.addr
  %r.9261 = call i64 @kx_struct_get(i64 %t.9260, i32 1)
  %field.9262 = inttoptr i64 %r.9261 to ptr
  %c.9264 = ptrtoint ptr %field.9262 to i64
  %r.9263 = call i64 @kx_map_get(i64 %r.9259, i64 %c.9264)
  %ext.9266 = call ptr @kx_int_str(i64 %r.9263)
  %r.9267 = call ptr @kx_str_cat(ptr %r.9257, ptr %ext.9266)
  %r.9268 = call i64 @Emit(i64 %t.9246, ptr %r.9267)
  %t.9269 = load i64, ptr %varType.329
  %ext.9271 = inttoptr i64 %t.9269 to ptr
  %r.9272 = call i1 @kx_str_eq(ptr %ext.9271, ptr @.str.271)
  br i1 %r.9272, label %if.then.9273, label %if.merge.9274
if.then.9273:
  %t.9275 = load ptr, ptr %t.331
  %r.9277 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.9275)
  ret ptr %r.9277
dead.9278:
  br label %if.merge.9274
if.merge.9274:
  %t.9279 = load i64, ptr %irType.330
  %ext.9281 = inttoptr i64 %t.9279 to ptr
  %r.9282 = call i1 @kx_str_eq(ptr %ext.9281, ptr @.str.269)
  br i1 %r.9282, label %if.then.9283, label %if.merge.9284
if.then.9283:
  %t.9285 = load ptr, ptr %t.331
  %r.9287 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.9285)
  ret ptr %r.9287
dead.9288:
  br label %if.merge.9284
if.merge.9284:
  %t.9289 = load i64, ptr %irType.330
  %ext.9291 = call ptr @kx_int_str(i64 %t.9289)
  %r.9292 = call ptr @kx_str_cat(ptr %ext.9291, ptr @.str.8)
  %t.9293 = load ptr, ptr %t.331
  %r.9295 = call ptr @kx_str_cat(ptr %r.9292, ptr %t.9293)
  ret ptr %r.9295
dead.9296:
  br label %if.merge.9215
if.merge.9215:
  ret ptr @.str.393
dead.9297:
  br label %if.merge.9190
if.merge.9190:
  %t.9298 = load i64, ptr %e.addr
  %r.9299 = call i64 @kx_struct_get(i64 %t.9298, i32 0)
  %field.9300 = inttoptr i64 %r.9299 to ptr
  %r.9302 = call i1 @kx_str_eq(ptr %field.9300, ptr @.str.117)
  br i1 %r.9302, label %if.then.9303, label %if.merge.9304
if.then.9303:
  %t.9305 = load i64, ptr %g.addr
  %t.9306 = load i64, ptr %arena.addr
  %t.9307 = load i64, ptr %e.addr
  %cast.9308 = sext i32 0 to i64
  %r.9309 = call i64 @Child(i64 %t.9306, i64 %t.9307, i64 %cast.9308)
  %t.9310 = load i64, ptr %arena.addr
  %r.9311 = call ptr @GenExpr(i64 %t.9305, i64 %r.9309, i64 %t.9310)
  %lv.332 = alloca ptr
  store ptr %r.9311, ptr %lv.332
  %t.9312 = load i64, ptr %g.addr
  %t.9313 = load i64, ptr %arena.addr
  %t.9314 = load i64, ptr %e.addr
  %cast.9315 = sext i32 1 to i64
  %r.9316 = call i64 @Child(i64 %t.9313, i64 %t.9314, i64 %cast.9315)
  %t.9317 = load i64, ptr %arena.addr
  %r.9318 = call ptr @GenExpr(i64 %t.9312, i64 %r.9316, i64 %t.9317)
  %rv.333 = alloca ptr
  store ptr %r.9318, ptr %rv.333
  %t.9319 = load ptr, ptr %lv.332
  %r.9320 = call i64 @XType(ptr %t.9319)
  %lt.334 = alloca i64
  store i64 %r.9320, ptr %lt.334
  %t.9321 = load ptr, ptr %rv.333
  %r.9322 = call i64 @XType(ptr %t.9321)
  %rt.335 = alloca i64
  store i64 %r.9322, ptr %rt.335
  %t.9323 = load ptr, ptr %lv.332
  %r.9324 = call i64 @XVal(ptr %t.9323)
  %la.336 = alloca i64
  store i64 %r.9324, ptr %la.336
  %t.9325 = load ptr, ptr %rv.333
  %r.9326 = call i64 @XVal(ptr %t.9325)
  %ra.337 = alloca i64
  store i64 %r.9326, ptr %ra.337
  %t.9327 = load i64, ptr %lt.334
  %t.9328 = load i64, ptr %rt.335
  %t.9329 = icmp ne i64 %t.9327, %t.9328
  %t.9330 = load i64, ptr %lt.334
  %ext.9332 = inttoptr i64 %t.9330 to ptr
  %r.9333 = call i1 @kx_str_eq(ptr %ext.9332, ptr @.str.271)
  %t.9334 = and i1 %t.9329, %r.9333
  %t.9335 = load i64, ptr %rt.335
  %ext.9337 = inttoptr i64 %t.9335 to ptr
  %r.9338 = call i1 @kx_str_eq(ptr %ext.9337, ptr @.str.271)
  %t.9339 = and i1 %t.9334, %r.9338
  br i1 %t.9339, label %if.then.9340, label %if.merge.9341
if.then.9340:
  %t.9342 = load i64, ptr %lt.334
  %ext.9344 = inttoptr i64 %t.9342 to ptr
  %r.9345 = call i1 @kx_str_eq(ptr %ext.9344, ptr @.str.279)
  %t.9346 = load i64, ptr %rt.335
  %ext.9348 = inttoptr i64 %t.9346 to ptr
  %r.9349 = call i1 @kx_str_eq(ptr %ext.9348, ptr @.str.269)
  %t.9350 = and i1 %r.9345, %r.9349
  br i1 %t.9350, label %if.then.9351, label %if.else.9353
if.then.9351:
  %t.9354 = load i64, ptr %g.addr
  %r.9355 = call i64 @kx_struct_get(i64 %t.9354, i32 4)
  %t.9356 = load i64, ptr %g.addr
  %r.9357 = call i64 @kx_struct_get(i64 %t.9356, i32 4)
  %ext.9359 = sext i32 0 to i64
  %r.9358 = call i64 @kx_list_get(i64 %r.9357, i64 %ext.9359)
  %ext.9360 = sext i32 1 to i64
  %t.9361 = add i64 %r.9358, %ext.9360
  %ext.9362 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9355, i64 %ext.9362, i64 %t.9361)
  %t.9363 = load i64, ptr %g.addr
  %r.9364 = call i64 @kx_struct_get(i64 %t.9363, i32 4)
  %ext.9366 = sext i32 0 to i64
  %r.9365 = call i64 @kx_list_get(i64 %r.9364, i64 %ext.9366)
  %r.9367 = call ptr @kx_int_str(i64 %r.9365)
  %r.9369 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9367)
  %ext.338 = alloca ptr
  store ptr %r.9369, ptr %ext.338
  %t.9370 = load i64, ptr %g.addr
  %t.9371 = load ptr, ptr %ext.338
  %r.9373 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9371)
  %r.9375 = call ptr @kx_str_cat(ptr %r.9373, ptr @.str.275)
  %t.9376 = load i64, ptr %la.336
  %ext.9378 = call ptr @kx_int_str(i64 %t.9376)
  %r.9379 = call ptr @kx_str_cat(ptr %r.9375, ptr %ext.9378)
  %r.9381 = call ptr @kx_str_cat(ptr %r.9379, ptr @.str.274)
  %r.9382 = call i64 @Emit(i64 %t.9370, ptr %r.9381)
  %t.9383 = load ptr, ptr %ext.338
  %ptrtoint.9384 = ptrtoint ptr %t.9383 to i64
  store i64 %ptrtoint.9384, ptr %la.336
  %ptrtoint.9385 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9385, ptr %lt.334
  br label %if.merge.9352
if.else.9353:
  %t.9386 = load i64, ptr %lt.334
  %ext.9388 = inttoptr i64 %t.9386 to ptr
  %r.9389 = call i1 @kx_str_eq(ptr %ext.9388, ptr @.str.269)
  %t.9390 = load i64, ptr %rt.335
  %ext.9392 = inttoptr i64 %t.9390 to ptr
  %r.9393 = call i1 @kx_str_eq(ptr %ext.9392, ptr @.str.279)
  %t.9394 = and i1 %r.9389, %r.9393
  br i1 %t.9394, label %if.then.9395, label %if.merge.9396
if.then.9395:
  %t.9397 = load i64, ptr %g.addr
  %r.9398 = call i64 @kx_struct_get(i64 %t.9397, i32 4)
  %t.9399 = load i64, ptr %g.addr
  %r.9400 = call i64 @kx_struct_get(i64 %t.9399, i32 4)
  %ext.9402 = sext i32 0 to i64
  %r.9401 = call i64 @kx_list_get(i64 %r.9400, i64 %ext.9402)
  %ext.9403 = sext i32 1 to i64
  %t.9404 = add i64 %r.9401, %ext.9403
  %ext.9405 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9398, i64 %ext.9405, i64 %t.9404)
  %t.9406 = load i64, ptr %g.addr
  %r.9407 = call i64 @kx_struct_get(i64 %t.9406, i32 4)
  %ext.9409 = sext i32 0 to i64
  %r.9408 = call i64 @kx_list_get(i64 %r.9407, i64 %ext.9409)
  %r.9410 = call ptr @kx_int_str(i64 %r.9408)
  %r.9412 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9410)
  %ext.339 = alloca ptr
  store ptr %r.9412, ptr %ext.339
  %t.9413 = load i64, ptr %g.addr
  %t.9414 = load ptr, ptr %ext.339
  %r.9416 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9414)
  %r.9418 = call ptr @kx_str_cat(ptr %r.9416, ptr @.str.275)
  %t.9419 = load i64, ptr %ra.337
  %ext.9421 = call ptr @kx_int_str(i64 %t.9419)
  %r.9422 = call ptr @kx_str_cat(ptr %r.9418, ptr %ext.9421)
  %r.9424 = call ptr @kx_str_cat(ptr %r.9422, ptr @.str.274)
  %r.9425 = call i64 @Emit(i64 %t.9413, ptr %r.9424)
  %t.9426 = load ptr, ptr %ext.339
  %ptrtoint.9427 = ptrtoint ptr %t.9426 to i64
  store i64 %ptrtoint.9427, ptr %ra.337
  %ptrtoint.9428 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9428, ptr %rt.335
  br label %if.merge.9396
if.merge.9396:
  br label %if.merge.9352
if.merge.9352:
  br label %if.merge.9341
if.merge.9341:
  %t.9429 = load i64, ptr %g.addr
  %r.9430 = call i64 @kx_struct_get(i64 %t.9429, i32 4)
  %t.9431 = load i64, ptr %g.addr
  %r.9432 = call i64 @kx_struct_get(i64 %t.9431, i32 4)
  %ext.9434 = sext i32 0 to i64
  %r.9433 = call i64 @kx_list_get(i64 %r.9432, i64 %ext.9434)
  %ext.9435 = sext i32 1 to i64
  %t.9436 = add i64 %r.9433, %ext.9435
  %ext.9437 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9430, i64 %ext.9437, i64 %t.9436)
  %t.9438 = load i64, ptr %g.addr
  %r.9439 = call i64 @kx_struct_get(i64 %t.9438, i32 4)
  %ext.9441 = sext i32 0 to i64
  %r.9440 = call i64 @kx_list_get(i64 %r.9439, i64 %ext.9441)
  %r.9442 = call ptr @kx_int_str(i64 %r.9440)
  %r.9444 = call ptr @kx_str_cat(ptr @.str.400, ptr %r.9442)
  %t.340 = alloca ptr
  store ptr %r.9444, ptr %t.340
  %t.9445 = load i64, ptr %e.addr
  %r.9446 = call i64 @kx_struct_get(i64 %t.9445, i32 1)
  %field.9447 = inttoptr i64 %r.9446 to ptr
  %r.9449 = call i1 @kx_str_eq(ptr %field.9447, ptr @.str.126)
  br i1 %r.9449, label %if.then.9450, label %if.merge.9451
if.then.9450:
  %t.9452 = load i64, ptr %lt.334
  %ext.9454 = inttoptr i64 %t.9452 to ptr
  %r.9455 = call i1 @kx_str_eq(ptr %ext.9454, ptr @.str.271)
  %t.9456 = load i64, ptr %rt.335
  %ext.9458 = inttoptr i64 %t.9456 to ptr
  %r.9459 = call i1 @kx_str_eq(ptr %ext.9458, ptr @.str.271)
  %t.9460 = or i1 %r.9455, %r.9459
  br i1 %t.9460, label %if.then.9461, label %if.merge.9462
if.then.9461:
  %t.9463 = load i64, ptr %lt.334
  %ext.9465 = inttoptr i64 %t.9463 to ptr
  %r.9466 = call i1 @kx_str_eq(ptr %ext.9465, ptr @.str.271)
  br i1 %r.9466, label %if.then.9467, label %if.merge.9468
if.then.9467:
  %t.9469 = load i64, ptr %g.addr
  %r.9470 = call i64 @kx_struct_get(i64 %t.9469, i32 4)
  %t.9471 = load i64, ptr %g.addr
  %r.9472 = call i64 @kx_struct_get(i64 %t.9471, i32 4)
  %ext.9474 = sext i32 0 to i64
  %r.9473 = call i64 @kx_list_get(i64 %r.9472, i64 %ext.9474)
  %ext.9475 = sext i32 1 to i64
  %t.9476 = add i64 %r.9473, %ext.9475
  %ext.9477 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9470, i64 %ext.9477, i64 %t.9476)
  %t.9478 = load i64, ptr %g.addr
  %r.9479 = call i64 @kx_struct_get(i64 %t.9478, i32 4)
  %ext.9481 = sext i32 0 to i64
  %r.9480 = call i64 @kx_list_get(i64 %r.9479, i64 %ext.9481)
  %r.9482 = call ptr @kx_int_str(i64 %r.9480)
  %r.9484 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9482)
  %ext.341 = alloca ptr
  store ptr %r.9484, ptr %ext.341
  %t.9485 = load i64, ptr %g.addr
  %t.9486 = load ptr, ptr %ext.341
  %r.9488 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9486)
  %r.9490 = call ptr @kx_str_cat(ptr %r.9488, ptr @.str.394)
  %t.9491 = load i64, ptr %la.336
  %ext.9493 = call ptr @kx_int_str(i64 %t.9491)
  %r.9494 = call ptr @kx_str_cat(ptr %r.9490, ptr %ext.9493)
  %r.9496 = call ptr @kx_str_cat(ptr %r.9494, ptr @.str.100)
  %r.9497 = call i64 @Emit(i64 %t.9485, ptr %r.9496)
  %t.9498 = load ptr, ptr %ext.341
  %ptrtoint.9499 = ptrtoint ptr %t.9498 to i64
  store i64 %ptrtoint.9499, ptr %la.336
  br label %if.merge.9468
if.merge.9468:
  %t.9500 = load i64, ptr %rt.335
  %ext.9502 = inttoptr i64 %t.9500 to ptr
  %r.9503 = call i1 @kx_str_eq(ptr %ext.9502, ptr @.str.271)
  br i1 %r.9503, label %if.then.9504, label %if.merge.9505
if.then.9504:
  %t.9506 = load i64, ptr %g.addr
  %r.9507 = call i64 @kx_struct_get(i64 %t.9506, i32 4)
  %t.9508 = load i64, ptr %g.addr
  %r.9509 = call i64 @kx_struct_get(i64 %t.9508, i32 4)
  %ext.9511 = sext i32 0 to i64
  %r.9510 = call i64 @kx_list_get(i64 %r.9509, i64 %ext.9511)
  %ext.9512 = sext i32 1 to i64
  %t.9513 = add i64 %r.9510, %ext.9512
  %ext.9514 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9507, i64 %ext.9514, i64 %t.9513)
  %t.9515 = load i64, ptr %g.addr
  %r.9516 = call i64 @kx_struct_get(i64 %t.9515, i32 4)
  %ext.9518 = sext i32 0 to i64
  %r.9517 = call i64 @kx_list_get(i64 %r.9516, i64 %ext.9518)
  %r.9519 = call ptr @kx_int_str(i64 %r.9517)
  %r.9521 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9519)
  %ext.342 = alloca ptr
  store ptr %r.9521, ptr %ext.342
  %t.9522 = load i64, ptr %g.addr
  %t.9523 = load ptr, ptr %ext.342
  %r.9525 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9523)
  %r.9527 = call ptr @kx_str_cat(ptr %r.9525, ptr @.str.394)
  %t.9528 = load i64, ptr %ra.337
  %ext.9530 = call ptr @kx_int_str(i64 %t.9528)
  %r.9531 = call ptr @kx_str_cat(ptr %r.9527, ptr %ext.9530)
  %r.9533 = call ptr @kx_str_cat(ptr %r.9531, ptr @.str.100)
  %r.9534 = call i64 @Emit(i64 %t.9522, ptr %r.9533)
  %t.9535 = load ptr, ptr %ext.342
  %ptrtoint.9536 = ptrtoint ptr %t.9535 to i64
  store i64 %ptrtoint.9536, ptr %ra.337
  br label %if.merge.9505
if.merge.9505:
  %t.9537 = load i64, ptr %g.addr
  %r.9538 = call i64 @kx_struct_get(i64 %t.9537, i32 4)
  %t.9539 = load i64, ptr %g.addr
  %r.9540 = call i64 @kx_struct_get(i64 %t.9539, i32 4)
  %ext.9542 = sext i32 0 to i64
  %r.9541 = call i64 @kx_list_get(i64 %r.9540, i64 %ext.9542)
  %ext.9543 = sext i32 1 to i64
  %t.9544 = add i64 %r.9541, %ext.9543
  %ext.9545 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9538, i64 %ext.9545, i64 %t.9544)
  %t.9546 = load i64, ptr %g.addr
  %r.9547 = call i64 @kx_struct_get(i64 %t.9546, i32 4)
  %ext.9549 = sext i32 0 to i64
  %r.9548 = call i64 @kx_list_get(i64 %r.9547, i64 %ext.9549)
  %r.9550 = call ptr @kx_int_str(i64 %r.9548)
  %r.9552 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.9550)
  %r.343 = alloca ptr
  store ptr %r.9552, ptr %r.343
  %t.9553 = load i64, ptr %g.addr
  %t.9554 = load ptr, ptr %r.343
  %r.9556 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9554)
  %r.9558 = call ptr @kx_str_cat(ptr %r.9556, ptr @.str.395)
  %t.9559 = load i64, ptr %la.336
  %ext.9561 = call ptr @kx_int_str(i64 %t.9559)
  %r.9562 = call ptr @kx_str_cat(ptr %r.9558, ptr %ext.9561)
  %r.9564 = call ptr @kx_str_cat(ptr %r.9562, ptr @.str.396)
  %t.9565 = load i64, ptr %ra.337
  %ext.9567 = call ptr @kx_int_str(i64 %t.9565)
  %r.9568 = call ptr @kx_str_cat(ptr %r.9564, ptr %ext.9567)
  %r.9570 = call ptr @kx_str_cat(ptr %r.9568, ptr @.str.100)
  %r.9571 = call i64 @Emit(i64 %t.9553, ptr %r.9570)
  %t.9572 = load ptr, ptr %r.343
  %r.9574 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.9572)
  ret ptr %r.9574
dead.9575:
  br label %if.merge.9462
if.merge.9462:
  %t.9576 = load i64, ptr %g.addr
  %t.9577 = load ptr, ptr %t.340
  %r.9579 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9577)
  %r.9581 = call ptr @kx_str_cat(ptr %r.9579, ptr @.str.402)
  %t.9582 = load i64, ptr %lt.334
  %ext.9584 = call ptr @kx_int_str(i64 %t.9582)
  %r.9585 = call ptr @kx_str_cat(ptr %r.9581, ptr %ext.9584)
  %r.9587 = call ptr @kx_str_cat(ptr %r.9585, ptr @.str.8)
  %t.9588 = load i64, ptr %la.336
  %ext.9590 = call ptr @kx_int_str(i64 %t.9588)
  %r.9591 = call ptr @kx_str_cat(ptr %r.9587, ptr %ext.9590)
  %r.9593 = call ptr @kx_str_cat(ptr %r.9591, ptr @.str.403)
  %t.9594 = load i64, ptr %ra.337
  %ext.9596 = call ptr @kx_int_str(i64 %t.9594)
  %r.9597 = call ptr @kx_str_cat(ptr %r.9593, ptr %ext.9596)
  %r.9598 = call i64 @Emit(i64 %t.9576, ptr %r.9597)
  %t.9599 = load i64, ptr %lt.334
  %ext.9601 = call ptr @kx_int_str(i64 %t.9599)
  %r.9602 = call ptr @kx_str_cat(ptr %ext.9601, ptr @.str.8)
  %t.9603 = load ptr, ptr %t.340
  %r.9605 = call ptr @kx_str_cat(ptr %r.9602, ptr %t.9603)
  ret ptr %r.9605
dead.9606:
  br label %if.merge.9451
if.merge.9451:
  %t.9607 = load i64, ptr %e.addr
  %r.9608 = call i64 @kx_struct_get(i64 %t.9607, i32 1)
  %field.9609 = inttoptr i64 %r.9608 to ptr
  %r.9611 = call i1 @kx_str_eq(ptr %field.9609, ptr @.str.127)
  br i1 %r.9611, label %if.then.9612, label %if.merge.9613
if.then.9612:
  %t.9614 = load i64, ptr %lt.334
  %ext.9616 = inttoptr i64 %t.9614 to ptr
  %r.9617 = call i1 @kx_str_eq(ptr %ext.9616, ptr @.str.271)
  br i1 %r.9617, label %if.then.9618, label %if.merge.9619
if.then.9618:
  %t.9620 = load i64, ptr %g.addr
  %r.9621 = call i64 @kx_struct_get(i64 %t.9620, i32 4)
  %t.9622 = load i64, ptr %g.addr
  %r.9623 = call i64 @kx_struct_get(i64 %t.9622, i32 4)
  %ext.9625 = sext i32 0 to i64
  %r.9624 = call i64 @kx_list_get(i64 %r.9623, i64 %ext.9625)
  %ext.9626 = sext i32 1 to i64
  %t.9627 = add i64 %r.9624, %ext.9626
  %ext.9628 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9621, i64 %ext.9628, i64 %t.9627)
  %t.9629 = load i64, ptr %g.addr
  %r.9630 = call i64 @kx_struct_get(i64 %t.9629, i32 4)
  %ext.9632 = sext i32 0 to i64
  %r.9631 = call i64 @kx_list_get(i64 %r.9630, i64 %ext.9632)
  %r.9633 = call ptr @kx_int_str(i64 %r.9631)
  %r.9635 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9633)
  %ext.344 = alloca ptr
  store ptr %r.9635, ptr %ext.344
  %t.9636 = load i64, ptr %g.addr
  %t.9637 = load ptr, ptr %ext.344
  %r.9639 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9637)
  %r.9641 = call ptr @kx_str_cat(ptr %r.9639, ptr @.str.273)
  %t.9642 = load i64, ptr %la.336
  %ext.9644 = call ptr @kx_int_str(i64 %t.9642)
  %r.9645 = call ptr @kx_str_cat(ptr %r.9641, ptr %ext.9644)
  %r.9647 = call ptr @kx_str_cat(ptr %r.9645, ptr @.str.274)
  %r.9648 = call i64 @Emit(i64 %t.9636, ptr %r.9647)
  %t.9649 = load ptr, ptr %ext.344
  %ptrtoint.9650 = ptrtoint ptr %t.9649 to i64
  store i64 %ptrtoint.9650, ptr %la.336
  %ptrtoint.9651 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9651, ptr %lt.334
  br label %if.merge.9619
if.merge.9619:
  %t.9652 = load i64, ptr %rt.335
  %ext.9654 = inttoptr i64 %t.9652 to ptr
  %r.9655 = call i1 @kx_str_eq(ptr %ext.9654, ptr @.str.271)
  br i1 %r.9655, label %if.then.9656, label %if.merge.9657
if.then.9656:
  %t.9658 = load i64, ptr %g.addr
  %r.9659 = call i64 @kx_struct_get(i64 %t.9658, i32 4)
  %t.9660 = load i64, ptr %g.addr
  %r.9661 = call i64 @kx_struct_get(i64 %t.9660, i32 4)
  %ext.9663 = sext i32 0 to i64
  %r.9662 = call i64 @kx_list_get(i64 %r.9661, i64 %ext.9663)
  %ext.9664 = sext i32 1 to i64
  %t.9665 = add i64 %r.9662, %ext.9664
  %ext.9666 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9659, i64 %ext.9666, i64 %t.9665)
  %t.9667 = load i64, ptr %g.addr
  %r.9668 = call i64 @kx_struct_get(i64 %t.9667, i32 4)
  %ext.9670 = sext i32 0 to i64
  %r.9669 = call i64 @kx_list_get(i64 %r.9668, i64 %ext.9670)
  %r.9671 = call ptr @kx_int_str(i64 %r.9669)
  %r.9673 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9671)
  %ext.345 = alloca ptr
  store ptr %r.9673, ptr %ext.345
  %t.9674 = load i64, ptr %g.addr
  %t.9675 = load ptr, ptr %ext.345
  %r.9677 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9675)
  %r.9679 = call ptr @kx_str_cat(ptr %r.9677, ptr @.str.273)
  %t.9680 = load i64, ptr %ra.337
  %ext.9682 = call ptr @kx_int_str(i64 %t.9680)
  %r.9683 = call ptr @kx_str_cat(ptr %r.9679, ptr %ext.9682)
  %r.9685 = call ptr @kx_str_cat(ptr %r.9683, ptr @.str.274)
  %r.9686 = call i64 @Emit(i64 %t.9674, ptr %r.9685)
  %t.9687 = load ptr, ptr %ext.345
  %ptrtoint.9688 = ptrtoint ptr %t.9687 to i64
  store i64 %ptrtoint.9688, ptr %ra.337
  %ptrtoint.9689 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9689, ptr %rt.335
  br label %if.merge.9657
if.merge.9657:
  %t.9690 = load i64, ptr %g.addr
  %t.9691 = load ptr, ptr %t.340
  %r.9693 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9691)
  %r.9695 = call ptr @kx_str_cat(ptr %r.9693, ptr @.str.404)
  %t.9696 = load i64, ptr %lt.334
  %ext.9698 = call ptr @kx_int_str(i64 %t.9696)
  %r.9699 = call ptr @kx_str_cat(ptr %r.9695, ptr %ext.9698)
  %r.9701 = call ptr @kx_str_cat(ptr %r.9699, ptr @.str.8)
  %t.9702 = load i64, ptr %la.336
  %ext.9704 = call ptr @kx_int_str(i64 %t.9702)
  %r.9705 = call ptr @kx_str_cat(ptr %r.9701, ptr %ext.9704)
  %r.9707 = call ptr @kx_str_cat(ptr %r.9705, ptr @.str.403)
  %t.9708 = load i64, ptr %ra.337
  %ext.9710 = call ptr @kx_int_str(i64 %t.9708)
  %r.9711 = call ptr @kx_str_cat(ptr %r.9707, ptr %ext.9710)
  %r.9712 = call i64 @Emit(i64 %t.9690, ptr %r.9711)
  %t.9713 = load i64, ptr %lt.334
  %ext.9715 = call ptr @kx_int_str(i64 %t.9713)
  %r.9716 = call ptr @kx_str_cat(ptr %ext.9715, ptr @.str.8)
  %t.9717 = load ptr, ptr %t.340
  %r.9719 = call ptr @kx_str_cat(ptr %r.9716, ptr %t.9717)
  ret ptr %r.9719
dead.9720:
  br label %if.merge.9613
if.merge.9613:
  %t.9721 = load i64, ptr %e.addr
  %r.9722 = call i64 @kx_struct_get(i64 %t.9721, i32 1)
  %field.9723 = inttoptr i64 %r.9722 to ptr
  %r.9725 = call i1 @kx_str_eq(ptr %field.9723, ptr @.str.121)
  br i1 %r.9725, label %if.then.9726, label %if.merge.9727
if.then.9726:
  %t.9728 = load i64, ptr %lt.334
  %ext.9730 = inttoptr i64 %t.9728 to ptr
  %r.9731 = call i1 @kx_str_eq(ptr %ext.9730, ptr @.str.271)
  br i1 %r.9731, label %if.then.9732, label %if.merge.9733
if.then.9732:
  %t.9734 = load i64, ptr %g.addr
  %r.9735 = call i64 @kx_struct_get(i64 %t.9734, i32 4)
  %t.9736 = load i64, ptr %g.addr
  %r.9737 = call i64 @kx_struct_get(i64 %t.9736, i32 4)
  %ext.9739 = sext i32 0 to i64
  %r.9738 = call i64 @kx_list_get(i64 %r.9737, i64 %ext.9739)
  %ext.9740 = sext i32 1 to i64
  %t.9741 = add i64 %r.9738, %ext.9740
  %ext.9742 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9735, i64 %ext.9742, i64 %t.9741)
  %t.9743 = load i64, ptr %g.addr
  %r.9744 = call i64 @kx_struct_get(i64 %t.9743, i32 4)
  %ext.9746 = sext i32 0 to i64
  %r.9745 = call i64 @kx_list_get(i64 %r.9744, i64 %ext.9746)
  %r.9747 = call ptr @kx_int_str(i64 %r.9745)
  %r.9749 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9747)
  %ext.346 = alloca ptr
  store ptr %r.9749, ptr %ext.346
  %t.9750 = load i64, ptr %g.addr
  %t.9751 = load ptr, ptr %ext.346
  %r.9753 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9751)
  %r.9755 = call ptr @kx_str_cat(ptr %r.9753, ptr @.str.273)
  %t.9756 = load i64, ptr %la.336
  %ext.9758 = call ptr @kx_int_str(i64 %t.9756)
  %r.9759 = call ptr @kx_str_cat(ptr %r.9755, ptr %ext.9758)
  %r.9761 = call ptr @kx_str_cat(ptr %r.9759, ptr @.str.274)
  %r.9762 = call i64 @Emit(i64 %t.9750, ptr %r.9761)
  %t.9763 = load ptr, ptr %ext.346
  %ptrtoint.9764 = ptrtoint ptr %t.9763 to i64
  store i64 %ptrtoint.9764, ptr %la.336
  %ptrtoint.9765 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9765, ptr %lt.334
  br label %if.merge.9733
if.merge.9733:
  %t.9766 = load i64, ptr %rt.335
  %ext.9768 = inttoptr i64 %t.9766 to ptr
  %r.9769 = call i1 @kx_str_eq(ptr %ext.9768, ptr @.str.271)
  br i1 %r.9769, label %if.then.9770, label %if.merge.9771
if.then.9770:
  %t.9772 = load i64, ptr %g.addr
  %r.9773 = call i64 @kx_struct_get(i64 %t.9772, i32 4)
  %t.9774 = load i64, ptr %g.addr
  %r.9775 = call i64 @kx_struct_get(i64 %t.9774, i32 4)
  %ext.9777 = sext i32 0 to i64
  %r.9776 = call i64 @kx_list_get(i64 %r.9775, i64 %ext.9777)
  %ext.9778 = sext i32 1 to i64
  %t.9779 = add i64 %r.9776, %ext.9778
  %ext.9780 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9773, i64 %ext.9780, i64 %t.9779)
  %t.9781 = load i64, ptr %g.addr
  %r.9782 = call i64 @kx_struct_get(i64 %t.9781, i32 4)
  %ext.9784 = sext i32 0 to i64
  %r.9783 = call i64 @kx_list_get(i64 %r.9782, i64 %ext.9784)
  %r.9785 = call ptr @kx_int_str(i64 %r.9783)
  %r.9787 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9785)
  %ext.347 = alloca ptr
  store ptr %r.9787, ptr %ext.347
  %t.9788 = load i64, ptr %g.addr
  %t.9789 = load ptr, ptr %ext.347
  %r.9791 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9789)
  %r.9793 = call ptr @kx_str_cat(ptr %r.9791, ptr @.str.273)
  %t.9794 = load i64, ptr %ra.337
  %ext.9796 = call ptr @kx_int_str(i64 %t.9794)
  %r.9797 = call ptr @kx_str_cat(ptr %r.9793, ptr %ext.9796)
  %r.9799 = call ptr @kx_str_cat(ptr %r.9797, ptr @.str.274)
  %r.9800 = call i64 @Emit(i64 %t.9788, ptr %r.9799)
  %t.9801 = load ptr, ptr %ext.347
  %ptrtoint.9802 = ptrtoint ptr %t.9801 to i64
  store i64 %ptrtoint.9802, ptr %ra.337
  %ptrtoint.9803 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9803, ptr %rt.335
  br label %if.merge.9771
if.merge.9771:
  %t.9804 = load i64, ptr %g.addr
  %t.9805 = load ptr, ptr %t.340
  %r.9807 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9805)
  %r.9809 = call ptr @kx_str_cat(ptr %r.9807, ptr @.str.405)
  %t.9810 = load i64, ptr %lt.334
  %ext.9812 = call ptr @kx_int_str(i64 %t.9810)
  %r.9813 = call ptr @kx_str_cat(ptr %r.9809, ptr %ext.9812)
  %r.9815 = call ptr @kx_str_cat(ptr %r.9813, ptr @.str.8)
  %t.9816 = load i64, ptr %la.336
  %ext.9818 = call ptr @kx_int_str(i64 %t.9816)
  %r.9819 = call ptr @kx_str_cat(ptr %r.9815, ptr %ext.9818)
  %r.9821 = call ptr @kx_str_cat(ptr %r.9819, ptr @.str.403)
  %t.9822 = load i64, ptr %ra.337
  %ext.9824 = call ptr @kx_int_str(i64 %t.9822)
  %r.9825 = call ptr @kx_str_cat(ptr %r.9821, ptr %ext.9824)
  %r.9826 = call i64 @Emit(i64 %t.9804, ptr %r.9825)
  %t.9827 = load i64, ptr %lt.334
  %ext.9829 = call ptr @kx_int_str(i64 %t.9827)
  %r.9830 = call ptr @kx_str_cat(ptr %ext.9829, ptr @.str.8)
  %t.9831 = load ptr, ptr %t.340
  %r.9833 = call ptr @kx_str_cat(ptr %r.9830, ptr %t.9831)
  ret ptr %r.9833
dead.9834:
  br label %if.merge.9727
if.merge.9727:
  %t.9835 = load i64, ptr %e.addr
  %r.9836 = call i64 @kx_struct_get(i64 %t.9835, i32 1)
  %field.9837 = inttoptr i64 %r.9836 to ptr
  %r.9839 = call i1 @kx_str_eq(ptr %field.9837, ptr @.str.122)
  br i1 %r.9839, label %if.then.9840, label %if.merge.9841
if.then.9840:
  %t.9842 = load i64, ptr %lt.334
  %ext.9844 = inttoptr i64 %t.9842 to ptr
  %r.9845 = call i1 @kx_str_eq(ptr %ext.9844, ptr @.str.271)
  br i1 %r.9845, label %if.then.9846, label %if.merge.9847
if.then.9846:
  %t.9848 = load i64, ptr %g.addr
  %r.9849 = call i64 @kx_struct_get(i64 %t.9848, i32 4)
  %t.9850 = load i64, ptr %g.addr
  %r.9851 = call i64 @kx_struct_get(i64 %t.9850, i32 4)
  %ext.9853 = sext i32 0 to i64
  %r.9852 = call i64 @kx_list_get(i64 %r.9851, i64 %ext.9853)
  %ext.9854 = sext i32 1 to i64
  %t.9855 = add i64 %r.9852, %ext.9854
  %ext.9856 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9849, i64 %ext.9856, i64 %t.9855)
  %t.9857 = load i64, ptr %g.addr
  %r.9858 = call i64 @kx_struct_get(i64 %t.9857, i32 4)
  %ext.9860 = sext i32 0 to i64
  %r.9859 = call i64 @kx_list_get(i64 %r.9858, i64 %ext.9860)
  %r.9861 = call ptr @kx_int_str(i64 %r.9859)
  %r.9863 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9861)
  %ext.348 = alloca ptr
  store ptr %r.9863, ptr %ext.348
  %t.9864 = load i64, ptr %g.addr
  %t.9865 = load ptr, ptr %ext.348
  %r.9867 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9865)
  %r.9869 = call ptr @kx_str_cat(ptr %r.9867, ptr @.str.273)
  %t.9870 = load i64, ptr %la.336
  %ext.9872 = call ptr @kx_int_str(i64 %t.9870)
  %r.9873 = call ptr @kx_str_cat(ptr %r.9869, ptr %ext.9872)
  %r.9875 = call ptr @kx_str_cat(ptr %r.9873, ptr @.str.274)
  %r.9876 = call i64 @Emit(i64 %t.9864, ptr %r.9875)
  %t.9877 = load ptr, ptr %ext.348
  %ptrtoint.9878 = ptrtoint ptr %t.9877 to i64
  store i64 %ptrtoint.9878, ptr %la.336
  %ptrtoint.9879 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9879, ptr %lt.334
  br label %if.merge.9847
if.merge.9847:
  %t.9880 = load i64, ptr %rt.335
  %ext.9882 = inttoptr i64 %t.9880 to ptr
  %r.9883 = call i1 @kx_str_eq(ptr %ext.9882, ptr @.str.271)
  br i1 %r.9883, label %if.then.9884, label %if.merge.9885
if.then.9884:
  %t.9886 = load i64, ptr %g.addr
  %r.9887 = call i64 @kx_struct_get(i64 %t.9886, i32 4)
  %t.9888 = load i64, ptr %g.addr
  %r.9889 = call i64 @kx_struct_get(i64 %t.9888, i32 4)
  %ext.9891 = sext i32 0 to i64
  %r.9890 = call i64 @kx_list_get(i64 %r.9889, i64 %ext.9891)
  %ext.9892 = sext i32 1 to i64
  %t.9893 = add i64 %r.9890, %ext.9892
  %ext.9894 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9887, i64 %ext.9894, i64 %t.9893)
  %t.9895 = load i64, ptr %g.addr
  %r.9896 = call i64 @kx_struct_get(i64 %t.9895, i32 4)
  %ext.9898 = sext i32 0 to i64
  %r.9897 = call i64 @kx_list_get(i64 %r.9896, i64 %ext.9898)
  %r.9899 = call ptr @kx_int_str(i64 %r.9897)
  %r.9901 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9899)
  %ext.349 = alloca ptr
  store ptr %r.9901, ptr %ext.349
  %t.9902 = load i64, ptr %g.addr
  %t.9903 = load ptr, ptr %ext.349
  %r.9905 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9903)
  %r.9907 = call ptr @kx_str_cat(ptr %r.9905, ptr @.str.273)
  %t.9908 = load i64, ptr %ra.337
  %ext.9910 = call ptr @kx_int_str(i64 %t.9908)
  %r.9911 = call ptr @kx_str_cat(ptr %r.9907, ptr %ext.9910)
  %r.9913 = call ptr @kx_str_cat(ptr %r.9911, ptr @.str.274)
  %r.9914 = call i64 @Emit(i64 %t.9902, ptr %r.9913)
  %t.9915 = load ptr, ptr %ext.349
  %ptrtoint.9916 = ptrtoint ptr %t.9915 to i64
  store i64 %ptrtoint.9916, ptr %ra.337
  %ptrtoint.9917 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9917, ptr %rt.335
  br label %if.merge.9885
if.merge.9885:
  %t.9918 = load i64, ptr %g.addr
  %t.9919 = load ptr, ptr %t.340
  %r.9921 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9919)
  %r.9923 = call ptr @kx_str_cat(ptr %r.9921, ptr @.str.406)
  %t.9924 = load i64, ptr %lt.334
  %ext.9926 = call ptr @kx_int_str(i64 %t.9924)
  %r.9927 = call ptr @kx_str_cat(ptr %r.9923, ptr %ext.9926)
  %r.9929 = call ptr @kx_str_cat(ptr %r.9927, ptr @.str.8)
  %t.9930 = load i64, ptr %la.336
  %ext.9932 = call ptr @kx_int_str(i64 %t.9930)
  %r.9933 = call ptr @kx_str_cat(ptr %r.9929, ptr %ext.9932)
  %r.9935 = call ptr @kx_str_cat(ptr %r.9933, ptr @.str.403)
  %t.9936 = load i64, ptr %ra.337
  %ext.9938 = call ptr @kx_int_str(i64 %t.9936)
  %r.9939 = call ptr @kx_str_cat(ptr %r.9935, ptr %ext.9938)
  %r.9940 = call i64 @Emit(i64 %t.9918, ptr %r.9939)
  %t.9941 = load i64, ptr %lt.334
  %ext.9943 = call ptr @kx_int_str(i64 %t.9941)
  %r.9944 = call ptr @kx_str_cat(ptr %ext.9943, ptr @.str.8)
  %t.9945 = load ptr, ptr %t.340
  %r.9947 = call ptr @kx_str_cat(ptr %r.9944, ptr %t.9945)
  ret ptr %r.9947
dead.9948:
  br label %if.merge.9841
if.merge.9841:
  %t.9949 = load i64, ptr %e.addr
  %r.9950 = call i64 @kx_struct_get(i64 %t.9949, i32 1)
  %field.9951 = inttoptr i64 %r.9950 to ptr
  %r.9953 = call i1 @kx_str_eq(ptr %field.9951, ptr @.str.124)
  br i1 %r.9953, label %if.then.9954, label %if.merge.9955
if.then.9954:
  %t.9956 = load i64, ptr %lt.334
  %ext.9958 = inttoptr i64 %t.9956 to ptr
  %r.9959 = call i1 @kx_str_eq(ptr %ext.9958, ptr @.str.271)
  br i1 %r.9959, label %if.then.9960, label %if.merge.9961
if.then.9960:
  %t.9962 = load i64, ptr %g.addr
  %r.9963 = call i64 @kx_struct_get(i64 %t.9962, i32 4)
  %t.9964 = load i64, ptr %g.addr
  %r.9965 = call i64 @kx_struct_get(i64 %t.9964, i32 4)
  %ext.9967 = sext i32 0 to i64
  %r.9966 = call i64 @kx_list_get(i64 %r.9965, i64 %ext.9967)
  %ext.9968 = sext i32 1 to i64
  %t.9969 = add i64 %r.9966, %ext.9968
  %ext.9970 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.9963, i64 %ext.9970, i64 %t.9969)
  %t.9971 = load i64, ptr %g.addr
  %r.9972 = call i64 @kx_struct_get(i64 %t.9971, i32 4)
  %ext.9974 = sext i32 0 to i64
  %r.9973 = call i64 @kx_list_get(i64 %r.9972, i64 %ext.9974)
  %r.9975 = call ptr @kx_int_str(i64 %r.9973)
  %r.9977 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.9975)
  %ext.350 = alloca ptr
  store ptr %r.9977, ptr %ext.350
  %t.9978 = load i64, ptr %g.addr
  %t.9979 = load ptr, ptr %ext.350
  %r.9981 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.9979)
  %r.9983 = call ptr @kx_str_cat(ptr %r.9981, ptr @.str.273)
  %t.9984 = load i64, ptr %la.336
  %ext.9986 = call ptr @kx_int_str(i64 %t.9984)
  %r.9987 = call ptr @kx_str_cat(ptr %r.9983, ptr %ext.9986)
  %r.9989 = call ptr @kx_str_cat(ptr %r.9987, ptr @.str.274)
  %r.9990 = call i64 @Emit(i64 %t.9978, ptr %r.9989)
  %t.9991 = load ptr, ptr %ext.350
  %ptrtoint.9992 = ptrtoint ptr %t.9991 to i64
  store i64 %ptrtoint.9992, ptr %la.336
  %ptrtoint.9993 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.9993, ptr %lt.334
  br label %if.merge.9961
if.merge.9961:
  %t.9994 = load i64, ptr %rt.335
  %ext.9996 = inttoptr i64 %t.9994 to ptr
  %r.9997 = call i1 @kx_str_eq(ptr %ext.9996, ptr @.str.271)
  br i1 %r.9997, label %if.then.9998, label %if.merge.9999
if.then.9998:
  %t.10000 = load i64, ptr %g.addr
  %r.10001 = call i64 @kx_struct_get(i64 %t.10000, i32 4)
  %t.10002 = load i64, ptr %g.addr
  %r.10003 = call i64 @kx_struct_get(i64 %t.10002, i32 4)
  %ext.10005 = sext i32 0 to i64
  %r.10004 = call i64 @kx_list_get(i64 %r.10003, i64 %ext.10005)
  %ext.10006 = sext i32 1 to i64
  %t.10007 = add i64 %r.10004, %ext.10006
  %ext.10008 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10001, i64 %ext.10008, i64 %t.10007)
  %t.10009 = load i64, ptr %g.addr
  %r.10010 = call i64 @kx_struct_get(i64 %t.10009, i32 4)
  %ext.10012 = sext i32 0 to i64
  %r.10011 = call i64 @kx_list_get(i64 %r.10010, i64 %ext.10012)
  %r.10013 = call ptr @kx_int_str(i64 %r.10011)
  %r.10015 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10013)
  %ext.351 = alloca ptr
  store ptr %r.10015, ptr %ext.351
  %t.10016 = load i64, ptr %g.addr
  %t.10017 = load ptr, ptr %ext.351
  %r.10019 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10017)
  %r.10021 = call ptr @kx_str_cat(ptr %r.10019, ptr @.str.273)
  %t.10022 = load i64, ptr %ra.337
  %ext.10024 = call ptr @kx_int_str(i64 %t.10022)
  %r.10025 = call ptr @kx_str_cat(ptr %r.10021, ptr %ext.10024)
  %r.10027 = call ptr @kx_str_cat(ptr %r.10025, ptr @.str.274)
  %r.10028 = call i64 @Emit(i64 %t.10016, ptr %r.10027)
  %t.10029 = load ptr, ptr %ext.351
  %ptrtoint.10030 = ptrtoint ptr %t.10029 to i64
  store i64 %ptrtoint.10030, ptr %ra.337
  %ptrtoint.10031 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.10031, ptr %rt.335
  br label %if.merge.9999
if.merge.9999:
  %t.10032 = load i64, ptr %g.addr
  %t.10033 = load ptr, ptr %t.340
  %r.10035 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10033)
  %r.10037 = call ptr @kx_str_cat(ptr %r.10035, ptr @.str.407)
  %t.10038 = load i64, ptr %lt.334
  %ext.10040 = call ptr @kx_int_str(i64 %t.10038)
  %r.10041 = call ptr @kx_str_cat(ptr %r.10037, ptr %ext.10040)
  %r.10043 = call ptr @kx_str_cat(ptr %r.10041, ptr @.str.8)
  %t.10044 = load i64, ptr %la.336
  %ext.10046 = call ptr @kx_int_str(i64 %t.10044)
  %r.10047 = call ptr @kx_str_cat(ptr %r.10043, ptr %ext.10046)
  %r.10049 = call ptr @kx_str_cat(ptr %r.10047, ptr @.str.403)
  %t.10050 = load i64, ptr %ra.337
  %ext.10052 = call ptr @kx_int_str(i64 %t.10050)
  %r.10053 = call ptr @kx_str_cat(ptr %r.10049, ptr %ext.10052)
  %r.10054 = call i64 @Emit(i64 %t.10032, ptr %r.10053)
  %t.10055 = load i64, ptr %lt.334
  %ext.10057 = call ptr @kx_int_str(i64 %t.10055)
  %r.10058 = call ptr @kx_str_cat(ptr %ext.10057, ptr @.str.8)
  %t.10059 = load ptr, ptr %t.340
  %r.10061 = call ptr @kx_str_cat(ptr %r.10058, ptr %t.10059)
  ret ptr %r.10061
dead.10062:
  br label %if.merge.9955
if.merge.9955:
  %t.10063 = load i64, ptr %e.addr
  %r.10064 = call i64 @kx_struct_get(i64 %t.10063, i32 1)
  %field.10065 = inttoptr i64 %r.10064 to ptr
  %r.10067 = call i1 @kx_str_eq(ptr %field.10065, ptr @.str.132)
  br i1 %r.10067, label %if.then.10068, label %if.merge.10069
if.then.10068:
  %t.10070 = load i64, ptr %lt.334
  %ext.10072 = inttoptr i64 %t.10070 to ptr
  %r.10073 = call i1 @kx_str_eq(ptr %ext.10072, ptr @.str.271)
  %t.10074 = load i64, ptr %rt.335
  %ext.10076 = inttoptr i64 %t.10074 to ptr
  %r.10077 = call i1 @kx_str_eq(ptr %ext.10076, ptr @.str.271)
  %t.10078 = or i1 %r.10073, %r.10077
  br i1 %t.10078, label %if.then.10079, label %if.merge.10080
if.then.10079:
  %t.10081 = load i64, ptr %lt.334
  %ext.10083 = inttoptr i64 %t.10081 to ptr
  %r.10084 = call i1 @kx_str_eq(ptr %ext.10083, ptr @.str.271)
  br i1 %r.10084, label %if.then.10085, label %if.merge.10086
if.then.10085:
  %t.10087 = load i64, ptr %g.addr
  %r.10088 = call i64 @kx_struct_get(i64 %t.10087, i32 4)
  %t.10089 = load i64, ptr %g.addr
  %r.10090 = call i64 @kx_struct_get(i64 %t.10089, i32 4)
  %ext.10092 = sext i32 0 to i64
  %r.10091 = call i64 @kx_list_get(i64 %r.10090, i64 %ext.10092)
  %ext.10093 = sext i32 1 to i64
  %t.10094 = add i64 %r.10091, %ext.10093
  %ext.10095 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10088, i64 %ext.10095, i64 %t.10094)
  %t.10096 = load i64, ptr %g.addr
  %r.10097 = call i64 @kx_struct_get(i64 %t.10096, i32 4)
  %ext.10099 = sext i32 0 to i64
  %r.10098 = call i64 @kx_list_get(i64 %r.10097, i64 %ext.10099)
  %r.10100 = call ptr @kx_int_str(i64 %r.10098)
  %r.10102 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10100)
  %ext.352 = alloca ptr
  store ptr %r.10102, ptr %ext.352
  %t.10103 = load i64, ptr %g.addr
  %t.10104 = load ptr, ptr %ext.352
  %r.10106 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10104)
  %r.10108 = call ptr @kx_str_cat(ptr %r.10106, ptr @.str.277)
  %t.10109 = load i64, ptr %la.336
  %ext.10111 = call ptr @kx_int_str(i64 %t.10109)
  %r.10112 = call ptr @kx_str_cat(ptr %r.10108, ptr %ext.10111)
  %r.10114 = call ptr @kx_str_cat(ptr %r.10112, ptr @.str.278)
  %r.10115 = call i64 @Emit(i64 %t.10103, ptr %r.10114)
  %t.10116 = load ptr, ptr %ext.352
  %ptrtoint.10117 = ptrtoint ptr %t.10116 to i64
  store i64 %ptrtoint.10117, ptr %la.336
  br label %if.merge.10086
if.merge.10086:
  %t.10118 = load i64, ptr %rt.335
  %ext.10120 = inttoptr i64 %t.10118 to ptr
  %r.10121 = call i1 @kx_str_eq(ptr %ext.10120, ptr @.str.271)
  br i1 %r.10121, label %if.then.10122, label %if.merge.10123
if.then.10122:
  %t.10124 = load i64, ptr %g.addr
  %r.10125 = call i64 @kx_struct_get(i64 %t.10124, i32 4)
  %t.10126 = load i64, ptr %g.addr
  %r.10127 = call i64 @kx_struct_get(i64 %t.10126, i32 4)
  %ext.10129 = sext i32 0 to i64
  %r.10128 = call i64 @kx_list_get(i64 %r.10127, i64 %ext.10129)
  %ext.10130 = sext i32 1 to i64
  %t.10131 = add i64 %r.10128, %ext.10130
  %ext.10132 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10125, i64 %ext.10132, i64 %t.10131)
  %t.10133 = load i64, ptr %g.addr
  %r.10134 = call i64 @kx_struct_get(i64 %t.10133, i32 4)
  %ext.10136 = sext i32 0 to i64
  %r.10135 = call i64 @kx_list_get(i64 %r.10134, i64 %ext.10136)
  %r.10137 = call ptr @kx_int_str(i64 %r.10135)
  %r.10139 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10137)
  %ext.353 = alloca ptr
  store ptr %r.10139, ptr %ext.353
  %t.10140 = load i64, ptr %g.addr
  %t.10141 = load ptr, ptr %ext.353
  %r.10143 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10141)
  %r.10145 = call ptr @kx_str_cat(ptr %r.10143, ptr @.str.277)
  %t.10146 = load i64, ptr %ra.337
  %ext.10148 = call ptr @kx_int_str(i64 %t.10146)
  %r.10149 = call ptr @kx_str_cat(ptr %r.10145, ptr %ext.10148)
  %r.10151 = call ptr @kx_str_cat(ptr %r.10149, ptr @.str.278)
  %r.10152 = call i64 @Emit(i64 %t.10140, ptr %r.10151)
  %t.10153 = load ptr, ptr %ext.353
  %ptrtoint.10154 = ptrtoint ptr %t.10153 to i64
  store i64 %ptrtoint.10154, ptr %ra.337
  br label %if.merge.10123
if.merge.10123:
  %t.10155 = load i64, ptr %g.addr
  %r.10156 = call i64 @kx_struct_get(i64 %t.10155, i32 4)
  %t.10157 = load i64, ptr %g.addr
  %r.10158 = call i64 @kx_struct_get(i64 %t.10157, i32 4)
  %ext.10160 = sext i32 0 to i64
  %r.10159 = call i64 @kx_list_get(i64 %r.10158, i64 %ext.10160)
  %ext.10161 = sext i32 1 to i64
  %t.10162 = add i64 %r.10159, %ext.10161
  %ext.10163 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10156, i64 %ext.10163, i64 %t.10162)
  %t.10164 = load i64, ptr %g.addr
  %r.10165 = call i64 @kx_struct_get(i64 %t.10164, i32 4)
  %ext.10167 = sext i32 0 to i64
  %r.10166 = call i64 @kx_list_get(i64 %r.10165, i64 %ext.10167)
  %r.10168 = call ptr @kx_int_str(i64 %r.10166)
  %r.10170 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10168)
  %r.354 = alloca ptr
  store ptr %r.10170, ptr %r.354
  %t.10171 = load i64, ptr %g.addr
  %t.10172 = load ptr, ptr %r.354
  %r.10174 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10172)
  %r.10176 = call ptr @kx_str_cat(ptr %r.10174, ptr @.str.408)
  %t.10177 = load i64, ptr %la.336
  %ext.10179 = call ptr @kx_int_str(i64 %t.10177)
  %r.10180 = call ptr @kx_str_cat(ptr %r.10176, ptr %ext.10179)
  %r.10182 = call ptr @kx_str_cat(ptr %r.10180, ptr @.str.396)
  %t.10183 = load i64, ptr %ra.337
  %ext.10185 = call ptr @kx_int_str(i64 %t.10183)
  %r.10186 = call ptr @kx_str_cat(ptr %r.10182, ptr %ext.10185)
  %r.10188 = call ptr @kx_str_cat(ptr %r.10186, ptr @.str.100)
  %r.10189 = call i64 @Emit(i64 %t.10171, ptr %r.10188)
  %t.10190 = load ptr, ptr %r.354
  %r.10192 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10190)
  ret ptr %r.10192
dead.10193:
  br label %if.merge.10080
if.merge.10080:
  %t.10194 = load i64, ptr %g.addr
  %t.10195 = load ptr, ptr %t.340
  %r.10197 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10195)
  %r.10199 = call ptr @kx_str_cat(ptr %r.10197, ptr @.str.409)
  %t.10200 = load i64, ptr %lt.334
  %ext.10202 = call ptr @kx_int_str(i64 %t.10200)
  %r.10203 = call ptr @kx_str_cat(ptr %r.10199, ptr %ext.10202)
  %r.10205 = call ptr @kx_str_cat(ptr %r.10203, ptr @.str.8)
  %t.10206 = load i64, ptr %la.336
  %ext.10208 = call ptr @kx_int_str(i64 %t.10206)
  %r.10209 = call ptr @kx_str_cat(ptr %r.10205, ptr %ext.10208)
  %r.10211 = call ptr @kx_str_cat(ptr %r.10209, ptr @.str.403)
  %t.10212 = load i64, ptr %ra.337
  %ext.10214 = call ptr @kx_int_str(i64 %t.10212)
  %r.10215 = call ptr @kx_str_cat(ptr %r.10211, ptr %ext.10214)
  %r.10216 = call i64 @Emit(i64 %t.10194, ptr %r.10215)
  %t.10217 = load ptr, ptr %t.340
  %r.10219 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10217)
  ret ptr %r.10219
dead.10220:
  br label %if.merge.10069
if.merge.10069:
  %t.10221 = load i64, ptr %e.addr
  %r.10222 = call i64 @kx_struct_get(i64 %t.10221, i32 1)
  %field.10223 = inttoptr i64 %r.10222 to ptr
  %r.10225 = call i1 @kx_str_eq(ptr %field.10223, ptr @.str.128)
  br i1 %r.10225, label %if.then.10226, label %if.merge.10227
if.then.10226:
  %t.10228 = load i64, ptr %lt.334
  %ext.10230 = inttoptr i64 %t.10228 to ptr
  %r.10231 = call i1 @kx_str_eq(ptr %ext.10230, ptr @.str.271)
  %t.10232 = load i64, ptr %rt.335
  %ext.10234 = inttoptr i64 %t.10232 to ptr
  %r.10235 = call i1 @kx_str_eq(ptr %ext.10234, ptr @.str.271)
  %t.10236 = or i1 %r.10231, %r.10235
  br i1 %t.10236, label %if.then.10237, label %if.merge.10238
if.then.10237:
  %t.10239 = load i64, ptr %lt.334
  %ext.10241 = inttoptr i64 %t.10239 to ptr
  %r.10242 = call i1 @kx_str_eq(ptr %ext.10241, ptr @.str.271)
  br i1 %r.10242, label %if.then.10243, label %if.merge.10244
if.then.10243:
  %t.10245 = load i64, ptr %g.addr
  %r.10246 = call i64 @kx_struct_get(i64 %t.10245, i32 4)
  %t.10247 = load i64, ptr %g.addr
  %r.10248 = call i64 @kx_struct_get(i64 %t.10247, i32 4)
  %ext.10250 = sext i32 0 to i64
  %r.10249 = call i64 @kx_list_get(i64 %r.10248, i64 %ext.10250)
  %ext.10251 = sext i32 1 to i64
  %t.10252 = add i64 %r.10249, %ext.10251
  %ext.10253 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10246, i64 %ext.10253, i64 %t.10252)
  %t.10254 = load i64, ptr %g.addr
  %r.10255 = call i64 @kx_struct_get(i64 %t.10254, i32 4)
  %ext.10257 = sext i32 0 to i64
  %r.10256 = call i64 @kx_list_get(i64 %r.10255, i64 %ext.10257)
  %r.10258 = call ptr @kx_int_str(i64 %r.10256)
  %r.10260 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10258)
  %ext.355 = alloca ptr
  store ptr %r.10260, ptr %ext.355
  %t.10261 = load i64, ptr %g.addr
  %t.10262 = load ptr, ptr %ext.355
  %r.10264 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10262)
  %r.10266 = call ptr @kx_str_cat(ptr %r.10264, ptr @.str.277)
  %t.10267 = load i64, ptr %la.336
  %ext.10269 = call ptr @kx_int_str(i64 %t.10267)
  %r.10270 = call ptr @kx_str_cat(ptr %r.10266, ptr %ext.10269)
  %r.10272 = call ptr @kx_str_cat(ptr %r.10270, ptr @.str.278)
  %r.10273 = call i64 @Emit(i64 %t.10261, ptr %r.10272)
  %t.10274 = load ptr, ptr %ext.355
  %ptrtoint.10275 = ptrtoint ptr %t.10274 to i64
  store i64 %ptrtoint.10275, ptr %la.336
  br label %if.merge.10244
if.merge.10244:
  %t.10276 = load i64, ptr %rt.335
  %ext.10278 = inttoptr i64 %t.10276 to ptr
  %r.10279 = call i1 @kx_str_eq(ptr %ext.10278, ptr @.str.271)
  br i1 %r.10279, label %if.then.10280, label %if.merge.10281
if.then.10280:
  %t.10282 = load i64, ptr %g.addr
  %r.10283 = call i64 @kx_struct_get(i64 %t.10282, i32 4)
  %t.10284 = load i64, ptr %g.addr
  %r.10285 = call i64 @kx_struct_get(i64 %t.10284, i32 4)
  %ext.10287 = sext i32 0 to i64
  %r.10286 = call i64 @kx_list_get(i64 %r.10285, i64 %ext.10287)
  %ext.10288 = sext i32 1 to i64
  %t.10289 = add i64 %r.10286, %ext.10288
  %ext.10290 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10283, i64 %ext.10290, i64 %t.10289)
  %t.10291 = load i64, ptr %g.addr
  %r.10292 = call i64 @kx_struct_get(i64 %t.10291, i32 4)
  %ext.10294 = sext i32 0 to i64
  %r.10293 = call i64 @kx_list_get(i64 %r.10292, i64 %ext.10294)
  %r.10295 = call ptr @kx_int_str(i64 %r.10293)
  %r.10297 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10295)
  %ext.356 = alloca ptr
  store ptr %r.10297, ptr %ext.356
  %t.10298 = load i64, ptr %g.addr
  %t.10299 = load ptr, ptr %ext.356
  %r.10301 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10299)
  %r.10303 = call ptr @kx_str_cat(ptr %r.10301, ptr @.str.277)
  %t.10304 = load i64, ptr %ra.337
  %ext.10306 = call ptr @kx_int_str(i64 %t.10304)
  %r.10307 = call ptr @kx_str_cat(ptr %r.10303, ptr %ext.10306)
  %r.10309 = call ptr @kx_str_cat(ptr %r.10307, ptr @.str.278)
  %r.10310 = call i64 @Emit(i64 %t.10298, ptr %r.10309)
  %t.10311 = load ptr, ptr %ext.356
  %ptrtoint.10312 = ptrtoint ptr %t.10311 to i64
  store i64 %ptrtoint.10312, ptr %ra.337
  br label %if.merge.10281
if.merge.10281:
  %t.10313 = load i64, ptr %g.addr
  %r.10314 = call i64 @kx_struct_get(i64 %t.10313, i32 4)
  %t.10315 = load i64, ptr %g.addr
  %r.10316 = call i64 @kx_struct_get(i64 %t.10315, i32 4)
  %ext.10318 = sext i32 0 to i64
  %r.10317 = call i64 @kx_list_get(i64 %r.10316, i64 %ext.10318)
  %ext.10319 = sext i32 1 to i64
  %t.10320 = add i64 %r.10317, %ext.10319
  %ext.10321 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10314, i64 %ext.10321, i64 %t.10320)
  %t.10322 = load i64, ptr %g.addr
  %r.10323 = call i64 @kx_struct_get(i64 %t.10322, i32 4)
  %ext.10325 = sext i32 0 to i64
  %r.10324 = call i64 @kx_list_get(i64 %r.10323, i64 %ext.10325)
  %r.10326 = call ptr @kx_int_str(i64 %r.10324)
  %r.10328 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10326)
  %r.357 = alloca ptr
  store ptr %r.10328, ptr %r.357
  %t.10329 = load i64, ptr %g.addr
  %t.10330 = load ptr, ptr %r.357
  %r.10332 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10330)
  %r.10334 = call ptr @kx_str_cat(ptr %r.10332, ptr @.str.410)
  %t.10335 = load i64, ptr %la.336
  %ext.10337 = call ptr @kx_int_str(i64 %t.10335)
  %r.10338 = call ptr @kx_str_cat(ptr %r.10334, ptr %ext.10337)
  %r.10340 = call ptr @kx_str_cat(ptr %r.10338, ptr @.str.396)
  %t.10341 = load i64, ptr %ra.337
  %ext.10343 = call ptr @kx_int_str(i64 %t.10341)
  %r.10344 = call ptr @kx_str_cat(ptr %r.10340, ptr %ext.10343)
  %r.10346 = call ptr @kx_str_cat(ptr %r.10344, ptr @.str.100)
  %r.10347 = call i64 @Emit(i64 %t.10329, ptr %r.10346)
  %t.10348 = load ptr, ptr %r.357
  %r.10350 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10348)
  ret ptr %r.10350
dead.10351:
  br label %if.merge.10238
if.merge.10238:
  %t.10352 = load i64, ptr %g.addr
  %t.10353 = load ptr, ptr %t.340
  %r.10355 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10353)
  %r.10357 = call ptr @kx_str_cat(ptr %r.10355, ptr @.str.411)
  %t.10358 = load i64, ptr %lt.334
  %ext.10360 = call ptr @kx_int_str(i64 %t.10358)
  %r.10361 = call ptr @kx_str_cat(ptr %r.10357, ptr %ext.10360)
  %r.10363 = call ptr @kx_str_cat(ptr %r.10361, ptr @.str.8)
  %t.10364 = load i64, ptr %la.336
  %ext.10366 = call ptr @kx_int_str(i64 %t.10364)
  %r.10367 = call ptr @kx_str_cat(ptr %r.10363, ptr %ext.10366)
  %r.10369 = call ptr @kx_str_cat(ptr %r.10367, ptr @.str.403)
  %t.10370 = load i64, ptr %ra.337
  %ext.10372 = call ptr @kx_int_str(i64 %t.10370)
  %r.10373 = call ptr @kx_str_cat(ptr %r.10369, ptr %ext.10372)
  %r.10374 = call i64 @Emit(i64 %t.10352, ptr %r.10373)
  %t.10375 = load ptr, ptr %t.340
  %r.10377 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10375)
  ret ptr %r.10377
dead.10378:
  br label %if.merge.10227
if.merge.10227:
  %t.10379 = load i64, ptr %e.addr
  %r.10380 = call i64 @kx_struct_get(i64 %t.10379, i32 1)
  %field.10381 = inttoptr i64 %r.10380 to ptr
  %r.10383 = call i1 @kx_str_eq(ptr %field.10381, ptr @.str.129)
  br i1 %r.10383, label %if.then.10384, label %if.merge.10385
if.then.10384:
  %t.10386 = load i64, ptr %lt.334
  %ext.10388 = inttoptr i64 %t.10386 to ptr
  %r.10389 = call i1 @kx_str_eq(ptr %ext.10388, ptr @.str.271)
  %t.10390 = load i64, ptr %rt.335
  %ext.10392 = inttoptr i64 %t.10390 to ptr
  %r.10393 = call i1 @kx_str_eq(ptr %ext.10392, ptr @.str.271)
  %t.10394 = or i1 %r.10389, %r.10393
  br i1 %t.10394, label %if.then.10395, label %if.merge.10396
if.then.10395:
  %t.10397 = load i64, ptr %lt.334
  %ext.10399 = inttoptr i64 %t.10397 to ptr
  %r.10400 = call i1 @kx_str_eq(ptr %ext.10399, ptr @.str.271)
  br i1 %r.10400, label %if.then.10401, label %if.merge.10402
if.then.10401:
  %t.10403 = load i64, ptr %g.addr
  %r.10404 = call i64 @kx_struct_get(i64 %t.10403, i32 4)
  %t.10405 = load i64, ptr %g.addr
  %r.10406 = call i64 @kx_struct_get(i64 %t.10405, i32 4)
  %ext.10408 = sext i32 0 to i64
  %r.10407 = call i64 @kx_list_get(i64 %r.10406, i64 %ext.10408)
  %ext.10409 = sext i32 1 to i64
  %t.10410 = add i64 %r.10407, %ext.10409
  %ext.10411 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10404, i64 %ext.10411, i64 %t.10410)
  %t.10412 = load i64, ptr %g.addr
  %r.10413 = call i64 @kx_struct_get(i64 %t.10412, i32 4)
  %ext.10415 = sext i32 0 to i64
  %r.10414 = call i64 @kx_list_get(i64 %r.10413, i64 %ext.10415)
  %r.10416 = call ptr @kx_int_str(i64 %r.10414)
  %r.10418 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10416)
  %ext.358 = alloca ptr
  store ptr %r.10418, ptr %ext.358
  %t.10419 = load i64, ptr %g.addr
  %t.10420 = load ptr, ptr %ext.358
  %r.10422 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10420)
  %r.10424 = call ptr @kx_str_cat(ptr %r.10422, ptr @.str.277)
  %t.10425 = load i64, ptr %la.336
  %ext.10427 = call ptr @kx_int_str(i64 %t.10425)
  %r.10428 = call ptr @kx_str_cat(ptr %r.10424, ptr %ext.10427)
  %r.10430 = call ptr @kx_str_cat(ptr %r.10428, ptr @.str.278)
  %r.10431 = call i64 @Emit(i64 %t.10419, ptr %r.10430)
  %t.10432 = load ptr, ptr %ext.358
  %ptrtoint.10433 = ptrtoint ptr %t.10432 to i64
  store i64 %ptrtoint.10433, ptr %la.336
  br label %if.merge.10402
if.merge.10402:
  %t.10434 = load i64, ptr %rt.335
  %ext.10436 = inttoptr i64 %t.10434 to ptr
  %r.10437 = call i1 @kx_str_eq(ptr %ext.10436, ptr @.str.271)
  br i1 %r.10437, label %if.then.10438, label %if.merge.10439
if.then.10438:
  %t.10440 = load i64, ptr %g.addr
  %r.10441 = call i64 @kx_struct_get(i64 %t.10440, i32 4)
  %t.10442 = load i64, ptr %g.addr
  %r.10443 = call i64 @kx_struct_get(i64 %t.10442, i32 4)
  %ext.10445 = sext i32 0 to i64
  %r.10444 = call i64 @kx_list_get(i64 %r.10443, i64 %ext.10445)
  %ext.10446 = sext i32 1 to i64
  %t.10447 = add i64 %r.10444, %ext.10446
  %ext.10448 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10441, i64 %ext.10448, i64 %t.10447)
  %t.10449 = load i64, ptr %g.addr
  %r.10450 = call i64 @kx_struct_get(i64 %t.10449, i32 4)
  %ext.10452 = sext i32 0 to i64
  %r.10451 = call i64 @kx_list_get(i64 %r.10450, i64 %ext.10452)
  %r.10453 = call ptr @kx_int_str(i64 %r.10451)
  %r.10455 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10453)
  %ext.359 = alloca ptr
  store ptr %r.10455, ptr %ext.359
  %t.10456 = load i64, ptr %g.addr
  %t.10457 = load ptr, ptr %ext.359
  %r.10459 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10457)
  %r.10461 = call ptr @kx_str_cat(ptr %r.10459, ptr @.str.277)
  %t.10462 = load i64, ptr %ra.337
  %ext.10464 = call ptr @kx_int_str(i64 %t.10462)
  %r.10465 = call ptr @kx_str_cat(ptr %r.10461, ptr %ext.10464)
  %r.10467 = call ptr @kx_str_cat(ptr %r.10465, ptr @.str.278)
  %r.10468 = call i64 @Emit(i64 %t.10456, ptr %r.10467)
  %t.10469 = load ptr, ptr %ext.359
  %ptrtoint.10470 = ptrtoint ptr %t.10469 to i64
  store i64 %ptrtoint.10470, ptr %ra.337
  br label %if.merge.10439
if.merge.10439:
  %t.10471 = load i64, ptr %g.addr
  %r.10472 = call i64 @kx_struct_get(i64 %t.10471, i32 4)
  %t.10473 = load i64, ptr %g.addr
  %r.10474 = call i64 @kx_struct_get(i64 %t.10473, i32 4)
  %ext.10476 = sext i32 0 to i64
  %r.10475 = call i64 @kx_list_get(i64 %r.10474, i64 %ext.10476)
  %ext.10477 = sext i32 1 to i64
  %t.10478 = add i64 %r.10475, %ext.10477
  %ext.10479 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10472, i64 %ext.10479, i64 %t.10478)
  %t.10480 = load i64, ptr %g.addr
  %r.10481 = call i64 @kx_struct_get(i64 %t.10480, i32 4)
  %ext.10483 = sext i32 0 to i64
  %r.10482 = call i64 @kx_list_get(i64 %r.10481, i64 %ext.10483)
  %r.10484 = call ptr @kx_int_str(i64 %r.10482)
  %r.10486 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10484)
  %r.360 = alloca ptr
  store ptr %r.10486, ptr %r.360
  %t.10487 = load i64, ptr %g.addr
  %t.10488 = load ptr, ptr %r.360
  %r.10490 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10488)
  %r.10492 = call ptr @kx_str_cat(ptr %r.10490, ptr @.str.412)
  %t.10493 = load i64, ptr %la.336
  %ext.10495 = call ptr @kx_int_str(i64 %t.10493)
  %r.10496 = call ptr @kx_str_cat(ptr %r.10492, ptr %ext.10495)
  %r.10498 = call ptr @kx_str_cat(ptr %r.10496, ptr @.str.396)
  %t.10499 = load i64, ptr %ra.337
  %ext.10501 = call ptr @kx_int_str(i64 %t.10499)
  %r.10502 = call ptr @kx_str_cat(ptr %r.10498, ptr %ext.10501)
  %r.10504 = call ptr @kx_str_cat(ptr %r.10502, ptr @.str.100)
  %r.10505 = call i64 @Emit(i64 %t.10487, ptr %r.10504)
  %t.10506 = load ptr, ptr %r.360
  %r.10508 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10506)
  ret ptr %r.10508
dead.10509:
  br label %if.merge.10396
if.merge.10396:
  %t.10510 = load i64, ptr %g.addr
  %t.10511 = load ptr, ptr %t.340
  %r.10513 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10511)
  %r.10515 = call ptr @kx_str_cat(ptr %r.10513, ptr @.str.413)
  %t.10516 = load i64, ptr %lt.334
  %ext.10518 = call ptr @kx_int_str(i64 %t.10516)
  %r.10519 = call ptr @kx_str_cat(ptr %r.10515, ptr %ext.10518)
  %r.10521 = call ptr @kx_str_cat(ptr %r.10519, ptr @.str.8)
  %t.10522 = load i64, ptr %la.336
  %ext.10524 = call ptr @kx_int_str(i64 %t.10522)
  %r.10525 = call ptr @kx_str_cat(ptr %r.10521, ptr %ext.10524)
  %r.10527 = call ptr @kx_str_cat(ptr %r.10525, ptr @.str.403)
  %t.10528 = load i64, ptr %ra.337
  %ext.10530 = call ptr @kx_int_str(i64 %t.10528)
  %r.10531 = call ptr @kx_str_cat(ptr %r.10527, ptr %ext.10530)
  %r.10532 = call i64 @Emit(i64 %t.10510, ptr %r.10531)
  %t.10533 = load ptr, ptr %t.340
  %r.10535 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10533)
  ret ptr %r.10535
dead.10536:
  br label %if.merge.10385
if.merge.10385:
  %t.10537 = load i64, ptr %e.addr
  %r.10538 = call i64 @kx_struct_get(i64 %t.10537, i32 1)
  %field.10539 = inttoptr i64 %r.10538 to ptr
  %r.10541 = call i1 @kx_str_eq(ptr %field.10539, ptr @.str.133)
  br i1 %r.10541, label %if.then.10542, label %if.merge.10543
if.then.10542:
  %t.10544 = load i64, ptr %lt.334
  %ext.10546 = inttoptr i64 %t.10544 to ptr
  %r.10547 = call i1 @kx_str_eq(ptr %ext.10546, ptr @.str.271)
  %t.10548 = load i64, ptr %rt.335
  %ext.10550 = inttoptr i64 %t.10548 to ptr
  %r.10551 = call i1 @kx_str_eq(ptr %ext.10550, ptr @.str.271)
  %t.10552 = or i1 %r.10547, %r.10551
  br i1 %t.10552, label %if.then.10553, label %if.merge.10554
if.then.10553:
  %t.10555 = load i64, ptr %lt.334
  %ext.10557 = inttoptr i64 %t.10555 to ptr
  %r.10558 = call i1 @kx_str_eq(ptr %ext.10557, ptr @.str.271)
  br i1 %r.10558, label %if.then.10559, label %if.merge.10560
if.then.10559:
  %t.10561 = load i64, ptr %g.addr
  %r.10562 = call i64 @kx_struct_get(i64 %t.10561, i32 4)
  %t.10563 = load i64, ptr %g.addr
  %r.10564 = call i64 @kx_struct_get(i64 %t.10563, i32 4)
  %ext.10566 = sext i32 0 to i64
  %r.10565 = call i64 @kx_list_get(i64 %r.10564, i64 %ext.10566)
  %ext.10567 = sext i32 1 to i64
  %t.10568 = add i64 %r.10565, %ext.10567
  %ext.10569 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10562, i64 %ext.10569, i64 %t.10568)
  %t.10570 = load i64, ptr %g.addr
  %r.10571 = call i64 @kx_struct_get(i64 %t.10570, i32 4)
  %ext.10573 = sext i32 0 to i64
  %r.10572 = call i64 @kx_list_get(i64 %r.10571, i64 %ext.10573)
  %r.10574 = call ptr @kx_int_str(i64 %r.10572)
  %r.10576 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10574)
  %ext.361 = alloca ptr
  store ptr %r.10576, ptr %ext.361
  %t.10577 = load i64, ptr %g.addr
  %t.10578 = load ptr, ptr %ext.361
  %r.10580 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10578)
  %r.10582 = call ptr @kx_str_cat(ptr %r.10580, ptr @.str.277)
  %t.10583 = load i64, ptr %la.336
  %ext.10585 = call ptr @kx_int_str(i64 %t.10583)
  %r.10586 = call ptr @kx_str_cat(ptr %r.10582, ptr %ext.10585)
  %r.10588 = call ptr @kx_str_cat(ptr %r.10586, ptr @.str.278)
  %r.10589 = call i64 @Emit(i64 %t.10577, ptr %r.10588)
  %t.10590 = load ptr, ptr %ext.361
  %ptrtoint.10591 = ptrtoint ptr %t.10590 to i64
  store i64 %ptrtoint.10591, ptr %la.336
  br label %if.merge.10560
if.merge.10560:
  %t.10592 = load i64, ptr %rt.335
  %ext.10594 = inttoptr i64 %t.10592 to ptr
  %r.10595 = call i1 @kx_str_eq(ptr %ext.10594, ptr @.str.271)
  br i1 %r.10595, label %if.then.10596, label %if.merge.10597
if.then.10596:
  %t.10598 = load i64, ptr %g.addr
  %r.10599 = call i64 @kx_struct_get(i64 %t.10598, i32 4)
  %t.10600 = load i64, ptr %g.addr
  %r.10601 = call i64 @kx_struct_get(i64 %t.10600, i32 4)
  %ext.10603 = sext i32 0 to i64
  %r.10602 = call i64 @kx_list_get(i64 %r.10601, i64 %ext.10603)
  %ext.10604 = sext i32 1 to i64
  %t.10605 = add i64 %r.10602, %ext.10604
  %ext.10606 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10599, i64 %ext.10606, i64 %t.10605)
  %t.10607 = load i64, ptr %g.addr
  %r.10608 = call i64 @kx_struct_get(i64 %t.10607, i32 4)
  %ext.10610 = sext i32 0 to i64
  %r.10609 = call i64 @kx_list_get(i64 %r.10608, i64 %ext.10610)
  %r.10611 = call ptr @kx_int_str(i64 %r.10609)
  %r.10613 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10611)
  %ext.362 = alloca ptr
  store ptr %r.10613, ptr %ext.362
  %t.10614 = load i64, ptr %g.addr
  %t.10615 = load ptr, ptr %ext.362
  %r.10617 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10615)
  %r.10619 = call ptr @kx_str_cat(ptr %r.10617, ptr @.str.277)
  %t.10620 = load i64, ptr %ra.337
  %ext.10622 = call ptr @kx_int_str(i64 %t.10620)
  %r.10623 = call ptr @kx_str_cat(ptr %r.10619, ptr %ext.10622)
  %r.10625 = call ptr @kx_str_cat(ptr %r.10623, ptr @.str.278)
  %r.10626 = call i64 @Emit(i64 %t.10614, ptr %r.10625)
  %t.10627 = load ptr, ptr %ext.362
  %ptrtoint.10628 = ptrtoint ptr %t.10627 to i64
  store i64 %ptrtoint.10628, ptr %ra.337
  br label %if.merge.10597
if.merge.10597:
  %t.10629 = load i64, ptr %g.addr
  %r.10630 = call i64 @kx_struct_get(i64 %t.10629, i32 4)
  %t.10631 = load i64, ptr %g.addr
  %r.10632 = call i64 @kx_struct_get(i64 %t.10631, i32 4)
  %ext.10634 = sext i32 0 to i64
  %r.10633 = call i64 @kx_list_get(i64 %r.10632, i64 %ext.10634)
  %ext.10635 = sext i32 1 to i64
  %t.10636 = add i64 %r.10633, %ext.10635
  %ext.10637 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10630, i64 %ext.10637, i64 %t.10636)
  %t.10638 = load i64, ptr %g.addr
  %r.10639 = call i64 @kx_struct_get(i64 %t.10638, i32 4)
  %ext.10641 = sext i32 0 to i64
  %r.10640 = call i64 @kx_list_get(i64 %r.10639, i64 %ext.10641)
  %r.10642 = call ptr @kx_int_str(i64 %r.10640)
  %r.10644 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10642)
  %r.363 = alloca ptr
  store ptr %r.10644, ptr %r.363
  %t.10645 = load i64, ptr %g.addr
  %t.10646 = load ptr, ptr %r.363
  %r.10648 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10646)
  %r.10650 = call ptr @kx_str_cat(ptr %r.10648, ptr @.str.408)
  %t.10651 = load i64, ptr %la.336
  %ext.10653 = call ptr @kx_int_str(i64 %t.10651)
  %r.10654 = call ptr @kx_str_cat(ptr %r.10650, ptr %ext.10653)
  %r.10656 = call ptr @kx_str_cat(ptr %r.10654, ptr @.str.396)
  %t.10657 = load i64, ptr %ra.337
  %ext.10659 = call ptr @kx_int_str(i64 %t.10657)
  %r.10660 = call ptr @kx_str_cat(ptr %r.10656, ptr %ext.10659)
  %r.10662 = call ptr @kx_str_cat(ptr %r.10660, ptr @.str.100)
  %r.10663 = call i64 @Emit(i64 %t.10645, ptr %r.10662)
  %t.10664 = load ptr, ptr %r.363
  %r.10666 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10664)
  ret ptr %r.10666
dead.10667:
  br label %if.merge.10554
if.merge.10554:
  %t.10668 = load i64, ptr %g.addr
  %t.10669 = load ptr, ptr %t.340
  %r.10671 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10669)
  %r.10673 = call ptr @kx_str_cat(ptr %r.10671, ptr @.str.414)
  %t.10674 = load i64, ptr %lt.334
  %ext.10676 = call ptr @kx_int_str(i64 %t.10674)
  %r.10677 = call ptr @kx_str_cat(ptr %r.10673, ptr %ext.10676)
  %r.10679 = call ptr @kx_str_cat(ptr %r.10677, ptr @.str.8)
  %t.10680 = load i64, ptr %la.336
  %ext.10682 = call ptr @kx_int_str(i64 %t.10680)
  %r.10683 = call ptr @kx_str_cat(ptr %r.10679, ptr %ext.10682)
  %r.10685 = call ptr @kx_str_cat(ptr %r.10683, ptr @.str.403)
  %t.10686 = load i64, ptr %ra.337
  %ext.10688 = call ptr @kx_int_str(i64 %t.10686)
  %r.10689 = call ptr @kx_str_cat(ptr %r.10685, ptr %ext.10688)
  %r.10690 = call i64 @Emit(i64 %t.10668, ptr %r.10689)
  %t.10691 = load ptr, ptr %t.340
  %r.10693 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10691)
  ret ptr %r.10693
dead.10694:
  br label %if.merge.10543
if.merge.10543:
  %t.10695 = load i64, ptr %e.addr
  %r.10696 = call i64 @kx_struct_get(i64 %t.10695, i32 1)
  %field.10697 = inttoptr i64 %r.10696 to ptr
  %r.10699 = call i1 @kx_str_eq(ptr %field.10697, ptr @.str.130)
  br i1 %r.10699, label %if.then.10700, label %if.merge.10701
if.then.10700:
  %t.10702 = load i64, ptr %lt.334
  %ext.10704 = inttoptr i64 %t.10702 to ptr
  %r.10705 = call i1 @kx_str_eq(ptr %ext.10704, ptr @.str.271)
  %t.10706 = load i64, ptr %rt.335
  %ext.10708 = inttoptr i64 %t.10706 to ptr
  %r.10709 = call i1 @kx_str_eq(ptr %ext.10708, ptr @.str.271)
  %t.10710 = or i1 %r.10705, %r.10709
  br i1 %t.10710, label %if.then.10711, label %if.merge.10712
if.then.10711:
  %t.10713 = load i64, ptr %lt.334
  %ext.10715 = inttoptr i64 %t.10713 to ptr
  %r.10716 = call i1 @kx_str_eq(ptr %ext.10715, ptr @.str.271)
  br i1 %r.10716, label %if.then.10717, label %if.merge.10718
if.then.10717:
  %t.10719 = load i64, ptr %g.addr
  %r.10720 = call i64 @kx_struct_get(i64 %t.10719, i32 4)
  %t.10721 = load i64, ptr %g.addr
  %r.10722 = call i64 @kx_struct_get(i64 %t.10721, i32 4)
  %ext.10724 = sext i32 0 to i64
  %r.10723 = call i64 @kx_list_get(i64 %r.10722, i64 %ext.10724)
  %ext.10725 = sext i32 1 to i64
  %t.10726 = add i64 %r.10723, %ext.10725
  %ext.10727 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10720, i64 %ext.10727, i64 %t.10726)
  %t.10728 = load i64, ptr %g.addr
  %r.10729 = call i64 @kx_struct_get(i64 %t.10728, i32 4)
  %ext.10731 = sext i32 0 to i64
  %r.10730 = call i64 @kx_list_get(i64 %r.10729, i64 %ext.10731)
  %r.10732 = call ptr @kx_int_str(i64 %r.10730)
  %r.10734 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10732)
  %ext.364 = alloca ptr
  store ptr %r.10734, ptr %ext.364
  %t.10735 = load i64, ptr %g.addr
  %t.10736 = load ptr, ptr %ext.364
  %r.10738 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10736)
  %r.10740 = call ptr @kx_str_cat(ptr %r.10738, ptr @.str.277)
  %t.10741 = load i64, ptr %la.336
  %ext.10743 = call ptr @kx_int_str(i64 %t.10741)
  %r.10744 = call ptr @kx_str_cat(ptr %r.10740, ptr %ext.10743)
  %r.10746 = call ptr @kx_str_cat(ptr %r.10744, ptr @.str.278)
  %r.10747 = call i64 @Emit(i64 %t.10735, ptr %r.10746)
  %t.10748 = load ptr, ptr %ext.364
  %ptrtoint.10749 = ptrtoint ptr %t.10748 to i64
  store i64 %ptrtoint.10749, ptr %la.336
  br label %if.merge.10718
if.merge.10718:
  %t.10750 = load i64, ptr %rt.335
  %ext.10752 = inttoptr i64 %t.10750 to ptr
  %r.10753 = call i1 @kx_str_eq(ptr %ext.10752, ptr @.str.271)
  br i1 %r.10753, label %if.then.10754, label %if.merge.10755
if.then.10754:
  %t.10756 = load i64, ptr %g.addr
  %r.10757 = call i64 @kx_struct_get(i64 %t.10756, i32 4)
  %t.10758 = load i64, ptr %g.addr
  %r.10759 = call i64 @kx_struct_get(i64 %t.10758, i32 4)
  %ext.10761 = sext i32 0 to i64
  %r.10760 = call i64 @kx_list_get(i64 %r.10759, i64 %ext.10761)
  %ext.10762 = sext i32 1 to i64
  %t.10763 = add i64 %r.10760, %ext.10762
  %ext.10764 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10757, i64 %ext.10764, i64 %t.10763)
  %t.10765 = load i64, ptr %g.addr
  %r.10766 = call i64 @kx_struct_get(i64 %t.10765, i32 4)
  %ext.10768 = sext i32 0 to i64
  %r.10767 = call i64 @kx_list_get(i64 %r.10766, i64 %ext.10768)
  %r.10769 = call ptr @kx_int_str(i64 %r.10767)
  %r.10771 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10769)
  %ext.365 = alloca ptr
  store ptr %r.10771, ptr %ext.365
  %t.10772 = load i64, ptr %g.addr
  %t.10773 = load ptr, ptr %ext.365
  %r.10775 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10773)
  %r.10777 = call ptr @kx_str_cat(ptr %r.10775, ptr @.str.277)
  %t.10778 = load i64, ptr %ra.337
  %ext.10780 = call ptr @kx_int_str(i64 %t.10778)
  %r.10781 = call ptr @kx_str_cat(ptr %r.10777, ptr %ext.10780)
  %r.10783 = call ptr @kx_str_cat(ptr %r.10781, ptr @.str.278)
  %r.10784 = call i64 @Emit(i64 %t.10772, ptr %r.10783)
  %t.10785 = load ptr, ptr %ext.365
  %ptrtoint.10786 = ptrtoint ptr %t.10785 to i64
  store i64 %ptrtoint.10786, ptr %ra.337
  br label %if.merge.10755
if.merge.10755:
  %t.10787 = load i64, ptr %g.addr
  %r.10788 = call i64 @kx_struct_get(i64 %t.10787, i32 4)
  %t.10789 = load i64, ptr %g.addr
  %r.10790 = call i64 @kx_struct_get(i64 %t.10789, i32 4)
  %ext.10792 = sext i32 0 to i64
  %r.10791 = call i64 @kx_list_get(i64 %r.10790, i64 %ext.10792)
  %ext.10793 = sext i32 1 to i64
  %t.10794 = add i64 %r.10791, %ext.10793
  %ext.10795 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10788, i64 %ext.10795, i64 %t.10794)
  %t.10796 = load i64, ptr %g.addr
  %r.10797 = call i64 @kx_struct_get(i64 %t.10796, i32 4)
  %ext.10799 = sext i32 0 to i64
  %r.10798 = call i64 @kx_list_get(i64 %r.10797, i64 %ext.10799)
  %r.10800 = call ptr @kx_int_str(i64 %r.10798)
  %r.10802 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10800)
  %r.366 = alloca ptr
  store ptr %r.10802, ptr %r.366
  %t.10803 = load i64, ptr %g.addr
  %t.10804 = load ptr, ptr %r.366
  %r.10806 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10804)
  %r.10808 = call ptr @kx_str_cat(ptr %r.10806, ptr @.str.415)
  %t.10809 = load i64, ptr %la.336
  %ext.10811 = call ptr @kx_int_str(i64 %t.10809)
  %r.10812 = call ptr @kx_str_cat(ptr %r.10808, ptr %ext.10811)
  %r.10814 = call ptr @kx_str_cat(ptr %r.10812, ptr @.str.396)
  %t.10815 = load i64, ptr %ra.337
  %ext.10817 = call ptr @kx_int_str(i64 %t.10815)
  %r.10818 = call ptr @kx_str_cat(ptr %r.10814, ptr %ext.10817)
  %r.10820 = call ptr @kx_str_cat(ptr %r.10818, ptr @.str.100)
  %r.10821 = call i64 @Emit(i64 %t.10803, ptr %r.10820)
  %t.10822 = load ptr, ptr %r.366
  %r.10824 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10822)
  ret ptr %r.10824
dead.10825:
  br label %if.merge.10712
if.merge.10712:
  %t.10826 = load i64, ptr %g.addr
  %t.10827 = load ptr, ptr %t.340
  %r.10829 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10827)
  %r.10831 = call ptr @kx_str_cat(ptr %r.10829, ptr @.str.416)
  %t.10832 = load i64, ptr %lt.334
  %ext.10834 = call ptr @kx_int_str(i64 %t.10832)
  %r.10835 = call ptr @kx_str_cat(ptr %r.10831, ptr %ext.10834)
  %r.10837 = call ptr @kx_str_cat(ptr %r.10835, ptr @.str.8)
  %t.10838 = load i64, ptr %la.336
  %ext.10840 = call ptr @kx_int_str(i64 %t.10838)
  %r.10841 = call ptr @kx_str_cat(ptr %r.10837, ptr %ext.10840)
  %r.10843 = call ptr @kx_str_cat(ptr %r.10841, ptr @.str.403)
  %t.10844 = load i64, ptr %ra.337
  %ext.10846 = call ptr @kx_int_str(i64 %t.10844)
  %r.10847 = call ptr @kx_str_cat(ptr %r.10843, ptr %ext.10846)
  %r.10848 = call i64 @Emit(i64 %t.10826, ptr %r.10847)
  %t.10849 = load ptr, ptr %t.340
  %r.10851 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10849)
  ret ptr %r.10851
dead.10852:
  br label %if.merge.10701
if.merge.10701:
  %t.10853 = load i64, ptr %e.addr
  %r.10854 = call i64 @kx_struct_get(i64 %t.10853, i32 1)
  %field.10855 = inttoptr i64 %r.10854 to ptr
  %r.10857 = call i1 @kx_str_eq(ptr %field.10855, ptr @.str.131)
  br i1 %r.10857, label %if.then.10858, label %if.merge.10859
if.then.10858:
  %t.10860 = load i64, ptr %lt.334
  %ext.10862 = inttoptr i64 %t.10860 to ptr
  %r.10863 = call i1 @kx_str_eq(ptr %ext.10862, ptr @.str.271)
  %t.10864 = load i64, ptr %rt.335
  %ext.10866 = inttoptr i64 %t.10864 to ptr
  %r.10867 = call i1 @kx_str_eq(ptr %ext.10866, ptr @.str.271)
  %t.10868 = or i1 %r.10863, %r.10867
  br i1 %t.10868, label %if.then.10869, label %if.merge.10870
if.then.10869:
  %t.10871 = load i64, ptr %lt.334
  %ext.10873 = inttoptr i64 %t.10871 to ptr
  %r.10874 = call i1 @kx_str_eq(ptr %ext.10873, ptr @.str.271)
  br i1 %r.10874, label %if.then.10875, label %if.merge.10876
if.then.10875:
  %t.10877 = load i64, ptr %g.addr
  %r.10878 = call i64 @kx_struct_get(i64 %t.10877, i32 4)
  %t.10879 = load i64, ptr %g.addr
  %r.10880 = call i64 @kx_struct_get(i64 %t.10879, i32 4)
  %ext.10882 = sext i32 0 to i64
  %r.10881 = call i64 @kx_list_get(i64 %r.10880, i64 %ext.10882)
  %ext.10883 = sext i32 1 to i64
  %t.10884 = add i64 %r.10881, %ext.10883
  %ext.10885 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10878, i64 %ext.10885, i64 %t.10884)
  %t.10886 = load i64, ptr %g.addr
  %r.10887 = call i64 @kx_struct_get(i64 %t.10886, i32 4)
  %ext.10889 = sext i32 0 to i64
  %r.10888 = call i64 @kx_list_get(i64 %r.10887, i64 %ext.10889)
  %r.10890 = call ptr @kx_int_str(i64 %r.10888)
  %r.10892 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10890)
  %ext.367 = alloca ptr
  store ptr %r.10892, ptr %ext.367
  %t.10893 = load i64, ptr %g.addr
  %t.10894 = load ptr, ptr %ext.367
  %r.10896 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10894)
  %r.10898 = call ptr @kx_str_cat(ptr %r.10896, ptr @.str.277)
  %t.10899 = load i64, ptr %la.336
  %ext.10901 = call ptr @kx_int_str(i64 %t.10899)
  %r.10902 = call ptr @kx_str_cat(ptr %r.10898, ptr %ext.10901)
  %r.10904 = call ptr @kx_str_cat(ptr %r.10902, ptr @.str.278)
  %r.10905 = call i64 @Emit(i64 %t.10893, ptr %r.10904)
  %t.10906 = load ptr, ptr %ext.367
  %ptrtoint.10907 = ptrtoint ptr %t.10906 to i64
  store i64 %ptrtoint.10907, ptr %la.336
  br label %if.merge.10876
if.merge.10876:
  %t.10908 = load i64, ptr %rt.335
  %ext.10910 = inttoptr i64 %t.10908 to ptr
  %r.10911 = call i1 @kx_str_eq(ptr %ext.10910, ptr @.str.271)
  br i1 %r.10911, label %if.then.10912, label %if.merge.10913
if.then.10912:
  %t.10914 = load i64, ptr %g.addr
  %r.10915 = call i64 @kx_struct_get(i64 %t.10914, i32 4)
  %t.10916 = load i64, ptr %g.addr
  %r.10917 = call i64 @kx_struct_get(i64 %t.10916, i32 4)
  %ext.10919 = sext i32 0 to i64
  %r.10918 = call i64 @kx_list_get(i64 %r.10917, i64 %ext.10919)
  %ext.10920 = sext i32 1 to i64
  %t.10921 = add i64 %r.10918, %ext.10920
  %ext.10922 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10915, i64 %ext.10922, i64 %t.10921)
  %t.10923 = load i64, ptr %g.addr
  %r.10924 = call i64 @kx_struct_get(i64 %t.10923, i32 4)
  %ext.10926 = sext i32 0 to i64
  %r.10925 = call i64 @kx_list_get(i64 %r.10924, i64 %ext.10926)
  %r.10927 = call ptr @kx_int_str(i64 %r.10925)
  %r.10929 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.10927)
  %ext.368 = alloca ptr
  store ptr %r.10929, ptr %ext.368
  %t.10930 = load i64, ptr %g.addr
  %t.10931 = load ptr, ptr %ext.368
  %r.10933 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10931)
  %r.10935 = call ptr @kx_str_cat(ptr %r.10933, ptr @.str.277)
  %t.10936 = load i64, ptr %ra.337
  %ext.10938 = call ptr @kx_int_str(i64 %t.10936)
  %r.10939 = call ptr @kx_str_cat(ptr %r.10935, ptr %ext.10938)
  %r.10941 = call ptr @kx_str_cat(ptr %r.10939, ptr @.str.278)
  %r.10942 = call i64 @Emit(i64 %t.10930, ptr %r.10941)
  %t.10943 = load ptr, ptr %ext.368
  %ptrtoint.10944 = ptrtoint ptr %t.10943 to i64
  store i64 %ptrtoint.10944, ptr %ra.337
  br label %if.merge.10913
if.merge.10913:
  %t.10945 = load i64, ptr %g.addr
  %r.10946 = call i64 @kx_struct_get(i64 %t.10945, i32 4)
  %t.10947 = load i64, ptr %g.addr
  %r.10948 = call i64 @kx_struct_get(i64 %t.10947, i32 4)
  %ext.10950 = sext i32 0 to i64
  %r.10949 = call i64 @kx_list_get(i64 %r.10948, i64 %ext.10950)
  %ext.10951 = sext i32 1 to i64
  %t.10952 = add i64 %r.10949, %ext.10951
  %ext.10953 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.10946, i64 %ext.10953, i64 %t.10952)
  %t.10954 = load i64, ptr %g.addr
  %r.10955 = call i64 @kx_struct_get(i64 %t.10954, i32 4)
  %ext.10957 = sext i32 0 to i64
  %r.10956 = call i64 @kx_list_get(i64 %r.10955, i64 %ext.10957)
  %r.10958 = call ptr @kx_int_str(i64 %r.10956)
  %r.10960 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.10958)
  %r.369 = alloca ptr
  store ptr %r.10960, ptr %r.369
  %t.10961 = load i64, ptr %g.addr
  %t.10962 = load ptr, ptr %r.369
  %r.10964 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10962)
  %r.10966 = call ptr @kx_str_cat(ptr %r.10964, ptr @.str.417)
  %t.10967 = load i64, ptr %la.336
  %ext.10969 = call ptr @kx_int_str(i64 %t.10967)
  %r.10970 = call ptr @kx_str_cat(ptr %r.10966, ptr %ext.10969)
  %r.10972 = call ptr @kx_str_cat(ptr %r.10970, ptr @.str.396)
  %t.10973 = load i64, ptr %ra.337
  %ext.10975 = call ptr @kx_int_str(i64 %t.10973)
  %r.10976 = call ptr @kx_str_cat(ptr %r.10972, ptr %ext.10975)
  %r.10978 = call ptr @kx_str_cat(ptr %r.10976, ptr @.str.100)
  %r.10979 = call i64 @Emit(i64 %t.10961, ptr %r.10978)
  %t.10980 = load ptr, ptr %r.369
  %r.10982 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.10980)
  ret ptr %r.10982
dead.10983:
  br label %if.merge.10870
if.merge.10870:
  %t.10984 = load i64, ptr %g.addr
  %t.10985 = load ptr, ptr %t.340
  %r.10987 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.10985)
  %r.10989 = call ptr @kx_str_cat(ptr %r.10987, ptr @.str.418)
  %t.10990 = load i64, ptr %lt.334
  %ext.10992 = call ptr @kx_int_str(i64 %t.10990)
  %r.10993 = call ptr @kx_str_cat(ptr %r.10989, ptr %ext.10992)
  %r.10995 = call ptr @kx_str_cat(ptr %r.10993, ptr @.str.8)
  %t.10996 = load i64, ptr %la.336
  %ext.10998 = call ptr @kx_int_str(i64 %t.10996)
  %r.10999 = call ptr @kx_str_cat(ptr %r.10995, ptr %ext.10998)
  %r.11001 = call ptr @kx_str_cat(ptr %r.10999, ptr @.str.403)
  %t.11002 = load i64, ptr %ra.337
  %ext.11004 = call ptr @kx_int_str(i64 %t.11002)
  %r.11005 = call ptr @kx_str_cat(ptr %r.11001, ptr %ext.11004)
  %r.11006 = call i64 @Emit(i64 %t.10984, ptr %r.11005)
  %t.11007 = load ptr, ptr %t.340
  %r.11009 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.11007)
  ret ptr %r.11009
dead.11010:
  br label %if.merge.10859
if.merge.10859:
  %t.11011 = load i64, ptr %e.addr
  %r.11012 = call i64 @kx_struct_get(i64 %t.11011, i32 1)
  %field.11013 = inttoptr i64 %r.11012 to ptr
  %r.11015 = call i1 @kx_str_eq(ptr %field.11013, ptr @.str.134)
  br i1 %r.11015, label %if.then.11016, label %if.merge.11017
if.then.11016:
  %t.11018 = load i64, ptr %la.336
  %lv2.370 = alloca i64
  store i64 %t.11018, ptr %lv2.370
  %t.11019 = load i64, ptr %ra.337
  %rv2.371 = alloca i64
  store i64 %t.11019, ptr %rv2.371
  %t.11020 = load i64, ptr %lt.334
  %ext.11022 = inttoptr i64 %t.11020 to ptr
  %r.11023 = call i1 @kx_str_eq(ptr %ext.11022, ptr @.str.269)
  br i1 %r.11023, label %if.then.11024, label %if.merge.11025
if.then.11024:
  %t.11026 = load i64, ptr %g.addr
  %r.11027 = call i64 @kx_struct_get(i64 %t.11026, i32 4)
  %t.11028 = load i64, ptr %g.addr
  %r.11029 = call i64 @kx_struct_get(i64 %t.11028, i32 4)
  %ext.11031 = sext i32 0 to i64
  %r.11030 = call i64 @kx_list_get(i64 %r.11029, i64 %ext.11031)
  %ext.11032 = sext i32 1 to i64
  %t.11033 = add i64 %r.11030, %ext.11032
  %ext.11034 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11027, i64 %ext.11034, i64 %t.11033)
  %t.11035 = load i64, ptr %g.addr
  %r.11036 = call i64 @kx_struct_get(i64 %t.11035, i32 4)
  %ext.11038 = sext i32 0 to i64
  %r.11037 = call i64 @kx_list_get(i64 %r.11036, i64 %ext.11038)
  %r.11039 = call ptr @kx_int_str(i64 %r.11037)
  %r.11041 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.11039)
  %ext.372 = alloca ptr
  store ptr %r.11041, ptr %ext.372
  %t.11042 = load i64, ptr %g.addr
  %t.11043 = load ptr, ptr %ext.372
  %r.11045 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11043)
  %r.11047 = call ptr @kx_str_cat(ptr %r.11045, ptr @.str.281)
  %t.11048 = load i64, ptr %la.336
  %ext.11050 = call ptr @kx_int_str(i64 %t.11048)
  %r.11051 = call ptr @kx_str_cat(ptr %r.11047, ptr %ext.11050)
  %r.11053 = call ptr @kx_str_cat(ptr %r.11051, ptr @.str.282)
  %r.11054 = call i64 @Emit(i64 %t.11042, ptr %r.11053)
  %t.11055 = load ptr, ptr %ext.372
  %ptrtoint.11056 = ptrtoint ptr %t.11055 to i64
  store i64 %ptrtoint.11056, ptr %lv2.370
  br label %if.merge.11025
if.merge.11025:
  %t.11057 = load i64, ptr %rt.335
  %ext.11059 = inttoptr i64 %t.11057 to ptr
  %r.11060 = call i1 @kx_str_eq(ptr %ext.11059, ptr @.str.269)
  br i1 %r.11060, label %if.then.11061, label %if.merge.11062
if.then.11061:
  %t.11063 = load i64, ptr %g.addr
  %r.11064 = call i64 @kx_struct_get(i64 %t.11063, i32 4)
  %t.11065 = load i64, ptr %g.addr
  %r.11066 = call i64 @kx_struct_get(i64 %t.11065, i32 4)
  %ext.11068 = sext i32 0 to i64
  %r.11067 = call i64 @kx_list_get(i64 %r.11066, i64 %ext.11068)
  %ext.11069 = sext i32 1 to i64
  %t.11070 = add i64 %r.11067, %ext.11069
  %ext.11071 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11064, i64 %ext.11071, i64 %t.11070)
  %t.11072 = load i64, ptr %g.addr
  %r.11073 = call i64 @kx_struct_get(i64 %t.11072, i32 4)
  %ext.11075 = sext i32 0 to i64
  %r.11074 = call i64 @kx_list_get(i64 %r.11073, i64 %ext.11075)
  %r.11076 = call ptr @kx_int_str(i64 %r.11074)
  %r.11078 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.11076)
  %ext.373 = alloca ptr
  store ptr %r.11078, ptr %ext.373
  %t.11079 = load i64, ptr %g.addr
  %t.11080 = load ptr, ptr %ext.373
  %r.11082 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11080)
  %r.11084 = call ptr @kx_str_cat(ptr %r.11082, ptr @.str.281)
  %t.11085 = load i64, ptr %ra.337
  %ext.11087 = call ptr @kx_int_str(i64 %t.11085)
  %r.11088 = call ptr @kx_str_cat(ptr %r.11084, ptr %ext.11087)
  %r.11090 = call ptr @kx_str_cat(ptr %r.11088, ptr @.str.282)
  %r.11091 = call i64 @Emit(i64 %t.11079, ptr %r.11090)
  %t.11092 = load ptr, ptr %ext.373
  %ptrtoint.11093 = ptrtoint ptr %t.11092 to i64
  store i64 %ptrtoint.11093, ptr %rv2.371
  br label %if.merge.11062
if.merge.11062:
  %t.11094 = load i64, ptr %g.addr
  %t.11095 = load ptr, ptr %t.340
  %r.11097 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11095)
  %r.11099 = call ptr @kx_str_cat(ptr %r.11097, ptr @.str.419)
  %t.11100 = load i64, ptr %lv2.370
  %ext.11102 = call ptr @kx_int_str(i64 %t.11100)
  %r.11103 = call ptr @kx_str_cat(ptr %r.11099, ptr %ext.11102)
  %r.11105 = call ptr @kx_str_cat(ptr %r.11103, ptr @.str.403)
  %t.11106 = load i64, ptr %rv2.371
  %ext.11108 = call ptr @kx_int_str(i64 %t.11106)
  %r.11109 = call ptr @kx_str_cat(ptr %r.11105, ptr %ext.11108)
  %r.11110 = call i64 @Emit(i64 %t.11094, ptr %r.11109)
  %t.11111 = load ptr, ptr %t.340
  %r.11113 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.11111)
  ret ptr %r.11113
dead.11114:
  br label %if.merge.11017
if.merge.11017:
  %t.11115 = load i64, ptr %e.addr
  %r.11116 = call i64 @kx_struct_get(i64 %t.11115, i32 1)
  %field.11117 = inttoptr i64 %r.11116 to ptr
  %r.11119 = call i1 @kx_str_eq(ptr %field.11117, ptr @.str.135)
  br i1 %r.11119, label %if.then.11120, label %if.merge.11121
if.then.11120:
  %t.11122 = load i64, ptr %la.336
  %lv2.374 = alloca i64
  store i64 %t.11122, ptr %lv2.374
  %t.11123 = load i64, ptr %ra.337
  %rv2.375 = alloca i64
  store i64 %t.11123, ptr %rv2.375
  %t.11124 = load i64, ptr %lt.334
  %ext.11126 = inttoptr i64 %t.11124 to ptr
  %r.11127 = call i1 @kx_str_eq(ptr %ext.11126, ptr @.str.269)
  br i1 %r.11127, label %if.then.11128, label %if.merge.11129
if.then.11128:
  %t.11130 = load i64, ptr %g.addr
  %r.11131 = call i64 @kx_struct_get(i64 %t.11130, i32 4)
  %t.11132 = load i64, ptr %g.addr
  %r.11133 = call i64 @kx_struct_get(i64 %t.11132, i32 4)
  %ext.11135 = sext i32 0 to i64
  %r.11134 = call i64 @kx_list_get(i64 %r.11133, i64 %ext.11135)
  %ext.11136 = sext i32 1 to i64
  %t.11137 = add i64 %r.11134, %ext.11136
  %ext.11138 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11131, i64 %ext.11138, i64 %t.11137)
  %t.11139 = load i64, ptr %g.addr
  %r.11140 = call i64 @kx_struct_get(i64 %t.11139, i32 4)
  %ext.11142 = sext i32 0 to i64
  %r.11141 = call i64 @kx_list_get(i64 %r.11140, i64 %ext.11142)
  %r.11143 = call ptr @kx_int_str(i64 %r.11141)
  %r.11145 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.11143)
  %ext.376 = alloca ptr
  store ptr %r.11145, ptr %ext.376
  %t.11146 = load i64, ptr %g.addr
  %t.11147 = load ptr, ptr %ext.376
  %r.11149 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11147)
  %r.11151 = call ptr @kx_str_cat(ptr %r.11149, ptr @.str.281)
  %t.11152 = load i64, ptr %la.336
  %ext.11154 = call ptr @kx_int_str(i64 %t.11152)
  %r.11155 = call ptr @kx_str_cat(ptr %r.11151, ptr %ext.11154)
  %r.11157 = call ptr @kx_str_cat(ptr %r.11155, ptr @.str.282)
  %r.11158 = call i64 @Emit(i64 %t.11146, ptr %r.11157)
  %t.11159 = load ptr, ptr %ext.376
  %ptrtoint.11160 = ptrtoint ptr %t.11159 to i64
  store i64 %ptrtoint.11160, ptr %lv2.374
  br label %if.merge.11129
if.merge.11129:
  %t.11161 = load i64, ptr %rt.335
  %ext.11163 = inttoptr i64 %t.11161 to ptr
  %r.11164 = call i1 @kx_str_eq(ptr %ext.11163, ptr @.str.269)
  br i1 %r.11164, label %if.then.11165, label %if.merge.11166
if.then.11165:
  %t.11167 = load i64, ptr %g.addr
  %r.11168 = call i64 @kx_struct_get(i64 %t.11167, i32 4)
  %t.11169 = load i64, ptr %g.addr
  %r.11170 = call i64 @kx_struct_get(i64 %t.11169, i32 4)
  %ext.11172 = sext i32 0 to i64
  %r.11171 = call i64 @kx_list_get(i64 %r.11170, i64 %ext.11172)
  %ext.11173 = sext i32 1 to i64
  %t.11174 = add i64 %r.11171, %ext.11173
  %ext.11175 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11168, i64 %ext.11175, i64 %t.11174)
  %t.11176 = load i64, ptr %g.addr
  %r.11177 = call i64 @kx_struct_get(i64 %t.11176, i32 4)
  %ext.11179 = sext i32 0 to i64
  %r.11178 = call i64 @kx_list_get(i64 %r.11177, i64 %ext.11179)
  %r.11180 = call ptr @kx_int_str(i64 %r.11178)
  %r.11182 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.11180)
  %ext.377 = alloca ptr
  store ptr %r.11182, ptr %ext.377
  %t.11183 = load i64, ptr %g.addr
  %t.11184 = load ptr, ptr %ext.377
  %r.11186 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11184)
  %r.11188 = call ptr @kx_str_cat(ptr %r.11186, ptr @.str.281)
  %t.11189 = load i64, ptr %ra.337
  %ext.11191 = call ptr @kx_int_str(i64 %t.11189)
  %r.11192 = call ptr @kx_str_cat(ptr %r.11188, ptr %ext.11191)
  %r.11194 = call ptr @kx_str_cat(ptr %r.11192, ptr @.str.282)
  %r.11195 = call i64 @Emit(i64 %t.11183, ptr %r.11194)
  %t.11196 = load ptr, ptr %ext.377
  %ptrtoint.11197 = ptrtoint ptr %t.11196 to i64
  store i64 %ptrtoint.11197, ptr %rv2.375
  br label %if.merge.11166
if.merge.11166:
  %t.11198 = load i64, ptr %g.addr
  %t.11199 = load ptr, ptr %t.340
  %r.11201 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11199)
  %r.11203 = call ptr @kx_str_cat(ptr %r.11201, ptr @.str.420)
  %t.11204 = load i64, ptr %lv2.374
  %ext.11206 = call ptr @kx_int_str(i64 %t.11204)
  %r.11207 = call ptr @kx_str_cat(ptr %r.11203, ptr %ext.11206)
  %r.11209 = call ptr @kx_str_cat(ptr %r.11207, ptr @.str.403)
  %t.11210 = load i64, ptr %rv2.375
  %ext.11212 = call ptr @kx_int_str(i64 %t.11210)
  %r.11213 = call ptr @kx_str_cat(ptr %r.11209, ptr %ext.11212)
  %r.11214 = call i64 @Emit(i64 %t.11198, ptr %r.11213)
  %t.11215 = load ptr, ptr %t.340
  %r.11217 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.11215)
  ret ptr %r.11217
dead.11218:
  br label %if.merge.11121
if.merge.11121:
  %t.11219 = load i64, ptr %lt.334
  %ext.11221 = call ptr @kx_int_str(i64 %t.11219)
  %r.11222 = call ptr @kx_str_cat(ptr %ext.11221, ptr @.str.8)
  %t.11223 = load ptr, ptr %t.340
  %r.11225 = call ptr @kx_str_cat(ptr %r.11222, ptr %t.11223)
  ret ptr %r.11225
dead.11226:
  br label %if.merge.9304
if.merge.9304:
  %t.11227 = load i64, ptr %e.addr
  %r.11228 = call i64 @kx_struct_get(i64 %t.11227, i32 0)
  %field.11229 = inttoptr i64 %r.11228 to ptr
  %r.11231 = call i1 @kx_str_eq(ptr %field.11229, ptr @.str.114)
  br i1 %r.11231, label %if.then.11232, label %if.merge.11233
if.then.11232:
  %t.11234 = load i64, ptr %g.addr
  %t.11235 = load i64, ptr %arena.addr
  %t.11236 = load i64, ptr %e.addr
  %cast.11237 = sext i32 0 to i64
  %r.11238 = call i64 @Child(i64 %t.11235, i64 %t.11236, i64 %cast.11237)
  %t.11239 = load i64, ptr %arena.addr
  %r.11240 = call ptr @GenExpr(i64 %t.11234, i64 %r.11238, i64 %t.11239)
  %v.378 = alloca ptr
  store ptr %r.11240, ptr %v.378
  %t.11241 = load ptr, ptr %v.378
  %r.11242 = call i64 @XType(ptr %t.11241)
  %vt.379 = alloca i64
  store i64 %r.11242, ptr %vt.379
  %t.11243 = load ptr, ptr %v.378
  %r.11244 = call i64 @XVal(ptr %t.11243)
  %va.380 = alloca i64
  store i64 %r.11244, ptr %va.380
  %t.11245 = load i64, ptr %g.addr
  %r.11246 = call i64 @kx_struct_get(i64 %t.11245, i32 4)
  %t.11247 = load i64, ptr %g.addr
  %r.11248 = call i64 @kx_struct_get(i64 %t.11247, i32 4)
  %ext.11250 = sext i32 0 to i64
  %r.11249 = call i64 @kx_list_get(i64 %r.11248, i64 %ext.11250)
  %ext.11251 = sext i32 1 to i64
  %t.11252 = add i64 %r.11249, %ext.11251
  %ext.11253 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11246, i64 %ext.11253, i64 %t.11252)
  %t.11254 = load i64, ptr %g.addr
  %r.11255 = call i64 @kx_struct_get(i64 %t.11254, i32 4)
  %ext.11257 = sext i32 0 to i64
  %r.11256 = call i64 @kx_list_get(i64 %r.11255, i64 %ext.11257)
  %r.11258 = call ptr @kx_int_str(i64 %r.11256)
  %r.11260 = call ptr @kx_str_cat(ptr @.str.400, ptr %r.11258)
  %t.381 = alloca ptr
  store ptr %r.11260, ptr %t.381
  %t.11261 = load i64, ptr %e.addr
  %r.11262 = call i64 @kx_struct_get(i64 %t.11261, i32 1)
  %field.11263 = inttoptr i64 %r.11262 to ptr
  %r.11265 = call i1 @kx_str_eq(ptr %field.11263, ptr @.str.120)
  br i1 %r.11265, label %if.then.11266, label %if.merge.11267
if.then.11266:
  %t.11268 = load i64, ptr %g.addr
  %t.11269 = load ptr, ptr %t.381
  %r.11271 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11269)
  %r.11273 = call ptr @kx_str_cat(ptr %r.11271, ptr @.str.404)
  %t.11274 = load i64, ptr %vt.379
  %ext.11276 = call ptr @kx_int_str(i64 %t.11274)
  %r.11277 = call ptr @kx_str_cat(ptr %r.11273, ptr %ext.11276)
  %r.11279 = call ptr @kx_str_cat(ptr %r.11277, ptr @.str.421)
  %t.11280 = load i64, ptr %va.380
  %ext.11282 = call ptr @kx_int_str(i64 %t.11280)
  %r.11283 = call ptr @kx_str_cat(ptr %r.11279, ptr %ext.11282)
  %r.11284 = call i64 @Emit(i64 %t.11268, ptr %r.11283)
  %t.11285 = load i64, ptr %vt.379
  %ext.11287 = call ptr @kx_int_str(i64 %t.11285)
  %r.11288 = call ptr @kx_str_cat(ptr %ext.11287, ptr @.str.8)
  %t.11289 = load ptr, ptr %t.381
  %r.11291 = call ptr @kx_str_cat(ptr %r.11288, ptr %t.11289)
  ret ptr %r.11291
dead.11292:
  br label %if.merge.11267
if.merge.11267:
  %t.11293 = load i64, ptr %e.addr
  %r.11294 = call i64 @kx_struct_get(i64 %t.11293, i32 1)
  %field.11295 = inttoptr i64 %r.11294 to ptr
  %r.11297 = call i1 @kx_str_eq(ptr %field.11295, ptr @.str.119)
  br i1 %r.11297, label %if.then.11298, label %if.merge.11299
if.then.11298:
  %t.11300 = load i64, ptr %va.380
  %nv.382 = alloca i64
  store i64 %t.11300, ptr %nv.382
  %t.11301 = load i64, ptr %vt.379
  %ext.11303 = inttoptr i64 %t.11301 to ptr
  %r.11304 = call i1 @kx_str_eq(ptr %ext.11303, ptr @.str.269)
  br i1 %r.11304, label %if.then.11305, label %if.merge.11306
if.then.11305:
  %t.11307 = load i64, ptr %g.addr
  %r.11308 = call i64 @kx_struct_get(i64 %t.11307, i32 4)
  %t.11309 = load i64, ptr %g.addr
  %r.11310 = call i64 @kx_struct_get(i64 %t.11309, i32 4)
  %ext.11312 = sext i32 0 to i64
  %r.11311 = call i64 @kx_list_get(i64 %r.11310, i64 %ext.11312)
  %ext.11313 = sext i32 1 to i64
  %t.11314 = add i64 %r.11311, %ext.11313
  %ext.11315 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11308, i64 %ext.11315, i64 %t.11314)
  %t.11316 = load i64, ptr %g.addr
  %r.11317 = call i64 @kx_struct_get(i64 %t.11316, i32 4)
  %ext.11319 = sext i32 0 to i64
  %r.11318 = call i64 @kx_list_get(i64 %r.11317, i64 %ext.11319)
  %r.11320 = call ptr @kx_int_str(i64 %r.11318)
  %r.11322 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.11320)
  %ext.383 = alloca ptr
  store ptr %r.11322, ptr %ext.383
  %t.11323 = load i64, ptr %g.addr
  %t.11324 = load ptr, ptr %ext.383
  %r.11326 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11324)
  %r.11328 = call ptr @kx_str_cat(ptr %r.11326, ptr @.str.281)
  %t.11329 = load i64, ptr %va.380
  %ext.11331 = call ptr @kx_int_str(i64 %t.11329)
  %r.11332 = call ptr @kx_str_cat(ptr %r.11328, ptr %ext.11331)
  %r.11334 = call ptr @kx_str_cat(ptr %r.11332, ptr @.str.282)
  %r.11335 = call i64 @Emit(i64 %t.11323, ptr %r.11334)
  %t.11336 = load ptr, ptr %ext.383
  %ptrtoint.11337 = ptrtoint ptr %t.11336 to i64
  store i64 %ptrtoint.11337, ptr %nv.382
  br label %if.merge.11306
if.merge.11306:
  %t.11338 = load i64, ptr %g.addr
  %t.11339 = load ptr, ptr %t.381
  %r.11341 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11339)
  %r.11343 = call ptr @kx_str_cat(ptr %r.11341, ptr @.str.422)
  %t.11344 = load i64, ptr %nv.382
  %ext.11346 = call ptr @kx_int_str(i64 %t.11344)
  %r.11347 = call ptr @kx_str_cat(ptr %r.11343, ptr %ext.11346)
  %r.11349 = call ptr @kx_str_cat(ptr %r.11347, ptr @.str.423)
  %r.11350 = call i64 @Emit(i64 %t.11338, ptr %r.11349)
  %t.11351 = load ptr, ptr %t.381
  %r.11353 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.11351)
  ret ptr %r.11353
dead.11354:
  br label %if.merge.11299
if.merge.11299:
  %t.11355 = load i64, ptr %e.addr
  %r.11356 = call i64 @kx_struct_get(i64 %t.11355, i32 1)
  %field.11357 = inttoptr i64 %r.11356 to ptr
  %r.11359 = call i1 @kx_str_eq(ptr %field.11357, ptr @.str.115)
  br i1 %r.11359, label %if.then.11360, label %if.merge.11361
if.then.11360:
  %t.11362 = load i64, ptr %arena.addr
  %t.11363 = load i64, ptr %e.addr
  %cast.11364 = sext i32 0 to i64
  %r.11365 = call i64 @Child(i64 %t.11362, i64 %t.11363, i64 %cast.11364)
  %child.384 = alloca i64
  store i64 %r.11365, ptr %child.384
  %t.11366 = load i64, ptr %child.384
  %ext.11368 = inttoptr i64 %t.11366 to ptr
  %r.11369 = call i1 @kx_str_eq(ptr %ext.11368, ptr @.str.92)
  %t.11370 = load i64, ptr %g.addr
  %r.11371 = call i64 @kx_struct_get(i64 %t.11370, i32 7)
  %t.11372 = load i64, ptr %child.384
  %r.11373 = call i1 @kx_map_has(i64 %r.11371, i64 %t.11372)
  %t.11374 = and i1 %r.11369, %r.11373
  br i1 %t.11374, label %if.then.11375, label %if.merge.11376
if.then.11375:
  %t.11377 = load i64, ptr %g.addr
  %r.11378 = call i64 @kx_struct_get(i64 %t.11377, i32 6)
  %t.11379 = load i64, ptr %child.384
  %r.11380 = call i64 @kx_list_get(i64 %r.11378, i64 %t.11379)
  %lhsType.385 = alloca i64
  store i64 %r.11380, ptr %lhsType.385
  %t.11381 = load i64, ptr %g.addr
  %r.11382 = call i64 @kx_struct_get(i64 %t.11381, i32 7)
  %t.11383 = load i64, ptr %child.384
  %r.11384 = call i64 @kx_list_get(i64 %r.11382, i64 %t.11383)
  %lhsPtr.386 = alloca i64
  store i64 %r.11384, ptr %lhsPtr.386
  %t.11385 = load i64, ptr %g.addr
  %r.11386 = call i64 @kx_struct_get(i64 %t.11385, i32 4)
  %t.11387 = load i64, ptr %g.addr
  %r.11388 = call i64 @kx_struct_get(i64 %t.11387, i32 4)
  %ext.11390 = sext i32 0 to i64
  %r.11389 = call i64 @kx_list_get(i64 %r.11388, i64 %ext.11390)
  %ext.11391 = sext i32 1 to i64
  %t.11392 = add i64 %r.11389, %ext.11391
  %ext.11393 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11386, i64 %ext.11393, i64 %t.11392)
  %t.11394 = load i64, ptr %g.addr
  %r.11395 = call i64 @kx_struct_get(i64 %t.11394, i32 4)
  %ext.11397 = sext i32 0 to i64
  %r.11396 = call i64 @kx_list_get(i64 %r.11395, i64 %ext.11397)
  %r.11398 = call ptr @kx_int_str(i64 %r.11396)
  %r.11400 = call ptr @kx_str_cat(ptr @.str.424, ptr %r.11398)
  %old.387 = alloca ptr
  store ptr %r.11400, ptr %old.387
  %t.11401 = load i64, ptr %g.addr
  %t.11402 = load ptr, ptr %old.387
  %r.11404 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11402)
  %r.11406 = call ptr @kx_str_cat(ptr %r.11404, ptr @.str.401)
  %t.11407 = load i64, ptr %lhsType.385
  %ext.11409 = call ptr @kx_int_str(i64 %t.11407)
  %r.11410 = call ptr @kx_str_cat(ptr %r.11406, ptr %ext.11409)
  %r.11412 = call ptr @kx_str_cat(ptr %r.11410, ptr @.str.396)
  %t.11413 = load i64, ptr %lhsPtr.386
  %ext.11415 = call ptr @kx_int_str(i64 %t.11413)
  %r.11416 = call ptr @kx_str_cat(ptr %r.11412, ptr %ext.11415)
  %r.11417 = call i64 @Emit(i64 %t.11401, ptr %r.11416)
  %t.11418 = load i64, ptr %lhsType.385
  %ext.11420 = inttoptr i64 %t.11418 to ptr
  %r.11421 = call i1 @kx_str_eq(ptr %ext.11420, ptr @.str.269)
  br i1 %r.11421, label %if.then.11422, label %if.else.11424
if.then.11422:
  %t.11425 = load i64, ptr %g.addr
  %r.11426 = call i64 @kx_struct_get(i64 %t.11425, i32 4)
  %t.11427 = load i64, ptr %g.addr
  %r.11428 = call i64 @kx_struct_get(i64 %t.11427, i32 4)
  %ext.11430 = sext i32 0 to i64
  %r.11429 = call i64 @kx_list_get(i64 %r.11428, i64 %ext.11430)
  %ext.11431 = sext i32 1 to i64
  %t.11432 = add i64 %r.11429, %ext.11431
  %ext.11433 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11426, i64 %ext.11433, i64 %t.11432)
  %t.11434 = load i64, ptr %g.addr
  %r.11435 = call i64 @kx_struct_get(i64 %t.11434, i32 4)
  %ext.11437 = sext i32 0 to i64
  %r.11436 = call i64 @kx_list_get(i64 %r.11435, i64 %ext.11437)
  %r.11438 = call ptr @kx_int_str(i64 %r.11436)
  %r.11440 = call ptr @kx_str_cat(ptr @.str.425, ptr %r.11438)
  %inc.388 = alloca ptr
  store ptr %r.11440, ptr %inc.388
  %t.11441 = load i64, ptr %g.addr
  %t.11442 = load ptr, ptr %inc.388
  %r.11444 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11442)
  %r.11446 = call ptr @kx_str_cat(ptr %r.11444, ptr @.str.426)
  %t.11447 = load ptr, ptr %old.387
  %r.11449 = call ptr @kx_str_cat(ptr %r.11446, ptr %t.11447)
  %r.11451 = call ptr @kx_str_cat(ptr %r.11449, ptr @.str.427)
  %r.11452 = call i64 @Emit(i64 %t.11441, ptr %r.11451)
  %t.11453 = load i64, ptr %g.addr
  %t.11454 = load ptr, ptr %inc.388
  %r.11456 = call ptr @kx_str_cat(ptr @.str.428, ptr %t.11454)
  %r.11458 = call ptr @kx_str_cat(ptr %r.11456, ptr @.str.396)
  %t.11459 = load i64, ptr %lhsPtr.386
  %ext.11461 = call ptr @kx_int_str(i64 %t.11459)
  %r.11462 = call ptr @kx_str_cat(ptr %r.11458, ptr %ext.11461)
  %r.11463 = call i64 @Emit(i64 %t.11453, ptr %r.11462)
  %t.11464 = load ptr, ptr %old.387
  %r.11466 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.11464)
  ret ptr %r.11466
dead.11467:
  br label %if.merge.11423
if.else.11424:
  %t.11468 = load i64, ptr %g.addr
  %r.11469 = call i64 @kx_struct_get(i64 %t.11468, i32 4)
  %t.11470 = load i64, ptr %g.addr
  %r.11471 = call i64 @kx_struct_get(i64 %t.11470, i32 4)
  %ext.11473 = sext i32 0 to i64
  %r.11472 = call i64 @kx_list_get(i64 %r.11471, i64 %ext.11473)
  %ext.11474 = sext i32 1 to i64
  %t.11475 = add i64 %r.11472, %ext.11474
  %ext.11476 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11469, i64 %ext.11476, i64 %t.11475)
  %t.11477 = load i64, ptr %g.addr
  %r.11478 = call i64 @kx_struct_get(i64 %t.11477, i32 4)
  %ext.11480 = sext i32 0 to i64
  %r.11479 = call i64 @kx_list_get(i64 %r.11478, i64 %ext.11480)
  %r.11481 = call ptr @kx_int_str(i64 %r.11479)
  %r.11483 = call ptr @kx_str_cat(ptr @.str.425, ptr %r.11481)
  %inc.389 = alloca ptr
  store ptr %r.11483, ptr %inc.389
  %t.11484 = load i64, ptr %g.addr
  %t.11485 = load ptr, ptr %inc.389
  %r.11487 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11485)
  %r.11489 = call ptr @kx_str_cat(ptr %r.11487, ptr @.str.429)
  %t.11490 = load ptr, ptr %old.387
  %r.11492 = call ptr @kx_str_cat(ptr %r.11489, ptr %t.11490)
  %r.11494 = call ptr @kx_str_cat(ptr %r.11492, ptr @.str.427)
  %r.11495 = call i64 @Emit(i64 %t.11484, ptr %r.11494)
  %t.11496 = load i64, ptr %g.addr
  %t.11497 = load ptr, ptr %inc.389
  %r.11499 = call ptr @kx_str_cat(ptr @.str.430, ptr %t.11497)
  %r.11501 = call ptr @kx_str_cat(ptr %r.11499, ptr @.str.396)
  %t.11502 = load i64, ptr %lhsPtr.386
  %ext.11504 = call ptr @kx_int_str(i64 %t.11502)
  %r.11505 = call ptr @kx_str_cat(ptr %r.11501, ptr %ext.11504)
  %r.11506 = call i64 @Emit(i64 %t.11496, ptr %r.11505)
  %t.11507 = load ptr, ptr %old.387
  %r.11509 = call ptr @kx_str_cat(ptr @.str.385, ptr %t.11507)
  ret ptr %r.11509
dead.11510:
  br label %if.merge.11423
if.merge.11423:
  br label %if.merge.11376
if.merge.11376:
  %t.11511 = load ptr, ptr %v.378
  ret ptr %t.11511
dead.11512:
  br label %if.merge.11361
if.merge.11361:
  %t.11513 = load i64, ptr %e.addr
  %r.11514 = call i64 @kx_struct_get(i64 %t.11513, i32 1)
  %field.11515 = inttoptr i64 %r.11514 to ptr
  %r.11517 = call i1 @kx_str_eq(ptr %field.11515, ptr @.str.116)
  br i1 %r.11517, label %if.then.11518, label %if.merge.11519
if.then.11518:
  %t.11520 = load i64, ptr %arena.addr
  %t.11521 = load i64, ptr %e.addr
  %cast.11522 = sext i32 0 to i64
  %r.11523 = call i64 @Child(i64 %t.11520, i64 %t.11521, i64 %cast.11522)
  %child.390 = alloca i64
  store i64 %r.11523, ptr %child.390
  %t.11524 = load i64, ptr %child.390
  %ext.11526 = inttoptr i64 %t.11524 to ptr
  %r.11527 = call i1 @kx_str_eq(ptr %ext.11526, ptr @.str.92)
  %t.11528 = load i64, ptr %g.addr
  %r.11529 = call i64 @kx_struct_get(i64 %t.11528, i32 7)
  %t.11530 = load i64, ptr %child.390
  %r.11531 = call i1 @kx_map_has(i64 %r.11529, i64 %t.11530)
  %t.11532 = and i1 %r.11527, %r.11531
  br i1 %t.11532, label %if.then.11533, label %if.merge.11534
if.then.11533:
  %t.11535 = load i64, ptr %g.addr
  %r.11536 = call i64 @kx_struct_get(i64 %t.11535, i32 6)
  %t.11537 = load i64, ptr %child.390
  %r.11538 = call i64 @kx_list_get(i64 %r.11536, i64 %t.11537)
  %lhsType.391 = alloca i64
  store i64 %r.11538, ptr %lhsType.391
  %t.11539 = load i64, ptr %g.addr
  %r.11540 = call i64 @kx_struct_get(i64 %t.11539, i32 7)
  %t.11541 = load i64, ptr %child.390
  %r.11542 = call i64 @kx_list_get(i64 %r.11540, i64 %t.11541)
  %lhsPtr.392 = alloca i64
  store i64 %r.11542, ptr %lhsPtr.392
  %t.11543 = load i64, ptr %g.addr
  %r.11544 = call i64 @kx_struct_get(i64 %t.11543, i32 4)
  %t.11545 = load i64, ptr %g.addr
  %r.11546 = call i64 @kx_struct_get(i64 %t.11545, i32 4)
  %ext.11548 = sext i32 0 to i64
  %r.11547 = call i64 @kx_list_get(i64 %r.11546, i64 %ext.11548)
  %ext.11549 = sext i32 1 to i64
  %t.11550 = add i64 %r.11547, %ext.11549
  %ext.11551 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11544, i64 %ext.11551, i64 %t.11550)
  %t.11552 = load i64, ptr %g.addr
  %r.11553 = call i64 @kx_struct_get(i64 %t.11552, i32 4)
  %ext.11555 = sext i32 0 to i64
  %r.11554 = call i64 @kx_list_get(i64 %r.11553, i64 %ext.11555)
  %r.11556 = call ptr @kx_int_str(i64 %r.11554)
  %r.11558 = call ptr @kx_str_cat(ptr @.str.424, ptr %r.11556)
  %old.393 = alloca ptr
  store ptr %r.11558, ptr %old.393
  %t.11559 = load i64, ptr %g.addr
  %t.11560 = load ptr, ptr %old.393
  %r.11562 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11560)
  %r.11564 = call ptr @kx_str_cat(ptr %r.11562, ptr @.str.401)
  %t.11565 = load i64, ptr %lhsType.391
  %ext.11567 = call ptr @kx_int_str(i64 %t.11565)
  %r.11568 = call ptr @kx_str_cat(ptr %r.11564, ptr %ext.11567)
  %r.11570 = call ptr @kx_str_cat(ptr %r.11568, ptr @.str.396)
  %t.11571 = load i64, ptr %lhsPtr.392
  %ext.11573 = call ptr @kx_int_str(i64 %t.11571)
  %r.11574 = call ptr @kx_str_cat(ptr %r.11570, ptr %ext.11573)
  %r.11575 = call i64 @Emit(i64 %t.11559, ptr %r.11574)
  %t.11576 = load i64, ptr %lhsType.391
  %ext.11578 = inttoptr i64 %t.11576 to ptr
  %r.11579 = call i1 @kx_str_eq(ptr %ext.11578, ptr @.str.269)
  br i1 %r.11579, label %if.then.11580, label %if.else.11582
if.then.11580:
  %t.11583 = load i64, ptr %g.addr
  %r.11584 = call i64 @kx_struct_get(i64 %t.11583, i32 4)
  %t.11585 = load i64, ptr %g.addr
  %r.11586 = call i64 @kx_struct_get(i64 %t.11585, i32 4)
  %ext.11588 = sext i32 0 to i64
  %r.11587 = call i64 @kx_list_get(i64 %r.11586, i64 %ext.11588)
  %ext.11589 = sext i32 1 to i64
  %t.11590 = add i64 %r.11587, %ext.11589
  %ext.11591 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11584, i64 %ext.11591, i64 %t.11590)
  %t.11592 = load i64, ptr %g.addr
  %r.11593 = call i64 @kx_struct_get(i64 %t.11592, i32 4)
  %ext.11595 = sext i32 0 to i64
  %r.11594 = call i64 @kx_list_get(i64 %r.11593, i64 %ext.11595)
  %r.11596 = call ptr @kx_int_str(i64 %r.11594)
  %r.11598 = call ptr @kx_str_cat(ptr @.str.431, ptr %r.11596)
  %dec.394 = alloca ptr
  store ptr %r.11598, ptr %dec.394
  %t.11599 = load i64, ptr %g.addr
  %t.11600 = load ptr, ptr %dec.394
  %r.11602 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11600)
  %r.11604 = call ptr @kx_str_cat(ptr %r.11602, ptr @.str.432)
  %t.11605 = load ptr, ptr %old.393
  %r.11607 = call ptr @kx_str_cat(ptr %r.11604, ptr %t.11605)
  %r.11609 = call ptr @kx_str_cat(ptr %r.11607, ptr @.str.427)
  %r.11610 = call i64 @Emit(i64 %t.11599, ptr %r.11609)
  %t.11611 = load i64, ptr %g.addr
  %t.11612 = load ptr, ptr %dec.394
  %r.11614 = call ptr @kx_str_cat(ptr @.str.428, ptr %t.11612)
  %r.11616 = call ptr @kx_str_cat(ptr %r.11614, ptr @.str.396)
  %t.11617 = load i64, ptr %lhsPtr.392
  %ext.11619 = call ptr @kx_int_str(i64 %t.11617)
  %r.11620 = call ptr @kx_str_cat(ptr %r.11616, ptr %ext.11619)
  %r.11621 = call i64 @Emit(i64 %t.11611, ptr %r.11620)
  %t.11622 = load ptr, ptr %old.393
  %r.11624 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.11622)
  ret ptr %r.11624
dead.11625:
  br label %if.merge.11581
if.else.11582:
  %t.11626 = load i64, ptr %g.addr
  %r.11627 = call i64 @kx_struct_get(i64 %t.11626, i32 4)
  %t.11628 = load i64, ptr %g.addr
  %r.11629 = call i64 @kx_struct_get(i64 %t.11628, i32 4)
  %ext.11631 = sext i32 0 to i64
  %r.11630 = call i64 @kx_list_get(i64 %r.11629, i64 %ext.11631)
  %ext.11632 = sext i32 1 to i64
  %t.11633 = add i64 %r.11630, %ext.11632
  %ext.11634 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11627, i64 %ext.11634, i64 %t.11633)
  %t.11635 = load i64, ptr %g.addr
  %r.11636 = call i64 @kx_struct_get(i64 %t.11635, i32 4)
  %ext.11638 = sext i32 0 to i64
  %r.11637 = call i64 @kx_list_get(i64 %r.11636, i64 %ext.11638)
  %r.11639 = call ptr @kx_int_str(i64 %r.11637)
  %r.11641 = call ptr @kx_str_cat(ptr @.str.431, ptr %r.11639)
  %dec.395 = alloca ptr
  store ptr %r.11641, ptr %dec.395
  %t.11642 = load i64, ptr %g.addr
  %t.11643 = load ptr, ptr %dec.395
  %r.11645 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11643)
  %r.11647 = call ptr @kx_str_cat(ptr %r.11645, ptr @.str.433)
  %t.11648 = load ptr, ptr %old.393
  %r.11650 = call ptr @kx_str_cat(ptr %r.11647, ptr %t.11648)
  %r.11652 = call ptr @kx_str_cat(ptr %r.11650, ptr @.str.427)
  %r.11653 = call i64 @Emit(i64 %t.11642, ptr %r.11652)
  %t.11654 = load i64, ptr %g.addr
  %t.11655 = load ptr, ptr %dec.395
  %r.11657 = call ptr @kx_str_cat(ptr @.str.430, ptr %t.11655)
  %r.11659 = call ptr @kx_str_cat(ptr %r.11657, ptr @.str.396)
  %t.11660 = load i64, ptr %lhsPtr.392
  %ext.11662 = call ptr @kx_int_str(i64 %t.11660)
  %r.11663 = call ptr @kx_str_cat(ptr %r.11659, ptr %ext.11662)
  %r.11664 = call i64 @Emit(i64 %t.11654, ptr %r.11663)
  %t.11665 = load ptr, ptr %old.393
  %r.11667 = call ptr @kx_str_cat(ptr @.str.385, ptr %t.11665)
  ret ptr %r.11667
dead.11668:
  br label %if.merge.11581
if.merge.11581:
  br label %if.merge.11534
if.merge.11534:
  %t.11669 = load ptr, ptr %v.378
  ret ptr %t.11669
dead.11670:
  br label %if.merge.11519
if.merge.11519:
  %t.11671 = load ptr, ptr %v.378
  ret ptr %t.11671
dead.11672:
  br label %if.merge.11233
if.merge.11233:
  %t.11673 = load i64, ptr %e.addr
  %r.11674 = call i64 @kx_struct_get(i64 %t.11673, i32 0)
  %field.11675 = inttoptr i64 %r.11674 to ptr
  %r.11677 = call i1 @kx_str_eq(ptr %field.11675, ptr @.str.106)
  br i1 %r.11677, label %if.then.11678, label %if.merge.11679
if.then.11678:
  %t.11680 = load i64, ptr %g.addr
  %t.11681 = load i64, ptr %arena.addr
  %t.11682 = load i64, ptr %e.addr
  %cast.11683 = sext i32 0 to i64
  %r.11684 = call i64 @Child(i64 %t.11681, i64 %t.11682, i64 %cast.11683)
  %t.11685 = load i64, ptr %arena.addr
  %r.11686 = call ptr @GenExpr(i64 %t.11680, i64 %r.11684, i64 %t.11685)
  ret ptr %r.11686
dead.11687:
  br label %if.merge.11679
if.merge.11679:
  %t.11688 = load i64, ptr %e.addr
  %r.11689 = call i64 @kx_struct_get(i64 %t.11688, i32 0)
  %field.11690 = inttoptr i64 %r.11689 to ptr
  %r.11692 = call i1 @kx_str_eq(ptr %field.11690, ptr @.str.52)
  br i1 %r.11692, label %if.then.11693, label %if.merge.11694
if.then.11693:
  %t.11695 = load i64, ptr %g.addr
  %t.11696 = load i64, ptr %arena.addr
  %t.11697 = load i64, ptr %e.addr
  %cast.11698 = sext i32 0 to i64
  %r.11699 = call i64 @Child(i64 %t.11696, i64 %t.11697, i64 %cast.11698)
  %t.11700 = load i64, ptr %arena.addr
  %r.11701 = call ptr @GenExpr(i64 %t.11695, i64 %r.11699, i64 %t.11700)
  %base.396 = alloca ptr
  store ptr %r.11701, ptr %base.396
  %t.11702 = load ptr, ptr %base.396
  %r.11703 = call i64 @XType(ptr %t.11702)
  %bt.397 = alloca i64
  store i64 %r.11703, ptr %bt.397
  %t.11704 = load ptr, ptr %base.396
  %r.11705 = call i64 @XVal(ptr %t.11704)
  %bv.398 = alloca i64
  store i64 %r.11705, ptr %bv.398
  %t.11706 = load i64, ptr %e.addr
  %r.11707 = call i64 @kx_struct_get(i64 %t.11706, i32 4)
  %r.11708 = call i64 @kx_list_size(i64 %r.11707)
  %ext.11709 = sext i32 2 to i64
  %t.11710 = icmp sgt i64 %r.11708, %ext.11709
  br i1 %t.11710, label %if.then.11711, label %if.merge.11712
if.then.11711:
  %t.11713 = load i64, ptr %arena.addr
  %t.11714 = load i64, ptr %e.addr
  %cast.11715 = sext i32 2 to i64
  %r.11716 = call i64 @Child(i64 %t.11713, i64 %t.11714, i64 %cast.11715)
  %r.11717 = call i64 @kx_struct_get(i64 %r.11716, i32 1)
  %field.11718 = inttoptr i64 %r.11717 to ptr
  %bind.399 = alloca ptr
  store ptr %field.11718, ptr %bind.399
  %t.11719 = load i64, ptr %g.addr
  %r.11720 = call i64 @kx_struct_get(i64 %t.11719, i32 4)
  %t.11721 = load i64, ptr %g.addr
  %r.11722 = call i64 @kx_struct_get(i64 %t.11721, i32 4)
  %ext.11724 = sext i32 0 to i64
  %r.11723 = call i64 @kx_list_get(i64 %r.11722, i64 %ext.11724)
  %ext.11725 = sext i32 1 to i64
  %t.11726 = add i64 %r.11723, %ext.11725
  %ext.11727 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11720, i64 %ext.11727, i64 %t.11726)
  %t.11728 = load i64, ptr %g.addr
  %r.11729 = call i64 @kx_struct_get(i64 %t.11728, i32 4)
  %ext.11731 = sext i32 0 to i64
  %r.11730 = call i64 @kx_list_get(i64 %r.11729, i64 %ext.11731)
  %r.11732 = call ptr @kx_int_str(i64 %r.11730)
  %r.11734 = call ptr @kx_str_cat(ptr @.str.434, ptr %r.11732)
  %bindPtr.400 = alloca ptr
  store ptr %r.11734, ptr %bindPtr.400
  %t.11735 = load i64, ptr %bt.397
  %ext.11737 = inttoptr i64 %t.11735 to ptr
  %r.11738 = call i1 @kx_str_eq(ptr %ext.11737, ptr @.str.271)
  br i1 %r.11738, label %if.then.11739, label %if.else.11741
if.then.11739:
  %t.11742 = load i64, ptr %g.addr
  %t.11743 = load ptr, ptr %bindPtr.400
  %r.11745 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11743)
  %r.11747 = call ptr @kx_str_cat(ptr %r.11745, ptr @.str.435)
  %r.11748 = call i64 @Emit(i64 %t.11742, ptr %r.11747)
  %t.11749 = load i64, ptr %g.addr
  %t.11750 = load i64, ptr %bv.398
  %ext.11752 = call ptr @kx_int_str(i64 %t.11750)
  %r.11753 = call ptr @kx_str_cat(ptr @.str.436, ptr %ext.11752)
  %r.11755 = call ptr @kx_str_cat(ptr %r.11753, ptr @.str.396)
  %t.11756 = load ptr, ptr %bindPtr.400
  %r.11758 = call ptr @kx_str_cat(ptr %r.11755, ptr %t.11756)
  %r.11759 = call i64 @Emit(i64 %t.11749, ptr %r.11758)
  %t.11760 = load i64, ptr %g.addr
  %r.11761 = call i64 @kx_struct_get(i64 %t.11760, i32 6)
  %t.11762 = load ptr, ptr %bind.399
  %c.11763 = ptrtoint ptr %t.11762 to i64
  %c.11764 = ptrtoint ptr @.str.271 to i64
  call void @kx_map_set(i64 %r.11761, i64 %c.11763, i64 %c.11764)
  %t.11765 = load i64, ptr %g.addr
  %r.11766 = call i64 @kx_struct_get(i64 %t.11765, i32 7)
  %t.11767 = load ptr, ptr %bind.399
  %t.11768 = load ptr, ptr %bindPtr.400
  %c.11769 = ptrtoint ptr %t.11767 to i64
  %c.11770 = ptrtoint ptr %t.11768 to i64
  call void @kx_map_set(i64 %r.11766, i64 %c.11769, i64 %c.11770)
  br label %if.merge.11740
if.else.11741:
  %t.11771 = load i64, ptr %g.addr
  %t.11772 = load ptr, ptr %bindPtr.400
  %r.11774 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11772)
  %r.11776 = call ptr @kx_str_cat(ptr %r.11774, ptr @.str.437)
  %r.11777 = call i64 @Emit(i64 %t.11771, ptr %r.11776)
  %t.11778 = load i64, ptr %g.addr
  %t.11779 = load i64, ptr %bv.398
  %ext.11781 = call ptr @kx_int_str(i64 %t.11779)
  %r.11782 = call ptr @kx_str_cat(ptr @.str.428, ptr %ext.11781)
  %r.11784 = call ptr @kx_str_cat(ptr %r.11782, ptr @.str.396)
  %t.11785 = load ptr, ptr %bindPtr.400
  %r.11787 = call ptr @kx_str_cat(ptr %r.11784, ptr %t.11785)
  %r.11788 = call i64 @Emit(i64 %t.11778, ptr %r.11787)
  %t.11789 = load i64, ptr %g.addr
  %r.11790 = call i64 @kx_struct_get(i64 %t.11789, i32 6)
  %t.11791 = load ptr, ptr %bind.399
  %c.11792 = ptrtoint ptr %t.11791 to i64
  %c.11793 = ptrtoint ptr @.str.269 to i64
  call void @kx_map_set(i64 %r.11790, i64 %c.11792, i64 %c.11793)
  %t.11794 = load i64, ptr %g.addr
  %r.11795 = call i64 @kx_struct_get(i64 %t.11794, i32 7)
  %t.11796 = load ptr, ptr %bind.399
  %t.11797 = load ptr, ptr %bindPtr.400
  %c.11798 = ptrtoint ptr %t.11796 to i64
  %c.11799 = ptrtoint ptr %t.11797 to i64
  call void @kx_map_set(i64 %r.11795, i64 %c.11798, i64 %c.11799)
  br label %if.merge.11740
if.merge.11740:
  br label %if.merge.11712
if.merge.11712:
  %t.11800 = load i64, ptr %g.addr
  %r.11801 = call i64 @kx_struct_get(i64 %t.11800, i32 4)
  %t.11802 = load i64, ptr %g.addr
  %r.11803 = call i64 @kx_struct_get(i64 %t.11802, i32 4)
  %ext.11805 = sext i32 0 to i64
  %r.11804 = call i64 @kx_list_get(i64 %r.11803, i64 %ext.11805)
  %ext.11806 = sext i32 1 to i64
  %t.11807 = add i64 %r.11804, %ext.11806
  %ext.11808 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11801, i64 %ext.11808, i64 %t.11807)
  %t.11809 = load i64, ptr %g.addr
  %r.11810 = call i64 @kx_struct_get(i64 %t.11809, i32 4)
  %ext.11812 = sext i32 0 to i64
  %r.11811 = call i64 @kx_list_get(i64 %r.11810, i64 %ext.11812)
  %r.11813 = call ptr @kx_int_str(i64 %r.11811)
  %r.11815 = call ptr @kx_str_cat(ptr @.str.434, ptr %r.11813)
  %r.401 = alloca ptr
  store ptr %r.11815, ptr %r.401
  %t.11816 = load i64, ptr %bt.397
  %ext.11818 = inttoptr i64 %t.11816 to ptr
  %r.11819 = call i1 @kx_str_eq(ptr %ext.11818, ptr @.str.271)
  br i1 %r.11819, label %if.then.11820, label %if.else.11822
if.then.11820:
  %t.11823 = load i64, ptr %g.addr
  %t.11824 = load ptr, ptr %r.401
  %r.11826 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11824)
  %r.11828 = call ptr @kx_str_cat(ptr %r.11826, ptr @.str.438)
  %t.11829 = load i64, ptr %bv.398
  %ext.11831 = call ptr @kx_int_str(i64 %t.11829)
  %r.11832 = call ptr @kx_str_cat(ptr %r.11828, ptr %ext.11831)
  %r.11834 = call ptr @kx_str_cat(ptr %r.11832, ptr @.str.439)
  %r.11835 = call i64 @Emit(i64 %t.11823, ptr %r.11834)
  br label %if.merge.11821
if.else.11822:
  %t.11836 = load i64, ptr %g.addr
  %t.11837 = load ptr, ptr %r.401
  %r.11839 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11837)
  %r.11841 = call ptr @kx_str_cat(ptr %r.11839, ptr @.str.281)
  %t.11842 = load i64, ptr %bv.398
  %ext.11844 = call ptr @kx_int_str(i64 %t.11842)
  %r.11845 = call ptr @kx_str_cat(ptr %r.11841, ptr %ext.11844)
  %r.11847 = call ptr @kx_str_cat(ptr %r.11845, ptr @.str.282)
  %r.11848 = call i64 @Emit(i64 %t.11836, ptr %r.11847)
  br label %if.merge.11821
if.merge.11821:
  %t.11849 = load ptr, ptr %r.401
  %r.11851 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.11849)
  ret ptr %r.11851
dead.11852:
  br label %if.merge.11694
if.merge.11694:
  %t.11853 = load i64, ptr %e.addr
  %r.11854 = call i64 @kx_struct_get(i64 %t.11853, i32 0)
  %field.11855 = inttoptr i64 %r.11854 to ptr
  %r.11857 = call i1 @kx_str_eq(ptr %field.11855, ptr @.str.111)
  br i1 %r.11857, label %if.then.11858, label %if.merge.11859
if.then.11858:
  %t.11860 = load i64, ptr %g.addr
  %t.11861 = load i64, ptr %arena.addr
  %t.11862 = load i64, ptr %e.addr
  %cast.11863 = sext i32 0 to i64
  %r.11864 = call i64 @Child(i64 %t.11861, i64 %t.11862, i64 %cast.11863)
  %t.11865 = load i64, ptr %arena.addr
  %r.11866 = call ptr @GenExpr(i64 %t.11860, i64 %r.11864, i64 %t.11865)
  %base.402 = alloca ptr
  store ptr %r.11866, ptr %base.402
  %t.11867 = load ptr, ptr %base.402
  %r.11868 = call i64 @XVal(ptr %t.11867)
  %bv.403 = alloca i64
  store i64 %r.11868, ptr %bv.403
  %t.11869 = load ptr, ptr %base.402
  %r.11870 = call i64 @XType(ptr %t.11869)
  %bt.404 = alloca i64
  store i64 %r.11870, ptr %bt.404
  %t.11871 = load i64, ptr %e.addr
  %r.11872 = call i64 @kx_struct_get(i64 %t.11871, i32 1)
  %field.11873 = inttoptr i64 %r.11872 to ptr
  %m.405 = alloca ptr
  store ptr %field.11873, ptr %m.405
  %t.11874 = load ptr, ptr %m.405
  %r.11876 = call i1 @kx_str_eq(ptr %t.11874, ptr @.str.300)
  %t.11877 = load i64, ptr %bt.404
  %ext.11879 = inttoptr i64 %t.11877 to ptr
  %r.11880 = call i1 @kx_str_eq(ptr %ext.11879, ptr @.str.269)
  %t.11881 = and i1 %r.11876, %r.11880
  br i1 %t.11881, label %if.then.11882, label %if.merge.11883
if.then.11882:
  %t.11884 = load i64, ptr %g.addr
  %r.11885 = call i64 @kx_struct_get(i64 %t.11884, i32 4)
  %t.11886 = load i64, ptr %g.addr
  %r.11887 = call i64 @kx_struct_get(i64 %t.11886, i32 4)
  %ext.11889 = sext i32 0 to i64
  %r.11888 = call i64 @kx_list_get(i64 %r.11887, i64 %ext.11889)
  %ext.11890 = sext i32 1 to i64
  %t.11891 = add i64 %r.11888, %ext.11890
  %ext.11892 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11885, i64 %ext.11892, i64 %t.11891)
  %t.11893 = load i64, ptr %g.addr
  %r.11894 = call i64 @kx_struct_get(i64 %t.11893, i32 4)
  %ext.11896 = sext i32 0 to i64
  %r.11895 = call i64 @kx_list_get(i64 %r.11894, i64 %ext.11896)
  %r.11897 = call ptr @kx_int_str(i64 %r.11895)
  %r.11899 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.11897)
  %r.406 = alloca ptr
  store ptr %r.11899, ptr %r.406
  %t.11900 = load i64, ptr %g.addr
  %t.11901 = load ptr, ptr %r.406
  %r.11903 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11901)
  %r.11905 = call ptr @kx_str_cat(ptr %r.11903, ptr @.str.440)
  %t.11906 = load i64, ptr %bv.403
  %ext.11908 = call ptr @kx_int_str(i64 %t.11906)
  %r.11909 = call ptr @kx_str_cat(ptr %r.11905, ptr %ext.11908)
  %r.11911 = call ptr @kx_str_cat(ptr %r.11909, ptr @.str.100)
  %r.11912 = call i64 @Emit(i64 %t.11900, ptr %r.11911)
  %t.11913 = load ptr, ptr %r.406
  %r.11915 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.11913)
  ret ptr %r.11915
dead.11916:
  br label %if.merge.11883
if.merge.11883:
  %t.11917 = load ptr, ptr %m.405
  %r.11919 = call i1 @kx_str_eq(ptr %t.11917, ptr @.str.293)
  %t.11920 = load i64, ptr %bt.404
  %ext.11922 = inttoptr i64 %t.11920 to ptr
  %r.11923 = call i1 @kx_str_eq(ptr %ext.11922, ptr @.str.271)
  %t.11924 = and i1 %r.11919, %r.11923
  br i1 %t.11924, label %if.then.11925, label %if.merge.11926
if.then.11925:
  %t.11927 = load i64, ptr %g.addr
  %r.11928 = call i64 @kx_struct_get(i64 %t.11927, i32 4)
  %t.11929 = load i64, ptr %g.addr
  %r.11930 = call i64 @kx_struct_get(i64 %t.11929, i32 4)
  %ext.11932 = sext i32 0 to i64
  %r.11931 = call i64 @kx_list_get(i64 %r.11930, i64 %ext.11932)
  %ext.11933 = sext i32 1 to i64
  %t.11934 = add i64 %r.11931, %ext.11933
  %ext.11935 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.11928, i64 %ext.11935, i64 %t.11934)
  %t.11936 = load i64, ptr %g.addr
  %r.11937 = call i64 @kx_struct_get(i64 %t.11936, i32 4)
  %ext.11939 = sext i32 0 to i64
  %r.11938 = call i64 @kx_list_get(i64 %r.11937, i64 %ext.11939)
  %r.11940 = call ptr @kx_int_str(i64 %r.11938)
  %r.11942 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.11940)
  %r.407 = alloca ptr
  store ptr %r.11942, ptr %r.407
  %t.11943 = load i64, ptr %g.addr
  %t.11944 = load ptr, ptr %r.407
  %r.11946 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.11944)
  %r.11948 = call ptr @kx_str_cat(ptr %r.11946, ptr @.str.441)
  %t.11949 = load i64, ptr %bv.403
  %ext.11951 = call ptr @kx_int_str(i64 %t.11949)
  %r.11952 = call ptr @kx_str_cat(ptr %r.11948, ptr %ext.11951)
  %r.11954 = call ptr @kx_str_cat(ptr %r.11952, ptr @.str.100)
  %r.11955 = call i64 @Emit(i64 %t.11943, ptr %r.11954)
  %t.11956 = load ptr, ptr %r.407
  %r.11958 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.11956)
  ret ptr %r.11958
dead.11959:
  br label %if.merge.11926
if.merge.11926:
  %structName.408 = alloca ptr
  store ptr @.str.12, ptr %structName.408
  %t.11960 = load i64, ptr %arena.addr
  %t.11961 = load i64, ptr %e.addr
  %cast.11962 = sext i32 0 to i64
  %r.11963 = call i64 @Child(i64 %t.11960, i64 %t.11961, i64 %cast.11962)
  %baseExpr.409 = alloca i64
  store i64 %r.11963, ptr %baseExpr.409
  %t.11964 = load i64, ptr %baseExpr.409
  %ext.11966 = inttoptr i64 %t.11964 to ptr
  %r.11967 = call i1 @kx_str_eq(ptr %ext.11966, ptr @.str.92)
  %t.11968 = load i64, ptr %g.addr
  %r.11969 = call i64 @kx_struct_get(i64 %t.11968, i32 6)
  %t.11970 = load i64, ptr %baseExpr.409
  %r.11971 = call i1 @kx_map_has(i64 %r.11969, i64 %t.11970)
  %t.11972 = and i1 %r.11967, %r.11971
  br i1 %t.11972, label %if.then.11973, label %if.else.11975
if.then.11973:
  %t.11976 = load i64, ptr %g.addr
  %r.11977 = call i64 @kx_struct_get(i64 %t.11976, i32 6)
  %t.11978 = load i64, ptr %baseExpr.409
  %r.11979 = call i64 @kx_list_get(i64 %r.11977, i64 %t.11978)
  %varType.410 = alloca i64
  store i64 %r.11979, ptr %varType.410
  %t.11980 = load i64, ptr %varType.410
  %ext.11981 = inttoptr i64 %t.11980 to ptr
  %r.11982 = call i1 @kx_str_starts_with(ptr %ext.11981, ptr @.str.286)
  br i1 %r.11982, label %if.then.11983, label %if.merge.11984
if.then.11983:
  %t.11985 = load i64, ptr %varType.410
  %ext.11986 = inttoptr i64 %t.11985 to ptr
  %ext.11987 = sext i32 7 to i64
  %r.11988 = call i64 @kx_str_len(ptr %ext.11986)
  %r.11989 = call ptr @kx_str_substr(ptr %ext.11986, i64 %ext.11987, i64 %r.11988)
  store ptr %r.11989, ptr %structName.408
  br label %if.merge.11984
if.merge.11984:
  br label %if.merge.11974
if.else.11975:
  %t.11990 = load i64, ptr %baseExpr.409
  %ext.11992 = inttoptr i64 %t.11990 to ptr
  %r.11993 = call i1 @kx_str_eq(ptr %ext.11992, ptr @.str.103)
  br i1 %r.11993, label %if.then.11994, label %if.merge.11995
if.then.11994:
  %t.11996 = load i64, ptr %arena.addr
  %t.11997 = load i64, ptr %baseExpr.409
  %cast.11998 = sext i32 0 to i64
  %r.11999 = call i64 @Child(i64 %t.11996, i64 %t.11997, i64 %cast.11998)
  %innerCallee.411 = alloca i64
  store i64 %r.11999, ptr %innerCallee.411
  %t.12000 = load i64, ptr %innerCallee.411
  %ext.12002 = inttoptr i64 %t.12000 to ptr
  %r.12003 = call i1 @kx_str_eq(ptr %ext.12002, ptr @.str.92)
  %t.12004 = load i64, ptr %g.addr
  %r.12005 = call i64 @kx_struct_get(i64 %t.12004, i32 12)
  %t.12006 = load i64, ptr %innerCallee.411
  %r.12007 = call i1 @kx_map_has(i64 %r.12005, i64 %t.12006)
  %t.12008 = and i1 %r.12003, %r.12007
  br i1 %t.12008, label %if.then.12009, label %if.merge.12010
if.then.12009:
  %t.12011 = load i64, ptr %g.addr
  %r.12012 = call i64 @kx_struct_get(i64 %t.12011, i32 12)
  %t.12013 = load i64, ptr %innerCallee.411
  %r.12014 = call i64 @kx_list_get(i64 %r.12012, i64 %t.12013)
  %cast.12015 = inttoptr i64 %r.12014 to ptr
  %r.12016 = call i64 @SigRet(ptr %cast.12015)
  %returned.412 = alloca i64
  store i64 %r.12016, ptr %returned.412
  %t.12017 = load i64, ptr %returned.412
  %ext.12018 = inttoptr i64 %t.12017 to ptr
  %r.12019 = call i1 @kx_str_starts_with(ptr %ext.12018, ptr @.str.286)
  br i1 %r.12019, label %if.then.12020, label %if.merge.12021
if.then.12020:
  %t.12022 = load i64, ptr %returned.412
  %ext.12023 = inttoptr i64 %t.12022 to ptr
  %ext.12024 = sext i32 7 to i64
  %r.12025 = call i64 @kx_str_len(ptr %ext.12023)
  %r.12026 = call ptr @kx_str_substr(ptr %ext.12023, i64 %ext.12024, i64 %r.12025)
  store ptr %r.12026, ptr %structName.408
  br label %if.merge.12021
if.merge.12021:
  br label %if.merge.12010
if.merge.12010:
  br label %if.merge.11995
if.merge.11995:
  br label %if.merge.11974
if.merge.11974:
  %t.12027 = load ptr, ptr %structName.408
  %r.12029 = call i1 @kx_str_eq(ptr %t.12027, ptr @.str.12)
  %t.12030 = load i64, ptr %g.addr
  %r.12031 = call i64 @kx_struct_get(i64 %t.12030, i32 8)
  %t.12032 = load ptr, ptr %structName.408
  %c.12033 = ptrtoint ptr %t.12032 to i64
  %r.12034 = call i1 @kx_map_has(i64 %r.12031, i64 %c.12033)
  %t.12035 = and i1 %r.12029, %r.12034
  br i1 %t.12035, label %if.then.12036, label %if.merge.12037
if.then.12036:
  %t.12038 = load i64, ptr %g.addr
  %r.12039 = call i64 @kx_struct_get(i64 %t.12038, i32 8)
  %t.12040 = load ptr, ptr %structName.408
  %c.12042 = ptrtoint ptr %t.12040 to i64
  %r.12041 = call i64 @kx_map_get(i64 %r.12039, i64 %c.12042)
  %cast.12043 = inttoptr i64 %r.12041 to ptr
  %r.12044 = call i64 @SplitAll(ptr %cast.12043, ptr @.str.97)
  %fields.413 = alloca i64
  store i64 %r.12044, ptr %fields.413
  %t.12045 = load i64, ptr %fields.413
  %ext.12047 = sext i32 0 to i64
  %r.12046 = call i64 @kx_list_get(i64 %t.12045, i64 %ext.12047)
  %ext.12049 = inttoptr i64 %r.12046 to ptr
  %r.12050 = call i1 @kx_str_eq(ptr %ext.12049, ptr @.str.12)
  br i1 %r.12050, label %if.then.12051, label %if.merge.12052
if.then.12051:
  %r.12053 = call i64 @kx_list_new(i32 0)
  store i64 %r.12053, ptr %fields.413
  br label %if.merge.12052
if.merge.12052:
  %t.12054 = sub i32 0, 1
  %fidx.414 = alloca i32
  store i32 %t.12054, ptr %fidx.414
  %fi.415 = alloca i32
  store i32 0, ptr %fi.415
  br label %for.cond.12055
for.cond.12055:
  %t.12059 = load i32, ptr %fi.415
  %t.12060 = load i64, ptr %fields.413
  %r.12061 = call i64 @kx_list_size(i64 %t.12060)
  %ext.12062 = sext i32 %t.12059 to i64
  %t.12063 = icmp slt i64 %ext.12062, %r.12061
  br i1 %t.12063, label %for.body.12056, label %for.end.12058
for.body.12056:
  %t.12064 = load i64, ptr %fields.413
  %t.12065 = load i32, ptr %fi.415
  %ext.12067 = sext i32 %t.12065 to i64
  %r.12066 = call i64 @kx_list_get(i64 %t.12064, i64 %ext.12067)
  %t.12068 = load ptr, ptr %m.405
  %ext.12070 = inttoptr i64 %r.12066 to ptr
  %r.12071 = call i1 @kx_str_eq(ptr %ext.12070, ptr %t.12068)
  br i1 %r.12071, label %if.then.12072, label %if.merge.12073
if.then.12072:
  %t.12074 = load i32, ptr %fi.415
  store i32 %t.12074, ptr %fidx.414
  br label %for.end.12058
dead.12075:
  br label %if.merge.12073
if.merge.12073:
  br label %for.inc.12057
for.inc.12057:
  %t.12076 = load i32, ptr %fi.415
  %t.12077 = add i32 %t.12076, 1
  store i32 %t.12077, ptr %fi.415
  br label %for.cond.12055
for.end.12058:
  %t.12078 = load i32, ptr %fidx.414
  %t.12079 = icmp sge i32 %t.12078, 0
  br i1 %t.12079, label %if.then.12080, label %if.merge.12081
if.then.12080:
  %t.12082 = load i64, ptr %g.addr
  %r.12083 = call i64 @kx_struct_get(i64 %t.12082, i32 4)
  %t.12084 = load i64, ptr %g.addr
  %r.12085 = call i64 @kx_struct_get(i64 %t.12084, i32 4)
  %ext.12087 = sext i32 0 to i64
  %r.12086 = call i64 @kx_list_get(i64 %r.12085, i64 %ext.12087)
  %ext.12088 = sext i32 1 to i64
  %t.12089 = add i64 %r.12086, %ext.12088
  %ext.12090 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12083, i64 %ext.12090, i64 %t.12089)
  %t.12091 = load i64, ptr %g.addr
  %r.12092 = call i64 @kx_struct_get(i64 %t.12091, i32 4)
  %ext.12094 = sext i32 0 to i64
  %r.12093 = call i64 @kx_list_get(i64 %r.12092, i64 %ext.12094)
  %r.12095 = call ptr @kx_int_str(i64 %r.12093)
  %r.12097 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12095)
  %r.416 = alloca ptr
  store ptr %r.12097, ptr %r.416
  %t.12098 = load i64, ptr %g.addr
  %t.12099 = load ptr, ptr %r.416
  %r.12101 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12099)
  %r.12103 = call ptr @kx_str_cat(ptr %r.12101, ptr @.str.442)
  %t.12104 = load i64, ptr %bv.403
  %ext.12106 = call ptr @kx_int_str(i64 %t.12104)
  %r.12107 = call ptr @kx_str_cat(ptr %r.12103, ptr %ext.12106)
  %r.12109 = call ptr @kx_str_cat(ptr %r.12107, ptr @.str.391)
  %t.12110 = load i32, ptr %fidx.414
  %ext.12111 = sext i32 %t.12110 to i64
  %r.12112 = call ptr @kx_int_str(i64 %ext.12111)
  %r.12114 = call ptr @kx_str_cat(ptr %r.12109, ptr %r.12112)
  %r.12116 = call ptr @kx_str_cat(ptr %r.12114, ptr @.str.100)
  %r.12117 = call i64 @Emit(i64 %t.12098, ptr %r.12116)
  %t.12118 = load ptr, ptr %m.405
  %r.12120 = call i1 @kx_str_eq(ptr %t.12118, ptr @.str.287)
  %t.12121 = load ptr, ptr %m.405
  %r.12123 = call i1 @kx_str_eq(ptr %t.12121, ptr @.str.288)
  %t.12124 = or i1 %r.12120, %r.12123
  %t.12125 = load ptr, ptr %m.405
  %r.12127 = call i1 @kx_str_eq(ptr %t.12125, ptr @.str.290)
  %t.12128 = or i1 %t.12124, %r.12127
  br i1 %t.12128, label %if.then.12129, label %if.merge.12130
if.then.12129:
  %t.12131 = load i64, ptr %g.addr
  %r.12132 = call i64 @kx_struct_get(i64 %t.12131, i32 4)
  %t.12133 = load i64, ptr %g.addr
  %r.12134 = call i64 @kx_struct_get(i64 %t.12133, i32 4)
  %ext.12136 = sext i32 0 to i64
  %r.12135 = call i64 @kx_list_get(i64 %r.12134, i64 %ext.12136)
  %ext.12137 = sext i32 1 to i64
  %t.12138 = add i64 %r.12135, %ext.12137
  %ext.12139 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12132, i64 %ext.12139, i64 %t.12138)
  %t.12140 = load i64, ptr %g.addr
  %r.12141 = call i64 @kx_struct_get(i64 %t.12140, i32 4)
  %ext.12143 = sext i32 0 to i64
  %r.12142 = call i64 @kx_list_get(i64 %r.12141, i64 %ext.12143)
  %r.12144 = call ptr @kx_int_str(i64 %r.12142)
  %r.12146 = call ptr @kx_str_cat(ptr @.str.443, ptr %r.12144)
  %p.417 = alloca ptr
  store ptr %r.12146, ptr %p.417
  %t.12147 = load i64, ptr %g.addr
  %t.12148 = load ptr, ptr %p.417
  %r.12150 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12148)
  %r.12152 = call ptr @kx_str_cat(ptr %r.12150, ptr @.str.277)
  %t.12153 = load ptr, ptr %r.416
  %r.12155 = call ptr @kx_str_cat(ptr %r.12152, ptr %t.12153)
  %r.12157 = call ptr @kx_str_cat(ptr %r.12155, ptr @.str.278)
  %r.12158 = call i64 @Emit(i64 %t.12147, ptr %r.12157)
  %t.12159 = load ptr, ptr %p.417
  %r.12161 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.12159)
  ret ptr %r.12161
dead.12162:
  br label %if.merge.12130
if.merge.12130:
  %t.12163 = load ptr, ptr %r.416
  %r.12165 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12163)
  ret ptr %r.12165
dead.12166:
  br label %if.merge.12081
if.merge.12081:
  br label %if.merge.12037
if.merge.12037:
  %t.12167 = load i64, ptr %bt.404
  %ext.12169 = inttoptr i64 %t.12167 to ptr
  %r.12170 = call i1 @kx_str_eq(ptr %ext.12169, ptr @.str.269)
  %t.12171 = load ptr, ptr %m.405
  %r.12173 = call i1 @kx_str_eq(ptr %t.12171, ptr @.str.300)
  %t.12174 = and i1 %r.12170, %r.12173
  br i1 %t.12174, label %if.then.12175, label %if.merge.12176
if.then.12175:
  %t.12177 = load i64, ptr %baseExpr.409
  %ext.12179 = inttoptr i64 %t.12177 to ptr
  %r.12180 = call i1 @kx_str_eq(ptr %ext.12179, ptr @.str.92)
  %t.12181 = load i64, ptr %g.addr
  %r.12182 = call i64 @kx_struct_get(i64 %t.12181, i32 6)
  %t.12183 = load i64, ptr %baseExpr.409
  %r.12184 = call i1 @kx_map_has(i64 %r.12182, i64 %t.12183)
  %t.12185 = and i1 %r.12180, %r.12184
  br i1 %t.12185, label %if.then.12186, label %if.merge.12187
if.then.12186:
  %t.12188 = load i64, ptr %g.addr
  %r.12189 = call i64 @kx_struct_get(i64 %t.12188, i32 6)
  %t.12190 = load i64, ptr %baseExpr.409
  %r.12191 = call i64 @kx_list_get(i64 %r.12189, i64 %t.12190)
  %varType.418 = alloca i64
  store i64 %r.12191, ptr %varType.418
  %t.12192 = load i64, ptr %varType.418
  %ext.12193 = inttoptr i64 %t.12192 to ptr
  %r.12194 = call i1 @kx_str_starts_with(ptr %ext.12193, ptr @.str.286)
  br i1 %r.12194, label %if.then.12195, label %if.merge.12196
if.then.12195:
  %t.12197 = load i64, ptr %varType.418
  %ext.12198 = inttoptr i64 %t.12197 to ptr
  %ext.12199 = sext i32 7 to i64
  %r.12200 = call i64 @kx_str_len(ptr %ext.12198)
  %r.12201 = call ptr @kx_str_substr(ptr %ext.12198, i64 %ext.12199, i64 %r.12200)
  %structName.419 = alloca ptr
  store ptr %r.12201, ptr %structName.419
  %t.12202 = load i64, ptr %g.addr
  %r.12203 = call i64 @kx_struct_get(i64 %t.12202, i32 8)
  %t.12204 = load ptr, ptr %structName.419
  %c.12205 = ptrtoint ptr %t.12204 to i64
  %r.12206 = call i1 @kx_map_has(i64 %r.12203, i64 %c.12205)
  br i1 %r.12206, label %if.then.12207, label %if.merge.12208
if.then.12207:
  %t.12209 = load i64, ptr %g.addr
  %r.12210 = call i64 @kx_struct_get(i64 %t.12209, i32 8)
  %t.12211 = load ptr, ptr %structName.419
  %c.12213 = ptrtoint ptr %t.12211 to i64
  %r.12212 = call i64 @kx_map_get(i64 %r.12210, i64 %c.12213)
  %fieldStr.420 = alloca i64
  store i64 %r.12212, ptr %fieldStr.420
  %t.12214 = load i64, ptr %fieldStr.420
  %cast.12215 = inttoptr i64 %t.12214 to ptr
  %r.12216 = call i64 @SplitAll(ptr %cast.12215, ptr @.str.97)
  %fields.421 = alloca i64
  store i64 %r.12216, ptr %fields.421
  %t.12217 = load i64, ptr %fields.421
  %ext.12219 = sext i32 0 to i64
  %r.12218 = call i64 @kx_list_get(i64 %t.12217, i64 %ext.12219)
  %ext.12221 = inttoptr i64 %r.12218 to ptr
  %r.12222 = call i1 @kx_str_eq(ptr %ext.12221, ptr @.str.12)
  br i1 %r.12222, label %if.then.12223, label %if.merge.12224
if.then.12223:
  %r.12225 = call i64 @kx_list_new(i32 0)
  store i64 %r.12225, ptr %fields.421
  br label %if.merge.12224
if.merge.12224:
  %t.12226 = sub i32 0, 1
  %fidx.422 = alloca i32
  store i32 %t.12226, ptr %fidx.422
  %fi.423 = alloca i32
  store i32 0, ptr %fi.423
  br label %for.cond.12227
for.cond.12227:
  %t.12231 = load i32, ptr %fi.423
  %t.12232 = load i64, ptr %fields.421
  %r.12233 = call i64 @kx_list_size(i64 %t.12232)
  %ext.12234 = sext i32 %t.12231 to i64
  %t.12235 = icmp slt i64 %ext.12234, %r.12233
  br i1 %t.12235, label %for.body.12228, label %for.end.12230
for.body.12228:
  %t.12236 = load i64, ptr %fields.421
  %t.12237 = load i32, ptr %fi.423
  %ext.12239 = sext i32 %t.12237 to i64
  %r.12238 = call i64 @kx_list_get(i64 %t.12236, i64 %ext.12239)
  %t.12240 = load ptr, ptr %m.405
  %ext.12242 = inttoptr i64 %r.12238 to ptr
  %r.12243 = call i1 @kx_str_eq(ptr %ext.12242, ptr %t.12240)
  br i1 %r.12243, label %if.then.12244, label %if.merge.12245
if.then.12244:
  %t.12246 = load i32, ptr %fi.423
  store i32 %t.12246, ptr %fidx.422
  br label %for.end.12230
dead.12247:
  br label %if.merge.12245
if.merge.12245:
  br label %for.inc.12229
for.inc.12229:
  %t.12248 = load i32, ptr %fi.423
  %t.12249 = add i32 %t.12248, 1
  store i32 %t.12249, ptr %fi.423
  br label %for.cond.12227
for.end.12230:
  %t.12250 = load i32, ptr %fidx.422
  %t.12251 = icmp sge i32 %t.12250, 0
  br i1 %t.12251, label %if.then.12252, label %if.merge.12253
if.then.12252:
  %t.12254 = load i64, ptr %g.addr
  %r.12255 = call i64 @kx_struct_get(i64 %t.12254, i32 4)
  %t.12256 = load i64, ptr %g.addr
  %r.12257 = call i64 @kx_struct_get(i64 %t.12256, i32 4)
  %ext.12259 = sext i32 0 to i64
  %r.12258 = call i64 @kx_list_get(i64 %r.12257, i64 %ext.12259)
  %ext.12260 = sext i32 1 to i64
  %t.12261 = add i64 %r.12258, %ext.12260
  %ext.12262 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12255, i64 %ext.12262, i64 %t.12261)
  %t.12263 = load i64, ptr %g.addr
  %r.12264 = call i64 @kx_struct_get(i64 %t.12263, i32 4)
  %ext.12266 = sext i32 0 to i64
  %r.12265 = call i64 @kx_list_get(i64 %r.12264, i64 %ext.12266)
  %r.12267 = call ptr @kx_int_str(i64 %r.12265)
  %r.12269 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12267)
  %r.424 = alloca ptr
  store ptr %r.12269, ptr %r.424
  %t.12270 = load i64, ptr %g.addr
  %t.12271 = load ptr, ptr %r.424
  %r.12273 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12271)
  %r.12275 = call ptr @kx_str_cat(ptr %r.12273, ptr @.str.442)
  %t.12276 = load i64, ptr %bv.403
  %ext.12278 = call ptr @kx_int_str(i64 %t.12276)
  %r.12279 = call ptr @kx_str_cat(ptr %r.12275, ptr %ext.12278)
  %r.12281 = call ptr @kx_str_cat(ptr %r.12279, ptr @.str.391)
  %t.12282 = load i32, ptr %fidx.422
  %ext.12283 = sext i32 %t.12282 to i64
  %r.12284 = call ptr @kx_int_str(i64 %ext.12283)
  %r.12286 = call ptr @kx_str_cat(ptr %r.12281, ptr %r.12284)
  %r.12288 = call ptr @kx_str_cat(ptr %r.12286, ptr @.str.100)
  %r.12289 = call i64 @Emit(i64 %t.12270, ptr %r.12288)
  %t.12290 = load ptr, ptr %r.424
  %r.12292 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12290)
  ret ptr %r.12292
dead.12293:
  br label %if.merge.12253
if.merge.12253:
  br label %if.merge.12208
if.merge.12208:
  br label %if.merge.12196
if.merge.12196:
  br label %if.merge.12187
if.merge.12187:
  br label %if.merge.12176
if.merge.12176:
  %t.12294 = load ptr, ptr %base.402
  ret ptr %t.12294
dead.12295:
  br label %if.merge.11859
if.merge.11859:
  %t.12296 = load i64, ptr %e.addr
  %r.12297 = call i64 @kx_struct_get(i64 %t.12296, i32 0)
  %field.12298 = inttoptr i64 %r.12297 to ptr
  %r.12300 = call i1 @kx_str_eq(ptr %field.12298, ptr @.str.103)
  br i1 %r.12300, label %if.then.12301, label %if.merge.12302
if.then.12301:
  %t.12303 = load i64, ptr %arena.addr
  %t.12304 = load i64, ptr %e.addr
  %cast.12305 = sext i32 0 to i64
  %r.12306 = call i64 @Child(i64 %t.12303, i64 %t.12304, i64 %cast.12305)
  %callee.425 = alloca i64
  store i64 %r.12306, ptr %callee.425
  %t.12307 = load i64, ptr %callee.425
  %ext.12309 = inttoptr i64 %t.12307 to ptr
  %r.12310 = call i1 @kx_str_eq(ptr %ext.12309, ptr @.str.111)
  br i1 %r.12310, label %if.then.12311, label %if.merge.12312
if.then.12311:
  %t.12313 = load i64, ptr %arena.addr
  %t.12314 = load i64, ptr %callee.425
  %cast.12315 = sext i32 0 to i64
  %r.12316 = call i64 @Child(i64 %t.12313, i64 %t.12314, i64 %cast.12315)
  %base.426 = alloca i64
  store i64 %r.12316, ptr %base.426
  %t.12317 = load i64, ptr %callee.425
  %m.427 = alloca i64
  store i64 %t.12317, ptr %m.427
  %t.12318 = load i64, ptr %base.426
  %ext.12320 = inttoptr i64 %t.12318 to ptr
  %r.12321 = call i1 @kx_str_eq(ptr %ext.12320, ptr @.str.92)
  %t.12322 = load i64, ptr %base.426
  %ext.12324 = inttoptr i64 %t.12322 to ptr
  %r.12325 = call i1 @kx_str_eq(ptr %ext.12324, ptr @.str.301)
  %t.12326 = and i1 %r.12321, %r.12325
  br i1 %t.12326, label %if.then.12327, label %if.merge.12328
if.then.12327:
  %t.12329 = load i64, ptr %m.427
  %ext.12331 = inttoptr i64 %t.12329 to ptr
  %r.12332 = call i1 @kx_str_eq(ptr %ext.12331, ptr @.str.306)
  br i1 %r.12332, label %if.then.12333, label %if.merge.12334
if.then.12333:
  %t.12335 = load i64, ptr %e.addr
  %r.12336 = call i64 @kx_struct_get(i64 %t.12335, i32 4)
  %r.12337 = call i64 @kx_list_size(i64 %r.12336)
  %ext.12338 = sext i32 1 to i64
  %t.12339 = icmp sgt i64 %r.12337, %ext.12338
  br i1 %t.12339, label %if.then.12340, label %if.else.12342
if.then.12340:
  %t.12343 = load i64, ptr %g.addr
  %t.12344 = load i64, ptr %arena.addr
  %t.12345 = load i64, ptr %e.addr
  %cast.12346 = sext i32 1 to i64
  %r.12347 = call i64 @Child(i64 %t.12344, i64 %t.12345, i64 %cast.12346)
  %t.12348 = load i64, ptr %arena.addr
  %r.12349 = call ptr @GenExpr(i64 %t.12343, i64 %r.12347, i64 %t.12348)
  %a.428 = alloca ptr
  store ptr %r.12349, ptr %a.428
  %t.12350 = load ptr, ptr %a.428
  %r.12351 = call i64 @XVal(ptr %t.12350)
  %av.429 = alloca i64
  store i64 %r.12351, ptr %av.429
  %t.12352 = load ptr, ptr %a.428
  %r.12353 = call i64 @XType(ptr %t.12352)
  %ext.12355 = inttoptr i64 %r.12353 to ptr
  %r.12356 = call i1 @kx_str_eq(ptr %ext.12355, ptr @.str.269)
  br i1 %r.12356, label %if.then.12357, label %if.merge.12358
if.then.12357:
  %t.12359 = load i64, ptr %g.addr
  %r.12360 = call i64 @kx_struct_get(i64 %t.12359, i32 4)
  %t.12361 = load i64, ptr %g.addr
  %r.12362 = call i64 @kx_struct_get(i64 %t.12361, i32 4)
  %ext.12364 = sext i32 0 to i64
  %r.12363 = call i64 @kx_list_get(i64 %r.12362, i64 %ext.12364)
  %ext.12365 = sext i32 1 to i64
  %t.12366 = add i64 %r.12363, %ext.12365
  %ext.12367 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12360, i64 %ext.12367, i64 %t.12366)
  %t.12368 = load i64, ptr %g.addr
  %r.12369 = call i64 @kx_struct_get(i64 %t.12368, i32 4)
  %ext.12371 = sext i32 0 to i64
  %r.12370 = call i64 @kx_list_get(i64 %r.12369, i64 %ext.12371)
  %r.12372 = call ptr @kx_int_str(i64 %r.12370)
  %r.12374 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.12372)
  %ext.430 = alloca ptr
  store ptr %r.12374, ptr %ext.430
  %t.12375 = load i64, ptr %g.addr
  %t.12376 = load ptr, ptr %ext.430
  %r.12378 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12376)
  %r.12380 = call ptr @kx_str_cat(ptr %r.12378, ptr @.str.277)
  %t.12381 = load i64, ptr %av.429
  %ext.12383 = call ptr @kx_int_str(i64 %t.12381)
  %r.12384 = call ptr @kx_str_cat(ptr %r.12380, ptr %ext.12383)
  %r.12386 = call ptr @kx_str_cat(ptr %r.12384, ptr @.str.278)
  %r.12387 = call i64 @Emit(i64 %t.12375, ptr %r.12386)
  %t.12388 = load ptr, ptr %ext.430
  %ptrtoint.12389 = ptrtoint ptr %t.12388 to i64
  store i64 %ptrtoint.12389, ptr %av.429
  br label %if.merge.12358
if.merge.12358:
  %t.12390 = load i64, ptr %g.addr
  %t.12391 = load i64, ptr %av.429
  %ext.12393 = call ptr @kx_int_str(i64 %t.12391)
  %r.12394 = call ptr @kx_str_cat(ptr @.str.444, ptr %ext.12393)
  %r.12396 = call ptr @kx_str_cat(ptr %r.12394, ptr @.str.100)
  %r.12397 = call i64 @Emit(i64 %t.12390, ptr %r.12396)
  br label %if.merge.12341
if.else.12342:
  %t.12398 = load i64, ptr %g.addr
  %t.12399 = load i64, ptr %g.addr
  %r.12400 = call ptr @GetStr(i64 %t.12399, ptr @.str.12)
  %r.12402 = call ptr @kx_str_cat(ptr @.str.444, ptr %r.12400)
  %r.12404 = call ptr @kx_str_cat(ptr %r.12402, ptr @.str.100)
  %r.12405 = call i64 @Emit(i64 %t.12398, ptr %r.12404)
  br label %if.merge.12341
if.merge.12341:
  ret ptr @.str.445
dead.12406:
  br label %if.merge.12334
if.merge.12334:
  %t.12407 = load i64, ptr %m.427
  %ext.12409 = inttoptr i64 %t.12407 to ptr
  %r.12410 = call i1 @kx_str_eq(ptr %ext.12409, ptr @.str.307)
  br i1 %r.12410, label %if.then.12411, label %if.merge.12412
if.then.12411:
  %t.12413 = load i64, ptr %e.addr
  %r.12414 = call i64 @kx_struct_get(i64 %t.12413, i32 4)
  %r.12415 = call i64 @kx_list_size(i64 %r.12414)
  %ext.12416 = sext i32 1 to i64
  %t.12417 = icmp sgt i64 %r.12415, %ext.12416
  br i1 %t.12417, label %if.then.12418, label %if.merge.12419
if.then.12418:
  %t.12420 = load i64, ptr %g.addr
  %t.12421 = load i64, ptr %arena.addr
  %t.12422 = load i64, ptr %e.addr
  %cast.12423 = sext i32 1 to i64
  %r.12424 = call i64 @Child(i64 %t.12421, i64 %t.12422, i64 %cast.12423)
  %t.12425 = load i64, ptr %arena.addr
  %r.12426 = call ptr @GenExpr(i64 %t.12420, i64 %r.12424, i64 %t.12425)
  %a.431 = alloca ptr
  store ptr %r.12426, ptr %a.431
  %t.12427 = load i64, ptr %g.addr
  %t.12428 = load ptr, ptr %a.431
  %r.12429 = call i64 @XType(ptr %t.12428)
  %ext.12431 = call ptr @kx_int_str(i64 %r.12429)
  %r.12432 = call ptr @kx_str_cat(ptr @.str.446, ptr %ext.12431)
  %r.12434 = call ptr @kx_str_cat(ptr %r.12432, ptr @.str.8)
  %t.12435 = load ptr, ptr %a.431
  %r.12436 = call i64 @XVal(ptr %t.12435)
  %ext.12438 = call ptr @kx_int_str(i64 %r.12436)
  %r.12439 = call ptr @kx_str_cat(ptr %r.12434, ptr %ext.12438)
  %r.12441 = call ptr @kx_str_cat(ptr %r.12439, ptr @.str.100)
  %r.12442 = call i64 @Emit(i64 %t.12427, ptr %r.12441)
  br label %if.merge.12419
if.merge.12419:
  ret ptr @.str.445
dead.12443:
  br label %if.merge.12412
if.merge.12412:
  %t.12444 = load i64, ptr %m.427
  %ext.12446 = inttoptr i64 %t.12444 to ptr
  %r.12447 = call i1 @kx_str_eq(ptr %ext.12446, ptr @.str.302)
  br i1 %r.12447, label %if.then.12448, label %if.merge.12449
if.then.12448:
  %t.12450 = load i64, ptr %g.addr
  %t.12451 = load i64, ptr %arena.addr
  %t.12452 = load i64, ptr %e.addr
  %cast.12453 = sext i32 1 to i64
  %r.12454 = call i64 @Child(i64 %t.12451, i64 %t.12452, i64 %cast.12453)
  %t.12455 = load i64, ptr %arena.addr
  %r.12456 = call ptr @GenExpr(i64 %t.12450, i64 %r.12454, i64 %t.12455)
  %a.432 = alloca ptr
  store ptr %r.12456, ptr %a.432
  %t.12457 = load i64, ptr %g.addr
  %r.12458 = call i64 @kx_struct_get(i64 %t.12457, i32 4)
  %t.12459 = load i64, ptr %g.addr
  %r.12460 = call i64 @kx_struct_get(i64 %t.12459, i32 4)
  %ext.12462 = sext i32 0 to i64
  %r.12461 = call i64 @kx_list_get(i64 %r.12460, i64 %ext.12462)
  %ext.12463 = sext i32 1 to i64
  %t.12464 = add i64 %r.12461, %ext.12463
  %ext.12465 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12458, i64 %ext.12465, i64 %t.12464)
  %t.12466 = load i64, ptr %g.addr
  %r.12467 = call i64 @kx_struct_get(i64 %t.12466, i32 4)
  %ext.12469 = sext i32 0 to i64
  %r.12468 = call i64 @kx_list_get(i64 %r.12467, i64 %ext.12469)
  %r.12470 = call ptr @kx_int_str(i64 %r.12468)
  %r.12472 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12470)
  %r.433 = alloca ptr
  store ptr %r.12472, ptr %r.433
  %t.12473 = load i64, ptr %g.addr
  %t.12474 = load ptr, ptr %r.433
  %r.12476 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12474)
  %r.12478 = call ptr @kx_str_cat(ptr %r.12476, ptr @.str.447)
  %t.12479 = load ptr, ptr %a.432
  %r.12480 = call i64 @XVal(ptr %t.12479)
  %ext.12482 = call ptr @kx_int_str(i64 %r.12480)
  %r.12483 = call ptr @kx_str_cat(ptr %r.12478, ptr %ext.12482)
  %r.12485 = call ptr @kx_str_cat(ptr %r.12483, ptr @.str.100)
  %r.12486 = call i64 @Emit(i64 %t.12473, ptr %r.12485)
  %t.12487 = load ptr, ptr %r.433
  %r.12489 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.12487)
  ret ptr %r.12489
dead.12490:
  br label %if.merge.12449
if.merge.12449:
  %t.12491 = load i64, ptr %m.427
  %ext.12493 = inttoptr i64 %t.12491 to ptr
  %r.12494 = call i1 @kx_str_eq(ptr %ext.12493, ptr @.str.448)
  br i1 %r.12494, label %if.then.12495, label %if.merge.12496
if.then.12495:
  %t.12497 = load i64, ptr %g.addr
  %t.12498 = load i64, ptr %arena.addr
  %t.12499 = load i64, ptr %e.addr
  %cast.12500 = sext i32 1 to i64
  %r.12501 = call i64 @Child(i64 %t.12498, i64 %t.12499, i64 %cast.12500)
  %t.12502 = load i64, ptr %arena.addr
  %r.12503 = call ptr @GenExpr(i64 %t.12497, i64 %r.12501, i64 %t.12502)
  %a1.434 = alloca ptr
  store ptr %r.12503, ptr %a1.434
  %t.12504 = load i64, ptr %g.addr
  %t.12505 = load i64, ptr %arena.addr
  %t.12506 = load i64, ptr %e.addr
  %cast.12507 = sext i32 2 to i64
  %r.12508 = call i64 @Child(i64 %t.12505, i64 %t.12506, i64 %cast.12507)
  %t.12509 = load i64, ptr %arena.addr
  %r.12510 = call ptr @GenExpr(i64 %t.12504, i64 %r.12508, i64 %t.12509)
  %a2.435 = alloca ptr
  store ptr %r.12510, ptr %a2.435
  %t.12511 = load i64, ptr %g.addr
  %r.12512 = call i64 @kx_struct_get(i64 %t.12511, i32 4)
  %t.12513 = load i64, ptr %g.addr
  %r.12514 = call i64 @kx_struct_get(i64 %t.12513, i32 4)
  %ext.12516 = sext i32 0 to i64
  %r.12515 = call i64 @kx_list_get(i64 %r.12514, i64 %ext.12516)
  %ext.12517 = sext i32 1 to i64
  %t.12518 = add i64 %r.12515, %ext.12517
  %ext.12519 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12512, i64 %ext.12519, i64 %t.12518)
  %t.12520 = load i64, ptr %g.addr
  %r.12521 = call i64 @kx_struct_get(i64 %t.12520, i32 4)
  %ext.12523 = sext i32 0 to i64
  %r.12522 = call i64 @kx_list_get(i64 %r.12521, i64 %ext.12523)
  %r.12524 = call ptr @kx_int_str(i64 %r.12522)
  %r.12526 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12524)
  %r.436 = alloca ptr
  store ptr %r.12526, ptr %r.436
  %t.12527 = load i64, ptr %g.addr
  %t.12528 = load ptr, ptr %r.436
  %r.12530 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12528)
  %r.12532 = call ptr @kx_str_cat(ptr %r.12530, ptr @.str.449)
  %t.12533 = load ptr, ptr %a1.434
  %r.12534 = call i64 @XVal(ptr %t.12533)
  %ext.12536 = call ptr @kx_int_str(i64 %r.12534)
  %r.12537 = call ptr @kx_str_cat(ptr %r.12532, ptr %ext.12536)
  %r.12539 = call ptr @kx_str_cat(ptr %r.12537, ptr @.str.396)
  %t.12540 = load ptr, ptr %a2.435
  %r.12541 = call i64 @XVal(ptr %t.12540)
  %ext.12543 = call ptr @kx_int_str(i64 %r.12541)
  %r.12544 = call ptr @kx_str_cat(ptr %r.12539, ptr %ext.12543)
  %r.12546 = call ptr @kx_str_cat(ptr %r.12544, ptr @.str.100)
  %r.12547 = call i64 @Emit(i64 %t.12527, ptr %r.12546)
  %t.12548 = load ptr, ptr %r.436
  %r.12550 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.12548)
  ret ptr %r.12550
dead.12551:
  br label %if.merge.12496
if.merge.12496:
  %t.12552 = load i64, ptr %m.427
  %ext.12554 = inttoptr i64 %t.12552 to ptr
  %r.12555 = call i1 @kx_str_eq(ptr %ext.12554, ptr @.str.303)
  br i1 %r.12555, label %if.then.12556, label %if.merge.12557
if.then.12556:
  %t.12558 = load i64, ptr %g.addr
  %r.12559 = call i64 @kx_struct_get(i64 %t.12558, i32 4)
  %t.12560 = load i64, ptr %g.addr
  %r.12561 = call i64 @kx_struct_get(i64 %t.12560, i32 4)
  %ext.12563 = sext i32 0 to i64
  %r.12562 = call i64 @kx_list_get(i64 %r.12561, i64 %ext.12563)
  %ext.12564 = sext i32 1 to i64
  %t.12565 = add i64 %r.12562, %ext.12564
  %ext.12566 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12559, i64 %ext.12566, i64 %t.12565)
  %t.12567 = load i64, ptr %g.addr
  %r.12568 = call i64 @kx_struct_get(i64 %t.12567, i32 4)
  %ext.12570 = sext i32 0 to i64
  %r.12569 = call i64 @kx_list_get(i64 %r.12568, i64 %ext.12570)
  %r.12571 = call ptr @kx_int_str(i64 %r.12569)
  %r.12573 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12571)
  %r.437 = alloca ptr
  store ptr %r.12573, ptr %r.437
  %t.12574 = load i64, ptr %g.addr
  %t.12575 = load ptr, ptr %r.437
  %r.12577 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12575)
  %r.12579 = call ptr @kx_str_cat(ptr %r.12577, ptr @.str.450)
  %r.12580 = call i64 @Emit(i64 %t.12574, ptr %r.12579)
  %t.12581 = load ptr, ptr %r.437
  %r.12583 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.12581)
  ret ptr %r.12583
dead.12584:
  br label %if.merge.12557
if.merge.12557:
  %t.12585 = load i64, ptr %m.427
  %ext.12587 = inttoptr i64 %t.12585 to ptr
  %r.12588 = call i1 @kx_str_eq(ptr %ext.12587, ptr @.str.304)
  br i1 %r.12588, label %if.then.12589, label %if.merge.12590
if.then.12589:
  %t.12591 = load i64, ptr %g.addr
  %r.12592 = call i64 @kx_struct_get(i64 %t.12591, i32 4)
  %t.12593 = load i64, ptr %g.addr
  %r.12594 = call i64 @kx_struct_get(i64 %t.12593, i32 4)
  %ext.12596 = sext i32 0 to i64
  %r.12595 = call i64 @kx_list_get(i64 %r.12594, i64 %ext.12596)
  %ext.12597 = sext i32 1 to i64
  %t.12598 = add i64 %r.12595, %ext.12597
  %ext.12599 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12592, i64 %ext.12599, i64 %t.12598)
  %t.12600 = load i64, ptr %g.addr
  %r.12601 = call i64 @kx_struct_get(i64 %t.12600, i32 4)
  %ext.12603 = sext i32 0 to i64
  %r.12602 = call i64 @kx_list_get(i64 %r.12601, i64 %ext.12603)
  %r.12604 = call ptr @kx_int_str(i64 %r.12602)
  %r.12606 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12604)
  %r.438 = alloca ptr
  store ptr %r.12606, ptr %r.438
  %t.12607 = load i64, ptr %g.addr
  %t.12608 = load ptr, ptr %r.438
  %r.12610 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12608)
  %r.12612 = call ptr @kx_str_cat(ptr %r.12610, ptr @.str.451)
  %r.12613 = call i64 @Emit(i64 %t.12607, ptr %r.12612)
  %t.12614 = load i64, ptr %g.addr
  %t.12615 = load ptr, ptr %r.438
  %r.12617 = call ptr @kx_str_cat(ptr @.str.452, ptr %t.12615)
  %r.12619 = call ptr @kx_str_cat(ptr %r.12617, ptr @.str.100)
  %r.12620 = call i64 @Emit(i64 %t.12614, ptr %r.12619)
  %t.12621 = load ptr, ptr %r.438
  %r.12623 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12621)
  ret ptr %r.12623
dead.12624:
  br label %if.merge.12590
if.merge.12590:
  %t.12625 = load i64, ptr %m.427
  %ext.12627 = inttoptr i64 %t.12625 to ptr
  %r.12628 = call i1 @kx_str_eq(ptr %ext.12627, ptr @.str.308)
  br i1 %r.12628, label %if.then.12629, label %if.merge.12630
if.then.12629:
  %t.12631 = load i64, ptr %g.addr
  %t.12632 = load i64, ptr %arena.addr
  %t.12633 = load i64, ptr %e.addr
  %cast.12634 = sext i32 1 to i64
  %r.12635 = call i64 @Child(i64 %t.12632, i64 %t.12633, i64 %cast.12634)
  %t.12636 = load i64, ptr %arena.addr
  %r.12637 = call ptr @GenExpr(i64 %t.12631, i64 %r.12635, i64 %t.12636)
  %a.439 = alloca ptr
  store ptr %r.12637, ptr %a.439
  %t.12638 = load i64, ptr %g.addr
  %t.12639 = load ptr, ptr %a.439
  %r.12640 = call i64 @XVal(ptr %t.12639)
  %ext.12642 = call ptr @kx_int_str(i64 %r.12640)
  %r.12643 = call ptr @kx_str_cat(ptr @.str.453, ptr %ext.12642)
  %r.12645 = call ptr @kx_str_cat(ptr %r.12643, ptr @.str.100)
  %r.12646 = call i64 @Emit(i64 %t.12638, ptr %r.12645)
  ret ptr @.str.445
dead.12647:
  br label %if.merge.12630
if.merge.12630:
  %t.12648 = load i64, ptr %m.427
  %ext.12650 = inttoptr i64 %t.12648 to ptr
  %r.12651 = call i1 @kx_str_eq(ptr %ext.12650, ptr @.str.17)
  br i1 %r.12651, label %if.then.12652, label %if.merge.12653
if.then.12652:
  %t.12654 = load i64, ptr %g.addr
  %t.12655 = load i64, ptr %arena.addr
  %t.12656 = load i64, ptr %e.addr
  %cast.12657 = sext i32 1 to i64
  %r.12658 = call i64 @Child(i64 %t.12655, i64 %t.12656, i64 %cast.12657)
  %t.12659 = load i64, ptr %arena.addr
  %r.12660 = call ptr @GenExpr(i64 %t.12654, i64 %r.12658, i64 %t.12659)
  %a.440 = alloca ptr
  store ptr %r.12660, ptr %a.440
  %t.12661 = load i64, ptr %g.addr
  %r.12662 = call i64 @kx_struct_get(i64 %t.12661, i32 4)
  %t.12663 = load i64, ptr %g.addr
  %r.12664 = call i64 @kx_struct_get(i64 %t.12663, i32 4)
  %ext.12666 = sext i32 0 to i64
  %r.12665 = call i64 @kx_list_get(i64 %r.12664, i64 %ext.12666)
  %ext.12667 = sext i32 1 to i64
  %t.12668 = add i64 %r.12665, %ext.12667
  %ext.12669 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12662, i64 %ext.12669, i64 %t.12668)
  %t.12670 = load i64, ptr %g.addr
  %r.12671 = call i64 @kx_struct_get(i64 %t.12670, i32 4)
  %ext.12673 = sext i32 0 to i64
  %r.12672 = call i64 @kx_list_get(i64 %r.12671, i64 %ext.12673)
  %r.12674 = call ptr @kx_int_str(i64 %r.12672)
  %r.12676 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12674)
  %r.441 = alloca ptr
  store ptr %r.12676, ptr %r.441
  %t.12677 = load i64, ptr %g.addr
  %t.12678 = load ptr, ptr %r.441
  %r.12680 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12678)
  %r.12682 = call ptr @kx_str_cat(ptr %r.12680, ptr @.str.454)
  %t.12683 = load ptr, ptr %a.440
  %r.12684 = call i64 @XVal(ptr %t.12683)
  %ext.12686 = call ptr @kx_int_str(i64 %r.12684)
  %r.12687 = call ptr @kx_str_cat(ptr %r.12682, ptr %ext.12686)
  %r.12689 = call ptr @kx_str_cat(ptr %r.12687, ptr @.str.100)
  %r.12690 = call i64 @Emit(i64 %t.12677, ptr %r.12689)
  %t.12691 = load ptr, ptr %r.441
  %r.12693 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12691)
  ret ptr %r.12693
dead.12694:
  br label %if.merge.12653
if.merge.12653:
  %t.12695 = load i64, ptr %m.427
  %ext.12697 = inttoptr i64 %t.12695 to ptr
  %r.12698 = call i1 @kx_str_eq(ptr %ext.12697, ptr @.str.309)
  br i1 %r.12698, label %if.then.12699, label %if.merge.12700
if.then.12699:
  %t.12701 = load i64, ptr %g.addr
  %r.12702 = call i64 @Emit(i64 %t.12701, ptr @.str.455)
  ret ptr @.str.445
dead.12703:
  br label %if.merge.12700
if.merge.12700:
  %t.12704 = load i64, ptr %m.427
  %ext.12706 = inttoptr i64 %t.12704 to ptr
  %r.12707 = call i1 @kx_str_eq(ptr %ext.12706, ptr @.str.305)
  br i1 %r.12707, label %if.then.12708, label %if.merge.12709
if.then.12708:
  %t.12710 = load i64, ptr %g.addr
  %t.12711 = load i64, ptr %arena.addr
  %t.12712 = load i64, ptr %e.addr
  %cast.12713 = sext i32 1 to i64
  %r.12714 = call i64 @Child(i64 %t.12711, i64 %t.12712, i64 %cast.12713)
  %t.12715 = load i64, ptr %arena.addr
  %r.12716 = call ptr @GenExpr(i64 %t.12710, i64 %r.12714, i64 %t.12715)
  %a.442 = alloca ptr
  store ptr %r.12716, ptr %a.442
  %t.12717 = load i64, ptr %g.addr
  %r.12718 = call i64 @kx_struct_get(i64 %t.12717, i32 4)
  %t.12719 = load i64, ptr %g.addr
  %r.12720 = call i64 @kx_struct_get(i64 %t.12719, i32 4)
  %ext.12722 = sext i32 0 to i64
  %r.12721 = call i64 @kx_list_get(i64 %r.12720, i64 %ext.12722)
  %ext.12723 = sext i32 1 to i64
  %t.12724 = add i64 %r.12721, %ext.12723
  %ext.12725 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12718, i64 %ext.12725, i64 %t.12724)
  %t.12726 = load i64, ptr %g.addr
  %r.12727 = call i64 @kx_struct_get(i64 %t.12726, i32 4)
  %ext.12729 = sext i32 0 to i64
  %r.12728 = call i64 @kx_list_get(i64 %r.12727, i64 %ext.12729)
  %r.12730 = call ptr @kx_int_str(i64 %r.12728)
  %r.12732 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12730)
  %r.443 = alloca ptr
  store ptr %r.12732, ptr %r.443
  %t.12733 = load i64, ptr %g.addr
  %t.12734 = load ptr, ptr %r.443
  %r.12736 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12734)
  %r.12738 = call ptr @kx_str_cat(ptr %r.12736, ptr @.str.456)
  %t.12739 = load ptr, ptr %a.442
  %r.12740 = call i64 @XVal(ptr %t.12739)
  %ext.12742 = call ptr @kx_int_str(i64 %r.12740)
  %r.12743 = call ptr @kx_str_cat(ptr %r.12738, ptr %ext.12742)
  %r.12745 = call ptr @kx_str_cat(ptr %r.12743, ptr @.str.100)
  %r.12746 = call i64 @Emit(i64 %t.12733, ptr %r.12745)
  %t.12747 = load ptr, ptr %r.443
  %r.12749 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12747)
  ret ptr %r.12749
dead.12750:
  br label %if.merge.12709
if.merge.12709:
  br label %if.merge.12328
if.merge.12328:
  %t.12751 = load i64, ptr %g.addr
  %t.12752 = load i64, ptr %base.426
  %t.12753 = load i64, ptr %arena.addr
  %r.12754 = call ptr @GenExpr(i64 %t.12751, i64 %t.12752, i64 %t.12753)
  %baseExpr.444 = alloca ptr
  store ptr %r.12754, ptr %baseExpr.444
  %t.12755 = load ptr, ptr %baseExpr.444
  %r.12756 = call i64 @XVal(ptr %t.12755)
  %bv.445 = alloca i64
  store i64 %r.12756, ptr %bv.445
  %t.12757 = load ptr, ptr %baseExpr.444
  %r.12758 = call i64 @XType(ptr %t.12757)
  %bt.446 = alloca i64
  store i64 %r.12758, ptr %bt.446
  %t.12759 = load i64, ptr %m.427
  %ext.12761 = inttoptr i64 %t.12759 to ptr
  %r.12762 = call i1 @kx_str_eq(ptr %ext.12761, ptr @.str.312)
  br i1 %r.12762, label %if.then.12763, label %if.merge.12764
if.then.12763:
  %t.12765 = load i64, ptr %g.addr
  %t.12766 = load i64, ptr %arena.addr
  %t.12767 = load i64, ptr %e.addr
  %cast.12768 = sext i32 1 to i64
  %r.12769 = call i64 @Child(i64 %t.12766, i64 %t.12767, i64 %cast.12768)
  %t.12770 = load i64, ptr %arena.addr
  %r.12771 = call ptr @GenExpr(i64 %t.12765, i64 %r.12769, i64 %t.12770)
  %a.447 = alloca ptr
  store ptr %r.12771, ptr %a.447
  %t.12772 = load i64, ptr %g.addr
  %t.12773 = load i64, ptr %bv.445
  %ext.12775 = call ptr @kx_int_str(i64 %t.12773)
  %r.12776 = call ptr @kx_str_cat(ptr @.str.457, ptr %ext.12775)
  %r.12778 = call ptr @kx_str_cat(ptr %r.12776, ptr @.str.392)
  %t.12779 = load i64, ptr %g.addr
  %t.12780 = load ptr, ptr %a.447
  %r.12781 = call ptr @ToI64(i64 %t.12779, ptr %t.12780)
  %r.12783 = call ptr @kx_str_cat(ptr %r.12778, ptr %r.12781)
  %r.12785 = call ptr @kx_str_cat(ptr %r.12783, ptr @.str.100)
  %r.12786 = call i64 @Emit(i64 %t.12772, ptr %r.12785)
  ret ptr @.str.445
dead.12787:
  br label %if.merge.12764
if.merge.12764:
  %t.12788 = load i64, ptr %m.427
  %ext.12790 = inttoptr i64 %t.12788 to ptr
  %r.12791 = call i1 @kx_str_eq(ptr %ext.12790, ptr @.str.458)
  %t.12792 = load i64, ptr %m.427
  %ext.12794 = inttoptr i64 %t.12792 to ptr
  %r.12795 = call i1 @kx_str_eq(ptr %ext.12794, ptr @.str.310)
  %t.12796 = or i1 %r.12791, %r.12795
  br i1 %t.12796, label %if.then.12797, label %if.merge.12798
if.then.12797:
  %t.12799 = load i64, ptr %g.addr
  %t.12800 = load i64, ptr %arena.addr
  %t.12801 = load i64, ptr %e.addr
  %cast.12802 = sext i32 1 to i64
  %r.12803 = call i64 @Child(i64 %t.12800, i64 %t.12801, i64 %cast.12802)
  %t.12804 = load i64, ptr %arena.addr
  %r.12805 = call ptr @GenExpr(i64 %t.12799, i64 %r.12803, i64 %t.12804)
  %a.448 = alloca ptr
  store ptr %r.12805, ptr %a.448
  %t.12806 = load i64, ptr %g.addr
  %r.12807 = call i64 @kx_struct_get(i64 %t.12806, i32 4)
  %t.12808 = load i64, ptr %g.addr
  %r.12809 = call i64 @kx_struct_get(i64 %t.12808, i32 4)
  %ext.12811 = sext i32 0 to i64
  %r.12810 = call i64 @kx_list_get(i64 %r.12809, i64 %ext.12811)
  %ext.12812 = sext i32 1 to i64
  %t.12813 = add i64 %r.12810, %ext.12812
  %ext.12814 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12807, i64 %ext.12814, i64 %t.12813)
  %t.12815 = load i64, ptr %g.addr
  %r.12816 = call i64 @kx_struct_get(i64 %t.12815, i32 4)
  %ext.12818 = sext i32 0 to i64
  %r.12817 = call i64 @kx_list_get(i64 %r.12816, i64 %ext.12818)
  %r.12819 = call ptr @kx_int_str(i64 %r.12817)
  %r.12821 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.12819)
  %r.449 = alloca ptr
  store ptr %r.12821, ptr %r.449
  %t.12822 = load ptr, ptr %a.448
  %r.12823 = call i64 @XType(ptr %t.12822)
  %ext.12825 = inttoptr i64 %r.12823 to ptr
  %r.12826 = call i1 @kx_str_eq(ptr %ext.12825, ptr @.str.271)
  br i1 %r.12826, label %if.then.12827, label %if.else.12829
if.then.12827:
  %t.12830 = load ptr, ptr %a.448
  %r.12831 = call i64 @XVal(ptr %t.12830)
  %k.450 = alloca i64
  store i64 %r.12831, ptr %k.450
  %t.12832 = load i64, ptr %g.addr
  %r.12833 = call i64 @kx_struct_get(i64 %t.12832, i32 4)
  %t.12834 = load i64, ptr %g.addr
  %r.12835 = call i64 @kx_struct_get(i64 %t.12834, i32 4)
  %ext.12837 = sext i32 0 to i64
  %r.12836 = call i64 @kx_list_get(i64 %r.12835, i64 %ext.12837)
  %ext.12838 = sext i32 1 to i64
  %t.12839 = add i64 %r.12836, %ext.12838
  %ext.12840 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12833, i64 %ext.12840, i64 %t.12839)
  %t.12841 = load i64, ptr %g.addr
  %r.12842 = call i64 @kx_struct_get(i64 %t.12841, i32 4)
  %ext.12844 = sext i32 0 to i64
  %r.12843 = call i64 @kx_list_get(i64 %r.12842, i64 %ext.12844)
  %r.12845 = call ptr @kx_int_str(i64 %r.12843)
  %r.12847 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.12845)
  %c.451 = alloca ptr
  store ptr %r.12847, ptr %c.451
  %t.12848 = load i64, ptr %g.addr
  %t.12849 = load ptr, ptr %c.451
  %r.12851 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12849)
  %r.12853 = call ptr @kx_str_cat(ptr %r.12851, ptr @.str.273)
  %t.12854 = load i64, ptr %k.450
  %ext.12856 = call ptr @kx_int_str(i64 %t.12854)
  %r.12857 = call ptr @kx_str_cat(ptr %r.12853, ptr %ext.12856)
  %r.12859 = call ptr @kx_str_cat(ptr %r.12857, ptr @.str.274)
  %r.12860 = call i64 @Emit(i64 %t.12848, ptr %r.12859)
  %t.12861 = load i64, ptr %g.addr
  %t.12862 = load ptr, ptr %r.449
  %r.12864 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12862)
  %r.12866 = call ptr @kx_str_cat(ptr %r.12864, ptr @.str.460)
  %t.12867 = load i64, ptr %bv.445
  %ext.12869 = call ptr @kx_int_str(i64 %t.12867)
  %r.12870 = call ptr @kx_str_cat(ptr %r.12866, ptr %ext.12869)
  %r.12872 = call ptr @kx_str_cat(ptr %r.12870, ptr @.str.392)
  %t.12873 = load ptr, ptr %c.451
  %r.12875 = call ptr @kx_str_cat(ptr %r.12872, ptr %t.12873)
  %r.12877 = call ptr @kx_str_cat(ptr %r.12875, ptr @.str.100)
  %r.12878 = call i64 @Emit(i64 %t.12861, ptr %r.12877)
  br label %if.merge.12828
if.else.12829:
  %t.12879 = load i64, ptr %g.addr
  %t.12880 = load ptr, ptr %r.449
  %r.12882 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12880)
  %r.12884 = call ptr @kx_str_cat(ptr %r.12882, ptr @.str.461)
  %t.12885 = load i64, ptr %bv.445
  %ext.12887 = call ptr @kx_int_str(i64 %t.12885)
  %r.12888 = call ptr @kx_str_cat(ptr %r.12884, ptr %ext.12887)
  %r.12890 = call ptr @kx_str_cat(ptr %r.12888, ptr @.str.392)
  %t.12891 = load i64, ptr %g.addr
  %t.12892 = load ptr, ptr %a.448
  %r.12893 = call ptr @ToI64(i64 %t.12891, ptr %t.12892)
  %r.12895 = call ptr @kx_str_cat(ptr %r.12890, ptr %r.12893)
  %r.12897 = call ptr @kx_str_cat(ptr %r.12895, ptr @.str.100)
  %r.12898 = call i64 @Emit(i64 %t.12879, ptr %r.12897)
  br label %if.merge.12828
if.merge.12828:
  %t.12899 = load i64, ptr %arena.addr
  %t.12900 = load i64, ptr %e.addr
  %cast.12901 = sext i32 0 to i64
  %r.12902 = call i64 @Child(i64 %t.12899, i64 %t.12900, i64 %cast.12901)
  %baseNode.452 = alloca i64
  store i64 %r.12902, ptr %baseNode.452
  %t.12903 = load i64, ptr %base.426
  %ext.12905 = inttoptr i64 %t.12903 to ptr
  %r.12906 = call i1 @kx_str_eq(ptr %ext.12905, ptr @.str.92)
  %t.12907 = load i64, ptr %g.addr
  %r.12908 = call i64 @kx_struct_get(i64 %t.12907, i32 16)
  %t.12909 = load i64, ptr %base.426
  %r.12910 = call i1 @kx_map_has(i64 %r.12908, i64 %t.12909)
  %t.12911 = and i1 %r.12906, %r.12910
  br i1 %t.12911, label %if.then.12912, label %if.merge.12913
if.then.12912:
  %t.12914 = load i64, ptr %g.addr
  %r.12915 = call i64 @kx_struct_get(i64 %t.12914, i32 16)
  %t.12916 = load i64, ptr %base.426
  %r.12917 = call i64 @kx_list_get(i64 %r.12915, i64 %t.12916)
  %elemType.453 = alloca i64
  store i64 %r.12917, ptr %elemType.453
  %t.12918 = load i64, ptr %elemType.453
  %ext.12920 = inttoptr i64 %t.12918 to ptr
  %r.12921 = call i1 @kx_str_eq(ptr %ext.12920, ptr @.str.30)
  br i1 %r.12921, label %if.then.12922, label %if.merge.12923
if.then.12922:
  %t.12924 = load i64, ptr %g.addr
  %r.12925 = call i64 @kx_struct_get(i64 %t.12924, i32 4)
  %t.12926 = load i64, ptr %g.addr
  %r.12927 = call i64 @kx_struct_get(i64 %t.12926, i32 4)
  %ext.12929 = sext i32 0 to i64
  %r.12928 = call i64 @kx_list_get(i64 %r.12927, i64 %ext.12929)
  %ext.12930 = sext i32 1 to i64
  %t.12931 = add i64 %r.12928, %ext.12930
  %ext.12932 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12925, i64 %ext.12932, i64 %t.12931)
  %t.12933 = load i64, ptr %g.addr
  %r.12934 = call i64 @kx_struct_get(i64 %t.12933, i32 4)
  %ext.12936 = sext i32 0 to i64
  %r.12935 = call i64 @kx_list_get(i64 %r.12934, i64 %ext.12936)
  %r.12937 = call ptr @kx_int_str(i64 %r.12935)
  %r.12939 = call ptr @kx_str_cat(ptr @.str.462, ptr %r.12937)
  %p.454 = alloca ptr
  store ptr %r.12939, ptr %p.454
  %t.12940 = load i64, ptr %g.addr
  %t.12941 = load ptr, ptr %p.454
  %r.12943 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.12941)
  %r.12945 = call ptr @kx_str_cat(ptr %r.12943, ptr @.str.277)
  %t.12946 = load ptr, ptr %r.449
  %r.12948 = call ptr @kx_str_cat(ptr %r.12945, ptr %t.12946)
  %r.12950 = call ptr @kx_str_cat(ptr %r.12948, ptr @.str.278)
  %r.12951 = call i64 @Emit(i64 %t.12940, ptr %r.12950)
  %t.12952 = load ptr, ptr %p.454
  %r.12954 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.12952)
  ret ptr %r.12954
dead.12955:
  br label %if.merge.12923
if.merge.12923:
  br label %if.merge.12913
if.merge.12913:
  %t.12956 = load ptr, ptr %r.449
  %r.12958 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.12956)
  ret ptr %r.12958
dead.12959:
  br label %if.merge.12798
if.merge.12798:
  %t.12960 = load i64, ptr %m.427
  %ext.12962 = inttoptr i64 %t.12960 to ptr
  %r.12963 = call i1 @kx_str_eq(ptr %ext.12962, ptr @.str.311)
  br i1 %r.12963, label %if.then.12964, label %if.merge.12965
if.then.12964:
  %t.12966 = load i64, ptr %g.addr
  %t.12967 = load i64, ptr %arena.addr
  %t.12968 = load i64, ptr %e.addr
  %cast.12969 = sext i32 1 to i64
  %r.12970 = call i64 @Child(i64 %t.12967, i64 %t.12968, i64 %cast.12969)
  %t.12971 = load i64, ptr %arena.addr
  %r.12972 = call ptr @GenExpr(i64 %t.12966, i64 %r.12970, i64 %t.12971)
  %a1.455 = alloca ptr
  store ptr %r.12972, ptr %a1.455
  %t.12973 = load i64, ptr %g.addr
  %t.12974 = load i64, ptr %arena.addr
  %t.12975 = load i64, ptr %e.addr
  %cast.12976 = sext i32 2 to i64
  %r.12977 = call i64 @Child(i64 %t.12974, i64 %t.12975, i64 %cast.12976)
  %t.12978 = load i64, ptr %arena.addr
  %r.12979 = call ptr @GenExpr(i64 %t.12973, i64 %r.12977, i64 %t.12978)
  %a2.456 = alloca ptr
  store ptr %r.12979, ptr %a2.456
  %t.12980 = load ptr, ptr %a1.455
  %r.12981 = call i64 @XVal(ptr %t.12980)
  %k.457 = alloca i64
  store i64 %r.12981, ptr %k.457
  %t.12982 = load ptr, ptr %a2.456
  %r.12983 = call i64 @XVal(ptr %t.12982)
  %v.458 = alloca i64
  store i64 %r.12983, ptr %v.458
  %t.12984 = load ptr, ptr %a1.455
  %r.12985 = call i64 @XType(ptr %t.12984)
  %ext.12987 = inttoptr i64 %r.12985 to ptr
  %r.12988 = call i1 @kx_str_eq(ptr %ext.12987, ptr @.str.271)
  br i1 %r.12988, label %if.then.12989, label %if.else.12991
if.then.12989:
  %t.12992 = load i64, ptr %g.addr
  %r.12993 = call i64 @kx_struct_get(i64 %t.12992, i32 4)
  %t.12994 = load i64, ptr %g.addr
  %r.12995 = call i64 @kx_struct_get(i64 %t.12994, i32 4)
  %ext.12997 = sext i32 0 to i64
  %r.12996 = call i64 @kx_list_get(i64 %r.12995, i64 %ext.12997)
  %ext.12998 = sext i32 1 to i64
  %t.12999 = add i64 %r.12996, %ext.12998
  %ext.13000 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.12993, i64 %ext.13000, i64 %t.12999)
  %t.13001 = load i64, ptr %g.addr
  %r.13002 = call i64 @kx_struct_get(i64 %t.13001, i32 4)
  %ext.13004 = sext i32 0 to i64
  %r.13003 = call i64 @kx_list_get(i64 %r.13002, i64 %ext.13004)
  %r.13005 = call ptr @kx_int_str(i64 %r.13003)
  %r.13007 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.13005)
  %c.459 = alloca ptr
  store ptr %r.13007, ptr %c.459
  %t.13008 = load i64, ptr %g.addr
  %t.13009 = load ptr, ptr %c.459
  %r.13011 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13009)
  %r.13013 = call ptr @kx_str_cat(ptr %r.13011, ptr @.str.273)
  %t.13014 = load i64, ptr %k.457
  %ext.13016 = call ptr @kx_int_str(i64 %t.13014)
  %r.13017 = call ptr @kx_str_cat(ptr %r.13013, ptr %ext.13016)
  %r.13019 = call ptr @kx_str_cat(ptr %r.13017, ptr @.str.274)
  %r.13020 = call i64 @Emit(i64 %t.13008, ptr %r.13019)
  %t.13021 = load ptr, ptr %c.459
  %ptrtoint.13022 = ptrtoint ptr %t.13021 to i64
  store i64 %ptrtoint.13022, ptr %k.457
  %t.13023 = load ptr, ptr %a2.456
  %r.13024 = call i64 @XType(ptr %t.13023)
  %ext.13026 = inttoptr i64 %r.13024 to ptr
  %r.13027 = call i1 @kx_str_eq(ptr %ext.13026, ptr @.str.271)
  br i1 %r.13027, label %if.then.13028, label %if.merge.13029
if.then.13028:
  %t.13030 = load i64, ptr %g.addr
  %r.13031 = call i64 @kx_struct_get(i64 %t.13030, i32 4)
  %t.13032 = load i64, ptr %g.addr
  %r.13033 = call i64 @kx_struct_get(i64 %t.13032, i32 4)
  %ext.13035 = sext i32 0 to i64
  %r.13034 = call i64 @kx_list_get(i64 %r.13033, i64 %ext.13035)
  %ext.13036 = sext i32 1 to i64
  %t.13037 = add i64 %r.13034, %ext.13036
  %ext.13038 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13031, i64 %ext.13038, i64 %t.13037)
  %t.13039 = load i64, ptr %g.addr
  %r.13040 = call i64 @kx_struct_get(i64 %t.13039, i32 4)
  %ext.13042 = sext i32 0 to i64
  %r.13041 = call i64 @kx_list_get(i64 %r.13040, i64 %ext.13042)
  %r.13043 = call ptr @kx_int_str(i64 %r.13041)
  %r.13045 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.13043)
  %vc.460 = alloca ptr
  store ptr %r.13045, ptr %vc.460
  %t.13046 = load i64, ptr %g.addr
  %t.13047 = load ptr, ptr %vc.460
  %r.13049 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13047)
  %r.13051 = call ptr @kx_str_cat(ptr %r.13049, ptr @.str.273)
  %t.13052 = load i64, ptr %v.458
  %ext.13054 = call ptr @kx_int_str(i64 %t.13052)
  %r.13055 = call ptr @kx_str_cat(ptr %r.13051, ptr %ext.13054)
  %r.13057 = call ptr @kx_str_cat(ptr %r.13055, ptr @.str.274)
  %r.13058 = call i64 @Emit(i64 %t.13046, ptr %r.13057)
  %t.13059 = load ptr, ptr %vc.460
  %ptrtoint.13060 = ptrtoint ptr %t.13059 to i64
  store i64 %ptrtoint.13060, ptr %v.458
  br label %if.merge.13029
if.merge.13029:
  %t.13061 = load i64, ptr %g.addr
  %t.13062 = load i64, ptr %bv.445
  %ext.13064 = call ptr @kx_int_str(i64 %t.13062)
  %r.13065 = call ptr @kx_str_cat(ptr @.str.463, ptr %ext.13064)
  %r.13067 = call ptr @kx_str_cat(ptr %r.13065, ptr @.str.392)
  %t.13068 = load i64, ptr %k.457
  %ext.13070 = call ptr @kx_int_str(i64 %t.13068)
  %r.13071 = call ptr @kx_str_cat(ptr %r.13067, ptr %ext.13070)
  %r.13073 = call ptr @kx_str_cat(ptr %r.13071, ptr @.str.392)
  %t.13074 = load i64, ptr %v.458
  %ext.13076 = call ptr @kx_int_str(i64 %t.13074)
  %r.13077 = call ptr @kx_str_cat(ptr %r.13073, ptr %ext.13076)
  %r.13079 = call ptr @kx_str_cat(ptr %r.13077, ptr @.str.100)
  %r.13080 = call i64 @Emit(i64 %t.13061, ptr %r.13079)
  br label %if.merge.12990
if.else.12991:
  %t.13081 = load i64, ptr %g.addr
  %t.13082 = load i64, ptr %bv.445
  %ext.13084 = call ptr @kx_int_str(i64 %t.13082)
  %r.13085 = call ptr @kx_str_cat(ptr @.str.464, ptr %ext.13084)
  %r.13087 = call ptr @kx_str_cat(ptr %r.13085, ptr @.str.392)
  %t.13088 = load i64, ptr %g.addr
  %t.13089 = load ptr, ptr %a1.455
  %r.13090 = call ptr @ToI64(i64 %t.13088, ptr %t.13089)
  %r.13092 = call ptr @kx_str_cat(ptr %r.13087, ptr %r.13090)
  %r.13094 = call ptr @kx_str_cat(ptr %r.13092, ptr @.str.392)
  %t.13095 = load i64, ptr %g.addr
  %t.13096 = load ptr, ptr %a2.456
  %r.13097 = call ptr @ToI64(i64 %t.13095, ptr %t.13096)
  %r.13099 = call ptr @kx_str_cat(ptr %r.13094, ptr %r.13097)
  %r.13101 = call ptr @kx_str_cat(ptr %r.13099, ptr @.str.100)
  %r.13102 = call i64 @Emit(i64 %t.13081, ptr %r.13101)
  br label %if.merge.12990
if.merge.12990:
  ret ptr @.str.445
dead.13103:
  br label %if.merge.12965
if.merge.12965:
  %t.13104 = load i64, ptr %m.427
  %ext.13106 = inttoptr i64 %t.13104 to ptr
  %r.13107 = call i1 @kx_str_eq(ptr %ext.13106, ptr @.str.310)
  br i1 %r.13107, label %if.then.13108, label %if.merge.13109
if.then.13108:
  %t.13110 = load i64, ptr %g.addr
  %t.13111 = load i64, ptr %arena.addr
  %t.13112 = load i64, ptr %e.addr
  %cast.13113 = sext i32 1 to i64
  %r.13114 = call i64 @Child(i64 %t.13111, i64 %t.13112, i64 %cast.13113)
  %t.13115 = load i64, ptr %arena.addr
  %r.13116 = call ptr @GenExpr(i64 %t.13110, i64 %r.13114, i64 %t.13115)
  %a.461 = alloca ptr
  store ptr %r.13116, ptr %a.461
  %t.13117 = load ptr, ptr %a.461
  %r.13118 = call i64 @XVal(ptr %t.13117)
  %k.462 = alloca i64
  store i64 %r.13118, ptr %k.462
  %t.13119 = load ptr, ptr %a.461
  %r.13120 = call i64 @XType(ptr %t.13119)
  %ext.13122 = inttoptr i64 %r.13120 to ptr
  %r.13123 = call i1 @kx_str_eq(ptr %ext.13122, ptr @.str.271)
  br i1 %r.13123, label %if.then.13124, label %if.merge.13125
if.then.13124:
  %t.13126 = load i64, ptr %g.addr
  %r.13127 = call i64 @kx_struct_get(i64 %t.13126, i32 4)
  %t.13128 = load i64, ptr %g.addr
  %r.13129 = call i64 @kx_struct_get(i64 %t.13128, i32 4)
  %ext.13131 = sext i32 0 to i64
  %r.13130 = call i64 @kx_list_get(i64 %r.13129, i64 %ext.13131)
  %ext.13132 = sext i32 1 to i64
  %t.13133 = add i64 %r.13130, %ext.13132
  %ext.13134 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13127, i64 %ext.13134, i64 %t.13133)
  %t.13135 = load i64, ptr %g.addr
  %r.13136 = call i64 @kx_struct_get(i64 %t.13135, i32 4)
  %ext.13138 = sext i32 0 to i64
  %r.13137 = call i64 @kx_list_get(i64 %r.13136, i64 %ext.13138)
  %r.13139 = call ptr @kx_int_str(i64 %r.13137)
  %r.13141 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.13139)
  %c.463 = alloca ptr
  store ptr %r.13141, ptr %c.463
  %t.13142 = load i64, ptr %g.addr
  %t.13143 = load ptr, ptr %c.463
  %r.13145 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13143)
  %r.13147 = call ptr @kx_str_cat(ptr %r.13145, ptr @.str.273)
  %t.13148 = load i64, ptr %k.462
  %ext.13150 = call ptr @kx_int_str(i64 %t.13148)
  %r.13151 = call ptr @kx_str_cat(ptr %r.13147, ptr %ext.13150)
  %r.13153 = call ptr @kx_str_cat(ptr %r.13151, ptr @.str.274)
  %r.13154 = call i64 @Emit(i64 %t.13142, ptr %r.13153)
  %t.13155 = load ptr, ptr %c.463
  %ptrtoint.13156 = ptrtoint ptr %t.13155 to i64
  store i64 %ptrtoint.13156, ptr %k.462
  br label %if.merge.13125
if.merge.13125:
  %t.13157 = load i64, ptr %g.addr
  %r.13158 = call i64 @kx_struct_get(i64 %t.13157, i32 4)
  %t.13159 = load i64, ptr %g.addr
  %r.13160 = call i64 @kx_struct_get(i64 %t.13159, i32 4)
  %ext.13162 = sext i32 0 to i64
  %r.13161 = call i64 @kx_list_get(i64 %r.13160, i64 %ext.13162)
  %ext.13163 = sext i32 1 to i64
  %t.13164 = add i64 %r.13161, %ext.13163
  %ext.13165 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13158, i64 %ext.13165, i64 %t.13164)
  %t.13166 = load i64, ptr %g.addr
  %r.13167 = call i64 @kx_struct_get(i64 %t.13166, i32 4)
  %ext.13169 = sext i32 0 to i64
  %r.13168 = call i64 @kx_list_get(i64 %r.13167, i64 %ext.13169)
  %r.13170 = call ptr @kx_int_str(i64 %r.13168)
  %r.13172 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13170)
  %r.464 = alloca ptr
  store ptr %r.13172, ptr %r.464
  %t.13173 = load i64, ptr %g.addr
  %t.13174 = load ptr, ptr %r.464
  %r.13176 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13174)
  %r.13178 = call ptr @kx_str_cat(ptr %r.13176, ptr @.str.460)
  %t.13179 = load i64, ptr %bv.445
  %ext.13181 = call ptr @kx_int_str(i64 %t.13179)
  %r.13182 = call ptr @kx_str_cat(ptr %r.13178, ptr %ext.13181)
  %r.13184 = call ptr @kx_str_cat(ptr %r.13182, ptr @.str.392)
  %t.13185 = load i64, ptr %k.462
  %ext.13187 = call ptr @kx_int_str(i64 %t.13185)
  %r.13188 = call ptr @kx_str_cat(ptr %r.13184, ptr %ext.13187)
  %r.13190 = call ptr @kx_str_cat(ptr %r.13188, ptr @.str.100)
  %r.13191 = call i64 @Emit(i64 %t.13173, ptr %r.13190)
  %t.13192 = load ptr, ptr %r.464
  %r.13194 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.13192)
  ret ptr %r.13194
dead.13195:
  br label %if.merge.13109
if.merge.13109:
  %t.13196 = load i64, ptr %m.427
  %ext.13198 = inttoptr i64 %t.13196 to ptr
  %r.13199 = call i1 @kx_str_eq(ptr %ext.13198, ptr @.str.313)
  br i1 %r.13199, label %if.then.13200, label %if.merge.13201
if.then.13200:
  %t.13202 = load i64, ptr %g.addr
  %t.13203 = load i64, ptr %arena.addr
  %t.13204 = load i64, ptr %e.addr
  %cast.13205 = sext i32 1 to i64
  %r.13206 = call i64 @Child(i64 %t.13203, i64 %t.13204, i64 %cast.13205)
  %t.13207 = load i64, ptr %arena.addr
  %r.13208 = call ptr @GenExpr(i64 %t.13202, i64 %r.13206, i64 %t.13207)
  %a.465 = alloca ptr
  store ptr %r.13208, ptr %a.465
  %t.13209 = load ptr, ptr %a.465
  %r.13210 = call i64 @XVal(ptr %t.13209)
  %k.466 = alloca i64
  store i64 %r.13210, ptr %k.466
  %t.13211 = load ptr, ptr %a.465
  %r.13212 = call i64 @XType(ptr %t.13211)
  %ext.13214 = inttoptr i64 %r.13212 to ptr
  %r.13215 = call i1 @kx_str_eq(ptr %ext.13214, ptr @.str.271)
  br i1 %r.13215, label %if.then.13216, label %if.merge.13217
if.then.13216:
  %t.13218 = load i64, ptr %g.addr
  %r.13219 = call i64 @kx_struct_get(i64 %t.13218, i32 4)
  %t.13220 = load i64, ptr %g.addr
  %r.13221 = call i64 @kx_struct_get(i64 %t.13220, i32 4)
  %ext.13223 = sext i32 0 to i64
  %r.13222 = call i64 @kx_list_get(i64 %r.13221, i64 %ext.13223)
  %ext.13224 = sext i32 1 to i64
  %t.13225 = add i64 %r.13222, %ext.13224
  %ext.13226 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13219, i64 %ext.13226, i64 %t.13225)
  %t.13227 = load i64, ptr %g.addr
  %r.13228 = call i64 @kx_struct_get(i64 %t.13227, i32 4)
  %ext.13230 = sext i32 0 to i64
  %r.13229 = call i64 @kx_list_get(i64 %r.13228, i64 %ext.13230)
  %r.13231 = call ptr @kx_int_str(i64 %r.13229)
  %r.13233 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.13231)
  %c.467 = alloca ptr
  store ptr %r.13233, ptr %c.467
  %t.13234 = load i64, ptr %g.addr
  %t.13235 = load ptr, ptr %c.467
  %r.13237 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13235)
  %r.13239 = call ptr @kx_str_cat(ptr %r.13237, ptr @.str.273)
  %t.13240 = load i64, ptr %k.466
  %ext.13242 = call ptr @kx_int_str(i64 %t.13240)
  %r.13243 = call ptr @kx_str_cat(ptr %r.13239, ptr %ext.13242)
  %r.13245 = call ptr @kx_str_cat(ptr %r.13243, ptr @.str.274)
  %r.13246 = call i64 @Emit(i64 %t.13234, ptr %r.13245)
  %t.13247 = load ptr, ptr %c.467
  %ptrtoint.13248 = ptrtoint ptr %t.13247 to i64
  store i64 %ptrtoint.13248, ptr %k.466
  br label %if.merge.13217
if.merge.13217:
  %t.13249 = load i64, ptr %g.addr
  %r.13250 = call i64 @kx_struct_get(i64 %t.13249, i32 4)
  %t.13251 = load i64, ptr %g.addr
  %r.13252 = call i64 @kx_struct_get(i64 %t.13251, i32 4)
  %ext.13254 = sext i32 0 to i64
  %r.13253 = call i64 @kx_list_get(i64 %r.13252, i64 %ext.13254)
  %ext.13255 = sext i32 1 to i64
  %t.13256 = add i64 %r.13253, %ext.13255
  %ext.13257 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13250, i64 %ext.13257, i64 %t.13256)
  %t.13258 = load i64, ptr %g.addr
  %r.13259 = call i64 @kx_struct_get(i64 %t.13258, i32 4)
  %ext.13261 = sext i32 0 to i64
  %r.13260 = call i64 @kx_list_get(i64 %r.13259, i64 %ext.13261)
  %r.13262 = call ptr @kx_int_str(i64 %r.13260)
  %r.13264 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13262)
  %r.468 = alloca ptr
  store ptr %r.13264, ptr %r.468
  %t.13265 = load i64, ptr %g.addr
  %t.13266 = load ptr, ptr %r.468
  %r.13268 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13266)
  %r.13270 = call ptr @kx_str_cat(ptr %r.13268, ptr @.str.465)
  %t.13271 = load i64, ptr %bv.445
  %ext.13273 = call ptr @kx_int_str(i64 %t.13271)
  %r.13274 = call ptr @kx_str_cat(ptr %r.13270, ptr %ext.13273)
  %r.13276 = call ptr @kx_str_cat(ptr %r.13274, ptr @.str.392)
  %t.13277 = load i64, ptr %k.466
  %ext.13279 = call ptr @kx_int_str(i64 %t.13277)
  %r.13280 = call ptr @kx_str_cat(ptr %r.13276, ptr %ext.13279)
  %r.13282 = call ptr @kx_str_cat(ptr %r.13280, ptr @.str.100)
  %r.13283 = call i64 @Emit(i64 %t.13265, ptr %r.13282)
  %t.13284 = load ptr, ptr %r.468
  %r.13286 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.13284)
  ret ptr %r.13286
dead.13287:
  br label %if.merge.13201
if.merge.13201:
  %t.13288 = load i64, ptr %m.427
  %ext.13290 = inttoptr i64 %t.13288 to ptr
  %r.13291 = call i1 @kx_str_eq(ptr %ext.13290, ptr @.str.466)
  br i1 %r.13291, label %if.then.13292, label %if.merge.13293
if.then.13292:
  %t.13294 = load i64, ptr %g.addr
  %t.13295 = load i64, ptr %arena.addr
  %t.13296 = load i64, ptr %e.addr
  %cast.13297 = sext i32 1 to i64
  %r.13298 = call i64 @Child(i64 %t.13295, i64 %t.13296, i64 %cast.13297)
  %t.13299 = load i64, ptr %arena.addr
  %r.13300 = call ptr @GenExpr(i64 %t.13294, i64 %r.13298, i64 %t.13299)
  %a.469 = alloca ptr
  store ptr %r.13300, ptr %a.469
  %t.13301 = load ptr, ptr %a.469
  %r.13302 = call i64 @XVal(ptr %t.13301)
  %k.470 = alloca i64
  store i64 %r.13302, ptr %k.470
  %t.13303 = load ptr, ptr %a.469
  %r.13304 = call i64 @XType(ptr %t.13303)
  %ext.13306 = inttoptr i64 %r.13304 to ptr
  %r.13307 = call i1 @kx_str_eq(ptr %ext.13306, ptr @.str.271)
  br i1 %r.13307, label %if.then.13308, label %if.merge.13309
if.then.13308:
  %t.13310 = load i64, ptr %g.addr
  %r.13311 = call i64 @kx_struct_get(i64 %t.13310, i32 4)
  %t.13312 = load i64, ptr %g.addr
  %r.13313 = call i64 @kx_struct_get(i64 %t.13312, i32 4)
  %ext.13315 = sext i32 0 to i64
  %r.13314 = call i64 @kx_list_get(i64 %r.13313, i64 %ext.13315)
  %ext.13316 = sext i32 1 to i64
  %t.13317 = add i64 %r.13314, %ext.13316
  %ext.13318 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13311, i64 %ext.13318, i64 %t.13317)
  %t.13319 = load i64, ptr %g.addr
  %r.13320 = call i64 @kx_struct_get(i64 %t.13319, i32 4)
  %ext.13322 = sext i32 0 to i64
  %r.13321 = call i64 @kx_list_get(i64 %r.13320, i64 %ext.13322)
  %r.13323 = call ptr @kx_int_str(i64 %r.13321)
  %r.13325 = call ptr @kx_str_cat(ptr @.str.459, ptr %r.13323)
  %c.471 = alloca ptr
  store ptr %r.13325, ptr %c.471
  %t.13326 = load i64, ptr %g.addr
  %t.13327 = load ptr, ptr %c.471
  %r.13329 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13327)
  %r.13331 = call ptr @kx_str_cat(ptr %r.13329, ptr @.str.273)
  %t.13332 = load i64, ptr %k.470
  %ext.13334 = call ptr @kx_int_str(i64 %t.13332)
  %r.13335 = call ptr @kx_str_cat(ptr %r.13331, ptr %ext.13334)
  %r.13337 = call ptr @kx_str_cat(ptr %r.13335, ptr @.str.274)
  %r.13338 = call i64 @Emit(i64 %t.13326, ptr %r.13337)
  %t.13339 = load ptr, ptr %c.471
  %ptrtoint.13340 = ptrtoint ptr %t.13339 to i64
  store i64 %ptrtoint.13340, ptr %k.470
  br label %if.merge.13309
if.merge.13309:
  %t.13341 = load i64, ptr %g.addr
  %t.13342 = load i64, ptr %bv.445
  %ext.13344 = call ptr @kx_int_str(i64 %t.13342)
  %r.13345 = call ptr @kx_str_cat(ptr @.str.467, ptr %ext.13344)
  %r.13347 = call ptr @kx_str_cat(ptr %r.13345, ptr @.str.392)
  %t.13348 = load i64, ptr %k.470
  %ext.13350 = call ptr @kx_int_str(i64 %t.13348)
  %r.13351 = call ptr @kx_str_cat(ptr %r.13347, ptr %ext.13350)
  %r.13353 = call ptr @kx_str_cat(ptr %r.13351, ptr @.str.100)
  %r.13354 = call i64 @Emit(i64 %t.13341, ptr %r.13353)
  ret ptr @.str.445
dead.13355:
  br label %if.merge.13293
if.merge.13293:
  %t.13356 = load i64, ptr %m.427
  %ext.13358 = inttoptr i64 %t.13356 to ptr
  %r.13359 = call i1 @kx_str_eq(ptr %ext.13358, ptr @.str.468)
  br i1 %r.13359, label %if.then.13360, label %if.merge.13361
if.then.13360:
  %t.13362 = load i64, ptr %g.addr
  %t.13363 = load i64, ptr %arena.addr
  %t.13364 = load i64, ptr %e.addr
  %cast.13365 = sext i32 1 to i64
  %r.13366 = call i64 @Child(i64 %t.13363, i64 %t.13364, i64 %cast.13365)
  %t.13367 = load i64, ptr %arena.addr
  %r.13368 = call ptr @GenExpr(i64 %t.13362, i64 %r.13366, i64 %t.13367)
  %a.472 = alloca ptr
  store ptr %r.13368, ptr %a.472
  %t.13369 = load i64, ptr %g.addr
  %t.13370 = load i64, ptr %bv.445
  %ext.13372 = call ptr @kx_int_str(i64 %t.13370)
  %r.13373 = call ptr @kx_str_cat(ptr @.str.469, ptr %ext.13372)
  %r.13375 = call ptr @kx_str_cat(ptr %r.13373, ptr @.str.392)
  %t.13376 = load i64, ptr %g.addr
  %t.13377 = load ptr, ptr %a.472
  %r.13378 = call ptr @ToI64(i64 %t.13376, ptr %t.13377)
  %r.13380 = call ptr @kx_str_cat(ptr %r.13375, ptr %r.13378)
  %r.13382 = call ptr @kx_str_cat(ptr %r.13380, ptr @.str.100)
  %r.13383 = call i64 @Emit(i64 %t.13369, ptr %r.13382)
  ret ptr @.str.445
dead.13384:
  br label %if.merge.13361
if.merge.13361:
  %t.13385 = load i64, ptr %m.427
  %ext.13387 = inttoptr i64 %t.13385 to ptr
  %r.13388 = call i1 @kx_str_eq(ptr %ext.13387, ptr @.str.470)
  br i1 %r.13388, label %if.then.13389, label %if.merge.13390
if.then.13389:
  %t.13391 = load i64, ptr %g.addr
  %t.13392 = load i64, ptr %bv.445
  %ext.13394 = call ptr @kx_int_str(i64 %t.13392)
  %r.13395 = call ptr @kx_str_cat(ptr @.str.471, ptr %ext.13394)
  %r.13397 = call ptr @kx_str_cat(ptr %r.13395, ptr @.str.100)
  %r.13398 = call i64 @Emit(i64 %t.13391, ptr %r.13397)
  ret ptr @.str.445
dead.13399:
  br label %if.merge.13390
if.merge.13390:
  %t.13400 = load i64, ptr %m.427
  %ext.13402 = inttoptr i64 %t.13400 to ptr
  %r.13403 = call i1 @kx_str_eq(ptr %ext.13402, ptr @.str.293)
  br i1 %r.13403, label %if.then.13404, label %if.merge.13405
if.then.13404:
  %t.13406 = load i64, ptr %g.addr
  %r.13407 = call i64 @kx_struct_get(i64 %t.13406, i32 4)
  %t.13408 = load i64, ptr %g.addr
  %r.13409 = call i64 @kx_struct_get(i64 %t.13408, i32 4)
  %ext.13411 = sext i32 0 to i64
  %r.13410 = call i64 @kx_list_get(i64 %r.13409, i64 %ext.13411)
  %ext.13412 = sext i32 1 to i64
  %t.13413 = add i64 %r.13410, %ext.13412
  %ext.13414 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13407, i64 %ext.13414, i64 %t.13413)
  %t.13415 = load i64, ptr %g.addr
  %r.13416 = call i64 @kx_struct_get(i64 %t.13415, i32 4)
  %ext.13418 = sext i32 0 to i64
  %r.13417 = call i64 @kx_list_get(i64 %r.13416, i64 %ext.13418)
  %r.13419 = call ptr @kx_int_str(i64 %r.13417)
  %r.13421 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13419)
  %r.473 = alloca ptr
  store ptr %r.13421, ptr %r.473
  %t.13422 = load i64, ptr %g.addr
  %t.13423 = load ptr, ptr %r.473
  %r.13425 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13423)
  %r.13427 = call ptr @kx_str_cat(ptr %r.13425, ptr @.str.441)
  %t.13428 = load i64, ptr %bv.445
  %ext.13430 = call ptr @kx_int_str(i64 %t.13428)
  %r.13431 = call ptr @kx_str_cat(ptr %r.13427, ptr %ext.13430)
  %r.13433 = call ptr @kx_str_cat(ptr %r.13431, ptr @.str.100)
  %r.13434 = call i64 @Emit(i64 %t.13422, ptr %r.13433)
  %t.13435 = load ptr, ptr %r.473
  %r.13437 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.13435)
  ret ptr %r.13437
dead.13438:
  br label %if.merge.13405
if.merge.13405:
  %t.13439 = load i64, ptr %m.427
  %ext.13441 = inttoptr i64 %t.13439 to ptr
  %r.13442 = call i1 @kx_str_eq(ptr %ext.13441, ptr @.str.294)
  br i1 %r.13442, label %if.then.13443, label %if.merge.13444
if.then.13443:
  %t.13445 = load i64, ptr %g.addr
  %t.13446 = load i64, ptr %arena.addr
  %t.13447 = load i64, ptr %e.addr
  %cast.13448 = sext i32 1 to i64
  %r.13449 = call i64 @Child(i64 %t.13446, i64 %t.13447, i64 %cast.13448)
  %t.13450 = load i64, ptr %arena.addr
  %r.13451 = call ptr @GenExpr(i64 %t.13445, i64 %r.13449, i64 %t.13450)
  %a1.474 = alloca ptr
  store ptr %r.13451, ptr %a1.474
  %t.13452 = load i64, ptr %bv.445
  %bv2.475 = alloca i64
  store i64 %t.13452, ptr %bv2.475
  %t.13453 = load i64, ptr %bt.446
  %ext.13455 = inttoptr i64 %t.13453 to ptr
  %r.13456 = call i1 @kx_str_eq(ptr %ext.13455, ptr @.str.269)
  br i1 %r.13456, label %if.then.13457, label %if.merge.13458
if.then.13457:
  %t.13459 = load i64, ptr %g.addr
  %r.13460 = call i64 @kx_struct_get(i64 %t.13459, i32 4)
  %t.13461 = load i64, ptr %g.addr
  %r.13462 = call i64 @kx_struct_get(i64 %t.13461, i32 4)
  %ext.13464 = sext i32 0 to i64
  %r.13463 = call i64 @kx_list_get(i64 %r.13462, i64 %ext.13464)
  %ext.13465 = sext i32 1 to i64
  %t.13466 = add i64 %r.13463, %ext.13465
  %ext.13467 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13460, i64 %ext.13467, i64 %t.13466)
  %t.13468 = load i64, ptr %g.addr
  %r.13469 = call i64 @kx_struct_get(i64 %t.13468, i32 4)
  %ext.13471 = sext i32 0 to i64
  %r.13470 = call i64 @kx_list_get(i64 %r.13469, i64 %ext.13471)
  %r.13472 = call ptr @kx_int_str(i64 %r.13470)
  %r.13474 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13472)
  %ext.476 = alloca ptr
  store ptr %r.13474, ptr %ext.476
  %t.13475 = load i64, ptr %g.addr
  %t.13476 = load ptr, ptr %ext.476
  %r.13478 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13476)
  %r.13480 = call ptr @kx_str_cat(ptr %r.13478, ptr @.str.277)
  %t.13481 = load i64, ptr %bv.445
  %ext.13483 = call ptr @kx_int_str(i64 %t.13481)
  %r.13484 = call ptr @kx_str_cat(ptr %r.13480, ptr %ext.13483)
  %r.13486 = call ptr @kx_str_cat(ptr %r.13484, ptr @.str.278)
  %r.13487 = call i64 @Emit(i64 %t.13475, ptr %r.13486)
  %t.13488 = load ptr, ptr %ext.476
  %ptrtoint.13489 = ptrtoint ptr %t.13488 to i64
  store i64 %ptrtoint.13489, ptr %bv2.475
  br label %if.merge.13458
if.merge.13458:
  %t.13490 = load ptr, ptr %a1.474
  %r.13491 = call i64 @XVal(ptr %t.13490)
  %a1v.477 = alloca i64
  store i64 %r.13491, ptr %a1v.477
  %t.13492 = load ptr, ptr %a1.474
  %r.13493 = call i64 @XType(ptr %t.13492)
  %ext.13495 = inttoptr i64 %r.13493 to ptr
  %r.13496 = call i1 @kx_str_eq(ptr %ext.13495, ptr @.str.279)
  br i1 %r.13496, label %if.then.13497, label %if.merge.13498
if.then.13497:
  %t.13499 = load i64, ptr %g.addr
  %r.13500 = call i64 @kx_struct_get(i64 %t.13499, i32 4)
  %t.13501 = load i64, ptr %g.addr
  %r.13502 = call i64 @kx_struct_get(i64 %t.13501, i32 4)
  %ext.13504 = sext i32 0 to i64
  %r.13503 = call i64 @kx_list_get(i64 %r.13502, i64 %ext.13504)
  %ext.13505 = sext i32 1 to i64
  %t.13506 = add i64 %r.13503, %ext.13505
  %ext.13507 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13500, i64 %ext.13507, i64 %t.13506)
  %t.13508 = load i64, ptr %g.addr
  %r.13509 = call i64 @kx_struct_get(i64 %t.13508, i32 4)
  %ext.13511 = sext i32 0 to i64
  %r.13510 = call i64 @kx_list_get(i64 %r.13509, i64 %ext.13511)
  %r.13512 = call ptr @kx_int_str(i64 %r.13510)
  %r.13514 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13512)
  %ext.478 = alloca ptr
  store ptr %r.13514, ptr %ext.478
  %t.13515 = load i64, ptr %g.addr
  %t.13516 = load ptr, ptr %ext.478
  %r.13518 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13516)
  %r.13520 = call ptr @kx_str_cat(ptr %r.13518, ptr @.str.275)
  %t.13521 = load i64, ptr %a1v.477
  %ext.13523 = call ptr @kx_int_str(i64 %t.13521)
  %r.13524 = call ptr @kx_str_cat(ptr %r.13520, ptr %ext.13523)
  %r.13526 = call ptr @kx_str_cat(ptr %r.13524, ptr @.str.274)
  %r.13527 = call i64 @Emit(i64 %t.13515, ptr %r.13526)
  %t.13528 = load ptr, ptr %ext.478
  %ptrtoint.13529 = ptrtoint ptr %t.13528 to i64
  store i64 %ptrtoint.13529, ptr %a1v.477
  br label %if.merge.13498
if.merge.13498:
  %a2v.479 = alloca ptr
  store ptr @.str.12, ptr %a2v.479
  %t.13530 = load i64, ptr %e.addr
  %r.13531 = call i64 @kx_struct_get(i64 %t.13530, i32 4)
  %r.13532 = call i64 @kx_list_size(i64 %r.13531)
  %ext.13533 = sext i32 2 to i64
  %t.13534 = icmp sgt i64 %r.13532, %ext.13533
  br i1 %t.13534, label %if.then.13535, label %if.else.13537
if.then.13535:
  %t.13538 = load i64, ptr %g.addr
  %t.13539 = load i64, ptr %arena.addr
  %t.13540 = load i64, ptr %e.addr
  %cast.13541 = sext i32 2 to i64
  %r.13542 = call i64 @Child(i64 %t.13539, i64 %t.13540, i64 %cast.13541)
  %t.13543 = load i64, ptr %arena.addr
  %r.13544 = call ptr @GenExpr(i64 %t.13538, i64 %r.13542, i64 %t.13543)
  %a2.480 = alloca ptr
  store ptr %r.13544, ptr %a2.480
  %t.13545 = load ptr, ptr %a2.480
  %r.13546 = call i64 @XVal(ptr %t.13545)
  %inttoptr.13547 = inttoptr i64 %r.13546 to ptr
  store ptr %inttoptr.13547, ptr %a2v.479
  %t.13548 = load ptr, ptr %a2.480
  %r.13549 = call i64 @XType(ptr %t.13548)
  %ext.13551 = inttoptr i64 %r.13549 to ptr
  %r.13552 = call i1 @kx_str_eq(ptr %ext.13551, ptr @.str.279)
  br i1 %r.13552, label %if.then.13553, label %if.merge.13554
if.then.13553:
  %t.13555 = load i64, ptr %g.addr
  %r.13556 = call i64 @kx_struct_get(i64 %t.13555, i32 4)
  %t.13557 = load i64, ptr %g.addr
  %r.13558 = call i64 @kx_struct_get(i64 %t.13557, i32 4)
  %ext.13560 = sext i32 0 to i64
  %r.13559 = call i64 @kx_list_get(i64 %r.13558, i64 %ext.13560)
  %ext.13561 = sext i32 1 to i64
  %t.13562 = add i64 %r.13559, %ext.13561
  %ext.13563 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13556, i64 %ext.13563, i64 %t.13562)
  %t.13564 = load i64, ptr %g.addr
  %r.13565 = call i64 @kx_struct_get(i64 %t.13564, i32 4)
  %ext.13567 = sext i32 0 to i64
  %r.13566 = call i64 @kx_list_get(i64 %r.13565, i64 %ext.13567)
  %r.13568 = call ptr @kx_int_str(i64 %r.13566)
  %r.13570 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13568)
  %ext.481 = alloca ptr
  store ptr %r.13570, ptr %ext.481
  %t.13571 = load i64, ptr %g.addr
  %t.13572 = load ptr, ptr %ext.481
  %r.13574 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13572)
  %r.13576 = call ptr @kx_str_cat(ptr %r.13574, ptr @.str.275)
  %t.13577 = load ptr, ptr %a2v.479
  %r.13579 = call ptr @kx_str_cat(ptr %r.13576, ptr %t.13577)
  %r.13581 = call ptr @kx_str_cat(ptr %r.13579, ptr @.str.274)
  %r.13582 = call i64 @Emit(i64 %t.13571, ptr %r.13581)
  %t.13583 = load ptr, ptr %ext.481
  store ptr %t.13583, ptr %a2v.479
  br label %if.merge.13554
if.merge.13554:
  br label %if.merge.13536
if.else.13537:
  %t.13584 = load i64, ptr %g.addr
  %r.13585 = call i64 @kx_struct_get(i64 %t.13584, i32 4)
  %t.13586 = load i64, ptr %g.addr
  %r.13587 = call i64 @kx_struct_get(i64 %t.13586, i32 4)
  %ext.13589 = sext i32 0 to i64
  %r.13588 = call i64 @kx_list_get(i64 %r.13587, i64 %ext.13589)
  %ext.13590 = sext i32 1 to i64
  %t.13591 = add i64 %r.13588, %ext.13590
  %ext.13592 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13585, i64 %ext.13592, i64 %t.13591)
  %t.13593 = load i64, ptr %g.addr
  %r.13594 = call i64 @kx_struct_get(i64 %t.13593, i32 4)
  %ext.13596 = sext i32 0 to i64
  %r.13595 = call i64 @kx_list_get(i64 %r.13594, i64 %ext.13596)
  %r.13597 = call ptr @kx_int_str(i64 %r.13595)
  %r.13599 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13597)
  %lenr.482 = alloca ptr
  store ptr %r.13599, ptr %lenr.482
  %t.13600 = load i64, ptr %g.addr
  %t.13601 = load ptr, ptr %lenr.482
  %r.13603 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13601)
  %r.13605 = call ptr @kx_str_cat(ptr %r.13603, ptr @.str.441)
  %t.13606 = load i64, ptr %bv2.475
  %ext.13608 = call ptr @kx_int_str(i64 %t.13606)
  %r.13609 = call ptr @kx_str_cat(ptr %r.13605, ptr %ext.13608)
  %r.13611 = call ptr @kx_str_cat(ptr %r.13609, ptr @.str.100)
  %r.13612 = call i64 @Emit(i64 %t.13600, ptr %r.13611)
  %t.13613 = load i64, ptr %g.addr
  %r.13614 = call i64 @kx_struct_get(i64 %t.13613, i32 4)
  %t.13615 = load i64, ptr %g.addr
  %r.13616 = call i64 @kx_struct_get(i64 %t.13615, i32 4)
  %ext.13618 = sext i32 0 to i64
  %r.13617 = call i64 @kx_list_get(i64 %r.13616, i64 %ext.13618)
  %ext.13619 = sext i32 1 to i64
  %t.13620 = add i64 %r.13617, %ext.13619
  %ext.13621 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13614, i64 %ext.13621, i64 %t.13620)
  %t.13622 = load i64, ptr %g.addr
  %r.13623 = call i64 @kx_struct_get(i64 %t.13622, i32 4)
  %ext.13625 = sext i32 0 to i64
  %r.13624 = call i64 @kx_list_get(i64 %r.13623, i64 %ext.13625)
  %r.13626 = call ptr @kx_int_str(i64 %r.13624)
  %r.13628 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13626)
  %subr.483 = alloca ptr
  store ptr %r.13628, ptr %subr.483
  %t.13629 = load i64, ptr %g.addr
  %t.13630 = load ptr, ptr %subr.483
  %r.13632 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13630)
  %r.13634 = call ptr @kx_str_cat(ptr %r.13632, ptr @.str.472)
  %t.13635 = load i64, ptr %bv2.475
  %ext.13637 = call ptr @kx_int_str(i64 %t.13635)
  %r.13638 = call ptr @kx_str_cat(ptr %r.13634, ptr %ext.13637)
  %r.13640 = call ptr @kx_str_cat(ptr %r.13638, ptr @.str.392)
  %t.13641 = load i64, ptr %a1v.477
  %ext.13643 = call ptr @kx_int_str(i64 %t.13641)
  %r.13644 = call ptr @kx_str_cat(ptr %r.13640, ptr %ext.13643)
  %r.13646 = call ptr @kx_str_cat(ptr %r.13644, ptr @.str.392)
  %t.13647 = load ptr, ptr %lenr.482
  %r.13649 = call ptr @kx_str_cat(ptr %r.13646, ptr %t.13647)
  %r.13651 = call ptr @kx_str_cat(ptr %r.13649, ptr @.str.100)
  %r.13652 = call i64 @Emit(i64 %t.13629, ptr %r.13651)
  %t.13653 = load ptr, ptr %subr.483
  %r.13655 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.13653)
  ret ptr %r.13655
dead.13656:
  br label %if.merge.13536
if.merge.13536:
  %t.13657 = load i64, ptr %g.addr
  %r.13658 = call i64 @kx_struct_get(i64 %t.13657, i32 4)
  %t.13659 = load i64, ptr %g.addr
  %r.13660 = call i64 @kx_struct_get(i64 %t.13659, i32 4)
  %ext.13662 = sext i32 0 to i64
  %r.13661 = call i64 @kx_list_get(i64 %r.13660, i64 %ext.13662)
  %ext.13663 = sext i32 1 to i64
  %t.13664 = add i64 %r.13661, %ext.13663
  %ext.13665 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13658, i64 %ext.13665, i64 %t.13664)
  %t.13666 = load i64, ptr %g.addr
  %r.13667 = call i64 @kx_struct_get(i64 %t.13666, i32 4)
  %ext.13669 = sext i32 0 to i64
  %r.13668 = call i64 @kx_list_get(i64 %r.13667, i64 %ext.13669)
  %r.13670 = call ptr @kx_int_str(i64 %r.13668)
  %r.13672 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13670)
  %r.484 = alloca ptr
  store ptr %r.13672, ptr %r.484
  %t.13673 = load i64, ptr %g.addr
  %t.13674 = load ptr, ptr %r.484
  %r.13676 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13674)
  %r.13678 = call ptr @kx_str_cat(ptr %r.13676, ptr @.str.472)
  %t.13679 = load i64, ptr %bv2.475
  %ext.13681 = call ptr @kx_int_str(i64 %t.13679)
  %r.13682 = call ptr @kx_str_cat(ptr %r.13678, ptr %ext.13681)
  %r.13684 = call ptr @kx_str_cat(ptr %r.13682, ptr @.str.392)
  %t.13685 = load i64, ptr %a1v.477
  %ext.13687 = call ptr @kx_int_str(i64 %t.13685)
  %r.13688 = call ptr @kx_str_cat(ptr %r.13684, ptr %ext.13687)
  %r.13690 = call ptr @kx_str_cat(ptr %r.13688, ptr @.str.392)
  %t.13691 = load ptr, ptr %a2v.479
  %r.13693 = call ptr @kx_str_cat(ptr %r.13690, ptr %t.13691)
  %r.13695 = call ptr @kx_str_cat(ptr %r.13693, ptr @.str.100)
  %r.13696 = call i64 @Emit(i64 %t.13673, ptr %r.13695)
  %t.13697 = load ptr, ptr %r.484
  %r.13699 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.13697)
  ret ptr %r.13699
dead.13700:
  br label %if.merge.13444
if.merge.13444:
  %t.13701 = load i64, ptr %m.427
  %ext.13703 = inttoptr i64 %t.13701 to ptr
  %r.13704 = call i1 @kx_str_eq(ptr %ext.13703, ptr @.str.295)
  br i1 %r.13704, label %if.then.13705, label %if.merge.13706
if.then.13705:
  %t.13707 = load i64, ptr %g.addr
  %t.13708 = load i64, ptr %arena.addr
  %t.13709 = load i64, ptr %e.addr
  %cast.13710 = sext i32 1 to i64
  %r.13711 = call i64 @Child(i64 %t.13708, i64 %t.13709, i64 %cast.13710)
  %t.13712 = load i64, ptr %arena.addr
  %r.13713 = call ptr @GenExpr(i64 %t.13707, i64 %r.13711, i64 %t.13712)
  %a.485 = alloca ptr
  store ptr %r.13713, ptr %a.485
  %t.13714 = load i64, ptr %bv.445
  %bv2.486 = alloca i64
  store i64 %t.13714, ptr %bv2.486
  %t.13715 = load i64, ptr %bt.446
  %ext.13717 = inttoptr i64 %t.13715 to ptr
  %r.13718 = call i1 @kx_str_eq(ptr %ext.13717, ptr @.str.269)
  br i1 %r.13718, label %if.then.13719, label %if.merge.13720
if.then.13719:
  %t.13721 = load i64, ptr %g.addr
  %r.13722 = call i64 @kx_struct_get(i64 %t.13721, i32 4)
  %t.13723 = load i64, ptr %g.addr
  %r.13724 = call i64 @kx_struct_get(i64 %t.13723, i32 4)
  %ext.13726 = sext i32 0 to i64
  %r.13725 = call i64 @kx_list_get(i64 %r.13724, i64 %ext.13726)
  %ext.13727 = sext i32 1 to i64
  %t.13728 = add i64 %r.13725, %ext.13727
  %ext.13729 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13722, i64 %ext.13729, i64 %t.13728)
  %t.13730 = load i64, ptr %g.addr
  %r.13731 = call i64 @kx_struct_get(i64 %t.13730, i32 4)
  %ext.13733 = sext i32 0 to i64
  %r.13732 = call i64 @kx_list_get(i64 %r.13731, i64 %ext.13733)
  %r.13734 = call ptr @kx_int_str(i64 %r.13732)
  %r.13736 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13734)
  %ext.487 = alloca ptr
  store ptr %r.13736, ptr %ext.487
  %t.13737 = load i64, ptr %g.addr
  %t.13738 = load ptr, ptr %ext.487
  %r.13740 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13738)
  %r.13742 = call ptr @kx_str_cat(ptr %r.13740, ptr @.str.277)
  %t.13743 = load i64, ptr %bv.445
  %ext.13745 = call ptr @kx_int_str(i64 %t.13743)
  %r.13746 = call ptr @kx_str_cat(ptr %r.13742, ptr %ext.13745)
  %r.13748 = call ptr @kx_str_cat(ptr %r.13746, ptr @.str.278)
  %r.13749 = call i64 @Emit(i64 %t.13737, ptr %r.13748)
  %t.13750 = load ptr, ptr %ext.487
  %ptrtoint.13751 = ptrtoint ptr %t.13750 to i64
  store i64 %ptrtoint.13751, ptr %bv2.486
  br label %if.merge.13720
if.merge.13720:
  %t.13752 = load i64, ptr %g.addr
  %r.13753 = call i64 @kx_struct_get(i64 %t.13752, i32 4)
  %t.13754 = load i64, ptr %g.addr
  %r.13755 = call i64 @kx_struct_get(i64 %t.13754, i32 4)
  %ext.13757 = sext i32 0 to i64
  %r.13756 = call i64 @kx_list_get(i64 %r.13755, i64 %ext.13757)
  %ext.13758 = sext i32 1 to i64
  %t.13759 = add i64 %r.13756, %ext.13758
  %ext.13760 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13753, i64 %ext.13760, i64 %t.13759)
  %t.13761 = load i64, ptr %g.addr
  %r.13762 = call i64 @kx_struct_get(i64 %t.13761, i32 4)
  %ext.13764 = sext i32 0 to i64
  %r.13763 = call i64 @kx_list_get(i64 %r.13762, i64 %ext.13764)
  %r.13765 = call ptr @kx_int_str(i64 %r.13763)
  %r.13767 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13765)
  %r.488 = alloca ptr
  store ptr %r.13767, ptr %r.488
  %t.13768 = load i64, ptr %g.addr
  %t.13769 = load ptr, ptr %r.488
  %r.13771 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13769)
  %r.13773 = call ptr @kx_str_cat(ptr %r.13771, ptr @.str.473)
  %t.13774 = load i64, ptr %bv2.486
  %ext.13776 = call ptr @kx_int_str(i64 %t.13774)
  %r.13777 = call ptr @kx_str_cat(ptr %r.13773, ptr %ext.13776)
  %r.13779 = call ptr @kx_str_cat(ptr %r.13777, ptr @.str.396)
  %t.13780 = load ptr, ptr %a.485
  %r.13781 = call i64 @XVal(ptr %t.13780)
  %ext.13783 = call ptr @kx_int_str(i64 %r.13781)
  %r.13784 = call ptr @kx_str_cat(ptr %r.13779, ptr %ext.13783)
  %r.13786 = call ptr @kx_str_cat(ptr %r.13784, ptr @.str.100)
  %r.13787 = call i64 @Emit(i64 %t.13768, ptr %r.13786)
  %t.13788 = load ptr, ptr %r.488
  %r.13790 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.13788)
  ret ptr %r.13790
dead.13791:
  br label %if.merge.13706
if.merge.13706:
  %t.13792 = load i64, ptr %m.427
  %ext.13794 = inttoptr i64 %t.13792 to ptr
  %r.13795 = call i1 @kx_str_eq(ptr %ext.13794, ptr @.str.296)
  br i1 %r.13795, label %if.then.13796, label %if.merge.13797
if.then.13796:
  %t.13798 = load i64, ptr %g.addr
  %t.13799 = load i64, ptr %arena.addr
  %t.13800 = load i64, ptr %e.addr
  %cast.13801 = sext i32 1 to i64
  %r.13802 = call i64 @Child(i64 %t.13799, i64 %t.13800, i64 %cast.13801)
  %t.13803 = load i64, ptr %arena.addr
  %r.13804 = call ptr @GenExpr(i64 %t.13798, i64 %r.13802, i64 %t.13803)
  %a.489 = alloca ptr
  store ptr %r.13804, ptr %a.489
  %t.13805 = load i64, ptr %bv.445
  %bv2.490 = alloca i64
  store i64 %t.13805, ptr %bv2.490
  %t.13806 = load i64, ptr %bt.446
  %ext.13808 = inttoptr i64 %t.13806 to ptr
  %r.13809 = call i1 @kx_str_eq(ptr %ext.13808, ptr @.str.269)
  br i1 %r.13809, label %if.then.13810, label %if.merge.13811
if.then.13810:
  %t.13812 = load i64, ptr %g.addr
  %r.13813 = call i64 @kx_struct_get(i64 %t.13812, i32 4)
  %t.13814 = load i64, ptr %g.addr
  %r.13815 = call i64 @kx_struct_get(i64 %t.13814, i32 4)
  %ext.13817 = sext i32 0 to i64
  %r.13816 = call i64 @kx_list_get(i64 %r.13815, i64 %ext.13817)
  %ext.13818 = sext i32 1 to i64
  %t.13819 = add i64 %r.13816, %ext.13818
  %ext.13820 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13813, i64 %ext.13820, i64 %t.13819)
  %t.13821 = load i64, ptr %g.addr
  %r.13822 = call i64 @kx_struct_get(i64 %t.13821, i32 4)
  %ext.13824 = sext i32 0 to i64
  %r.13823 = call i64 @kx_list_get(i64 %r.13822, i64 %ext.13824)
  %r.13825 = call ptr @kx_int_str(i64 %r.13823)
  %r.13827 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13825)
  %ext.491 = alloca ptr
  store ptr %r.13827, ptr %ext.491
  %t.13828 = load i64, ptr %g.addr
  %t.13829 = load ptr, ptr %ext.491
  %r.13831 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13829)
  %r.13833 = call ptr @kx_str_cat(ptr %r.13831, ptr @.str.277)
  %t.13834 = load i64, ptr %bv.445
  %ext.13836 = call ptr @kx_int_str(i64 %t.13834)
  %r.13837 = call ptr @kx_str_cat(ptr %r.13833, ptr %ext.13836)
  %r.13839 = call ptr @kx_str_cat(ptr %r.13837, ptr @.str.278)
  %r.13840 = call i64 @Emit(i64 %t.13828, ptr %r.13839)
  %t.13841 = load ptr, ptr %ext.491
  %ptrtoint.13842 = ptrtoint ptr %t.13841 to i64
  store i64 %ptrtoint.13842, ptr %bv2.490
  br label %if.merge.13811
if.merge.13811:
  %t.13843 = load i64, ptr %g.addr
  %r.13844 = call i64 @kx_struct_get(i64 %t.13843, i32 4)
  %t.13845 = load i64, ptr %g.addr
  %r.13846 = call i64 @kx_struct_get(i64 %t.13845, i32 4)
  %ext.13848 = sext i32 0 to i64
  %r.13847 = call i64 @kx_list_get(i64 %r.13846, i64 %ext.13848)
  %ext.13849 = sext i32 1 to i64
  %t.13850 = add i64 %r.13847, %ext.13849
  %ext.13851 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13844, i64 %ext.13851, i64 %t.13850)
  %t.13852 = load i64, ptr %g.addr
  %r.13853 = call i64 @kx_struct_get(i64 %t.13852, i32 4)
  %ext.13855 = sext i32 0 to i64
  %r.13854 = call i64 @kx_list_get(i64 %r.13853, i64 %ext.13855)
  %r.13856 = call ptr @kx_int_str(i64 %r.13854)
  %r.13858 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13856)
  %r.492 = alloca ptr
  store ptr %r.13858, ptr %r.492
  %t.13859 = load i64, ptr %g.addr
  %t.13860 = load ptr, ptr %r.492
  %r.13862 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13860)
  %r.13864 = call ptr @kx_str_cat(ptr %r.13862, ptr @.str.474)
  %t.13865 = load i64, ptr %bv2.490
  %ext.13867 = call ptr @kx_int_str(i64 %t.13865)
  %r.13868 = call ptr @kx_str_cat(ptr %r.13864, ptr %ext.13867)
  %r.13870 = call ptr @kx_str_cat(ptr %r.13868, ptr @.str.396)
  %t.13871 = load ptr, ptr %a.489
  %r.13872 = call i64 @XVal(ptr %t.13871)
  %ext.13874 = call ptr @kx_int_str(i64 %r.13872)
  %r.13875 = call ptr @kx_str_cat(ptr %r.13870, ptr %ext.13874)
  %r.13877 = call ptr @kx_str_cat(ptr %r.13875, ptr @.str.100)
  %r.13878 = call i64 @Emit(i64 %t.13859, ptr %r.13877)
  %t.13879 = load ptr, ptr %r.492
  %r.13881 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.13879)
  ret ptr %r.13881
dead.13882:
  br label %if.merge.13797
if.merge.13797:
  %t.13883 = load i64, ptr %m.427
  %ext.13885 = inttoptr i64 %t.13883 to ptr
  %r.13886 = call i1 @kx_str_eq(ptr %ext.13885, ptr @.str.297)
  br i1 %r.13886, label %if.then.13887, label %if.merge.13888
if.then.13887:
  %t.13889 = load i64, ptr %g.addr
  %t.13890 = load i64, ptr %arena.addr
  %t.13891 = load i64, ptr %e.addr
  %cast.13892 = sext i32 1 to i64
  %r.13893 = call i64 @Child(i64 %t.13890, i64 %t.13891, i64 %cast.13892)
  %t.13894 = load i64, ptr %arena.addr
  %r.13895 = call ptr @GenExpr(i64 %t.13889, i64 %r.13893, i64 %t.13894)
  %a.493 = alloca ptr
  store ptr %r.13895, ptr %a.493
  %t.13896 = load i64, ptr %bv.445
  %bv2.494 = alloca i64
  store i64 %t.13896, ptr %bv2.494
  %t.13897 = load i64, ptr %bt.446
  %ext.13899 = inttoptr i64 %t.13897 to ptr
  %r.13900 = call i1 @kx_str_eq(ptr %ext.13899, ptr @.str.269)
  br i1 %r.13900, label %if.then.13901, label %if.merge.13902
if.then.13901:
  %t.13903 = load i64, ptr %g.addr
  %r.13904 = call i64 @kx_struct_get(i64 %t.13903, i32 4)
  %t.13905 = load i64, ptr %g.addr
  %r.13906 = call i64 @kx_struct_get(i64 %t.13905, i32 4)
  %ext.13908 = sext i32 0 to i64
  %r.13907 = call i64 @kx_list_get(i64 %r.13906, i64 %ext.13908)
  %ext.13909 = sext i32 1 to i64
  %t.13910 = add i64 %r.13907, %ext.13909
  %ext.13911 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13904, i64 %ext.13911, i64 %t.13910)
  %t.13912 = load i64, ptr %g.addr
  %r.13913 = call i64 @kx_struct_get(i64 %t.13912, i32 4)
  %ext.13915 = sext i32 0 to i64
  %r.13914 = call i64 @kx_list_get(i64 %r.13913, i64 %ext.13915)
  %r.13916 = call ptr @kx_int_str(i64 %r.13914)
  %r.13918 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.13916)
  %ext.495 = alloca ptr
  store ptr %r.13918, ptr %ext.495
  %t.13919 = load i64, ptr %g.addr
  %t.13920 = load ptr, ptr %ext.495
  %r.13922 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13920)
  %r.13924 = call ptr @kx_str_cat(ptr %r.13922, ptr @.str.277)
  %t.13925 = load i64, ptr %bv.445
  %ext.13927 = call ptr @kx_int_str(i64 %t.13925)
  %r.13928 = call ptr @kx_str_cat(ptr %r.13924, ptr %ext.13927)
  %r.13930 = call ptr @kx_str_cat(ptr %r.13928, ptr @.str.278)
  %r.13931 = call i64 @Emit(i64 %t.13919, ptr %r.13930)
  %t.13932 = load ptr, ptr %ext.495
  %ptrtoint.13933 = ptrtoint ptr %t.13932 to i64
  store i64 %ptrtoint.13933, ptr %bv2.494
  br label %if.merge.13902
if.merge.13902:
  %t.13934 = load i64, ptr %g.addr
  %r.13935 = call i64 @kx_struct_get(i64 %t.13934, i32 4)
  %t.13936 = load i64, ptr %g.addr
  %r.13937 = call i64 @kx_struct_get(i64 %t.13936, i32 4)
  %ext.13939 = sext i32 0 to i64
  %r.13938 = call i64 @kx_list_get(i64 %r.13937, i64 %ext.13939)
  %ext.13940 = sext i32 1 to i64
  %t.13941 = add i64 %r.13938, %ext.13940
  %ext.13942 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13935, i64 %ext.13942, i64 %t.13941)
  %t.13943 = load i64, ptr %g.addr
  %r.13944 = call i64 @kx_struct_get(i64 %t.13943, i32 4)
  %ext.13946 = sext i32 0 to i64
  %r.13945 = call i64 @kx_list_get(i64 %r.13944, i64 %ext.13946)
  %r.13947 = call ptr @kx_int_str(i64 %r.13945)
  %r.13949 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.13947)
  %r.496 = alloca ptr
  store ptr %r.13949, ptr %r.496
  %t.13950 = load i64, ptr %g.addr
  %t.13951 = load ptr, ptr %r.496
  %r.13953 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.13951)
  %r.13955 = call ptr @kx_str_cat(ptr %r.13953, ptr @.str.475)
  %t.13956 = load i64, ptr %bv2.494
  %ext.13958 = call ptr @kx_int_str(i64 %t.13956)
  %r.13959 = call ptr @kx_str_cat(ptr %r.13955, ptr %ext.13958)
  %r.13961 = call ptr @kx_str_cat(ptr %r.13959, ptr @.str.396)
  %t.13962 = load ptr, ptr %a.493
  %r.13963 = call i64 @XVal(ptr %t.13962)
  %ext.13965 = call ptr @kx_int_str(i64 %r.13963)
  %r.13966 = call ptr @kx_str_cat(ptr %r.13961, ptr %ext.13965)
  %r.13968 = call ptr @kx_str_cat(ptr %r.13966, ptr @.str.100)
  %r.13969 = call i64 @Emit(i64 %t.13950, ptr %r.13968)
  %t.13970 = load ptr, ptr %r.496
  %r.13972 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.13970)
  ret ptr %r.13972
dead.13973:
  br label %if.merge.13888
if.merge.13888:
  %t.13974 = load i64, ptr %m.427
  %ext.13976 = inttoptr i64 %t.13974 to ptr
  %r.13977 = call i1 @kx_str_eq(ptr %ext.13976, ptr @.str.298)
  br i1 %r.13977, label %if.then.13978, label %if.merge.13979
if.then.13978:
  %t.13980 = load i64, ptr %bv.445
  %bv2.497 = alloca i64
  store i64 %t.13980, ptr %bv2.497
  %t.13981 = load i64, ptr %bt.446
  %ext.13983 = inttoptr i64 %t.13981 to ptr
  %r.13984 = call i1 @kx_str_eq(ptr %ext.13983, ptr @.str.269)
  br i1 %r.13984, label %if.then.13985, label %if.merge.13986
if.then.13985:
  %t.13987 = load i64, ptr %g.addr
  %r.13988 = call i64 @kx_struct_get(i64 %t.13987, i32 4)
  %t.13989 = load i64, ptr %g.addr
  %r.13990 = call i64 @kx_struct_get(i64 %t.13989, i32 4)
  %ext.13992 = sext i32 0 to i64
  %r.13991 = call i64 @kx_list_get(i64 %r.13990, i64 %ext.13992)
  %ext.13993 = sext i32 1 to i64
  %t.13994 = add i64 %r.13991, %ext.13993
  %ext.13995 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.13988, i64 %ext.13995, i64 %t.13994)
  %t.13996 = load i64, ptr %g.addr
  %r.13997 = call i64 @kx_struct_get(i64 %t.13996, i32 4)
  %ext.13999 = sext i32 0 to i64
  %r.13998 = call i64 @kx_list_get(i64 %r.13997, i64 %ext.13999)
  %r.14000 = call ptr @kx_int_str(i64 %r.13998)
  %r.14002 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14000)
  %ext.498 = alloca ptr
  store ptr %r.14002, ptr %ext.498
  %t.14003 = load i64, ptr %g.addr
  %t.14004 = load ptr, ptr %ext.498
  %r.14006 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14004)
  %r.14008 = call ptr @kx_str_cat(ptr %r.14006, ptr @.str.277)
  %t.14009 = load i64, ptr %bv.445
  %ext.14011 = call ptr @kx_int_str(i64 %t.14009)
  %r.14012 = call ptr @kx_str_cat(ptr %r.14008, ptr %ext.14011)
  %r.14014 = call ptr @kx_str_cat(ptr %r.14012, ptr @.str.278)
  %r.14015 = call i64 @Emit(i64 %t.14003, ptr %r.14014)
  %t.14016 = load ptr, ptr %ext.498
  %ptrtoint.14017 = ptrtoint ptr %t.14016 to i64
  store i64 %ptrtoint.14017, ptr %bv2.497
  br label %if.merge.13986
if.merge.13986:
  %t.14018 = load i64, ptr %g.addr
  %r.14019 = call i64 @kx_struct_get(i64 %t.14018, i32 4)
  %t.14020 = load i64, ptr %g.addr
  %r.14021 = call i64 @kx_struct_get(i64 %t.14020, i32 4)
  %ext.14023 = sext i32 0 to i64
  %r.14022 = call i64 @kx_list_get(i64 %r.14021, i64 %ext.14023)
  %ext.14024 = sext i32 1 to i64
  %t.14025 = add i64 %r.14022, %ext.14024
  %ext.14026 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14019, i64 %ext.14026, i64 %t.14025)
  %t.14027 = load i64, ptr %g.addr
  %r.14028 = call i64 @kx_struct_get(i64 %t.14027, i32 4)
  %ext.14030 = sext i32 0 to i64
  %r.14029 = call i64 @kx_list_get(i64 %r.14028, i64 %ext.14030)
  %r.14031 = call ptr @kx_int_str(i64 %r.14029)
  %r.14033 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14031)
  %r.499 = alloca ptr
  store ptr %r.14033, ptr %r.499
  %t.14034 = load i64, ptr %g.addr
  %t.14035 = load ptr, ptr %r.499
  %r.14037 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14035)
  %r.14039 = call ptr @kx_str_cat(ptr %r.14037, ptr @.str.476)
  %t.14040 = load i64, ptr %bv2.497
  %ext.14042 = call ptr @kx_int_str(i64 %t.14040)
  %r.14043 = call ptr @kx_str_cat(ptr %r.14039, ptr %ext.14042)
  %r.14045 = call ptr @kx_str_cat(ptr %r.14043, ptr @.str.100)
  %r.14046 = call i64 @Emit(i64 %t.14034, ptr %r.14045)
  %t.14047 = load ptr, ptr %r.499
  %r.14049 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.14047)
  ret ptr %r.14049
dead.14050:
  br label %if.merge.13979
if.merge.13979:
  %t.14051 = load i64, ptr %m.427
  %ext.14053 = inttoptr i64 %t.14051 to ptr
  %r.14054 = call i1 @kx_str_eq(ptr %ext.14053, ptr @.str.299)
  br i1 %r.14054, label %if.then.14055, label %if.merge.14056
if.then.14055:
  %t.14057 = load i64, ptr %bv.445
  %bv2.500 = alloca i64
  store i64 %t.14057, ptr %bv2.500
  %t.14058 = load i64, ptr %bt.446
  %ext.14060 = inttoptr i64 %t.14058 to ptr
  %r.14061 = call i1 @kx_str_eq(ptr %ext.14060, ptr @.str.269)
  br i1 %r.14061, label %if.then.14062, label %if.merge.14063
if.then.14062:
  %t.14064 = load i64, ptr %g.addr
  %r.14065 = call i64 @kx_struct_get(i64 %t.14064, i32 4)
  %t.14066 = load i64, ptr %g.addr
  %r.14067 = call i64 @kx_struct_get(i64 %t.14066, i32 4)
  %ext.14069 = sext i32 0 to i64
  %r.14068 = call i64 @kx_list_get(i64 %r.14067, i64 %ext.14069)
  %ext.14070 = sext i32 1 to i64
  %t.14071 = add i64 %r.14068, %ext.14070
  %ext.14072 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14065, i64 %ext.14072, i64 %t.14071)
  %t.14073 = load i64, ptr %g.addr
  %r.14074 = call i64 @kx_struct_get(i64 %t.14073, i32 4)
  %ext.14076 = sext i32 0 to i64
  %r.14075 = call i64 @kx_list_get(i64 %r.14074, i64 %ext.14076)
  %r.14077 = call ptr @kx_int_str(i64 %r.14075)
  %r.14079 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14077)
  %ext.501 = alloca ptr
  store ptr %r.14079, ptr %ext.501
  %t.14080 = load i64, ptr %g.addr
  %t.14081 = load ptr, ptr %ext.501
  %r.14083 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14081)
  %r.14085 = call ptr @kx_str_cat(ptr %r.14083, ptr @.str.277)
  %t.14086 = load i64, ptr %bv.445
  %ext.14088 = call ptr @kx_int_str(i64 %t.14086)
  %r.14089 = call ptr @kx_str_cat(ptr %r.14085, ptr %ext.14088)
  %r.14091 = call ptr @kx_str_cat(ptr %r.14089, ptr @.str.278)
  %r.14092 = call i64 @Emit(i64 %t.14080, ptr %r.14091)
  %t.14093 = load ptr, ptr %ext.501
  %ptrtoint.14094 = ptrtoint ptr %t.14093 to i64
  store i64 %ptrtoint.14094, ptr %bv2.500
  br label %if.merge.14063
if.merge.14063:
  %t.14095 = load i64, ptr %g.addr
  %r.14096 = call i64 @kx_struct_get(i64 %t.14095, i32 4)
  %t.14097 = load i64, ptr %g.addr
  %r.14098 = call i64 @kx_struct_get(i64 %t.14097, i32 4)
  %ext.14100 = sext i32 0 to i64
  %r.14099 = call i64 @kx_list_get(i64 %r.14098, i64 %ext.14100)
  %ext.14101 = sext i32 1 to i64
  %t.14102 = add i64 %r.14099, %ext.14101
  %ext.14103 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14096, i64 %ext.14103, i64 %t.14102)
  %t.14104 = load i64, ptr %g.addr
  %r.14105 = call i64 @kx_struct_get(i64 %t.14104, i32 4)
  %ext.14107 = sext i32 0 to i64
  %r.14106 = call i64 @kx_list_get(i64 %r.14105, i64 %ext.14107)
  %r.14108 = call ptr @kx_int_str(i64 %r.14106)
  %r.14110 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14108)
  %r.502 = alloca ptr
  store ptr %r.14110, ptr %r.502
  %t.14111 = load i64, ptr %g.addr
  %t.14112 = load ptr, ptr %r.502
  %r.14114 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14112)
  %r.14116 = call ptr @kx_str_cat(ptr %r.14114, ptr @.str.477)
  %t.14117 = load i64, ptr %bv2.500
  %ext.14119 = call ptr @kx_int_str(i64 %t.14117)
  %r.14120 = call ptr @kx_str_cat(ptr %r.14116, ptr %ext.14119)
  %r.14122 = call ptr @kx_str_cat(ptr %r.14120, ptr @.str.100)
  %r.14123 = call i64 @Emit(i64 %t.14111, ptr %r.14122)
  %t.14124 = load ptr, ptr %r.502
  %r.14126 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.14124)
  ret ptr %r.14126
dead.14127:
  br label %if.merge.14056
if.merge.14056:
  br label %if.merge.12312
if.merge.12312:
  %t.14128 = load i64, ptr %callee.425
  %ext.14130 = inttoptr i64 %t.14128 to ptr
  %r.14131 = call i1 @kx_str_eq(ptr %ext.14130, ptr @.str.92)
  br i1 %r.14131, label %if.then.14132, label %if.merge.14133
if.then.14132:
  %t.14134 = load i64, ptr %callee.425
  %ext.14136 = inttoptr i64 %t.14134 to ptr
  %r.14137 = call i1 @kx_str_eq(ptr %ext.14136, ptr @.str.316)
  br i1 %r.14137, label %if.then.14138, label %if.merge.14139
if.then.14138:
  %t.14140 = load i64, ptr %g.addr
  %t.14141 = load i64, ptr %arena.addr
  %t.14142 = load i64, ptr %e.addr
  %cast.14143 = sext i32 1 to i64
  %r.14144 = call i64 @Child(i64 %t.14141, i64 %t.14142, i64 %cast.14143)
  %t.14145 = load i64, ptr %arena.addr
  %r.14146 = call ptr @GenExpr(i64 %t.14140, i64 %r.14144, i64 %t.14145)
  %a.503 = alloca ptr
  store ptr %r.14146, ptr %a.503
  %t.14147 = load ptr, ptr %a.503
  %r.14148 = call i64 @XVal(ptr %t.14147)
  %av.504 = alloca i64
  store i64 %r.14148, ptr %av.504
  %t.14149 = load ptr, ptr %a.503
  %r.14150 = call i64 @XType(ptr %t.14149)
  %ext.14152 = inttoptr i64 %r.14150 to ptr
  %r.14153 = call i1 @kx_str_eq(ptr %ext.14152, ptr @.str.279)
  br i1 %r.14153, label %if.then.14154, label %if.else.14156
if.then.14154:
  %t.14157 = load i64, ptr %g.addr
  %r.14158 = call i64 @kx_struct_get(i64 %t.14157, i32 4)
  %t.14159 = load i64, ptr %g.addr
  %r.14160 = call i64 @kx_struct_get(i64 %t.14159, i32 4)
  %ext.14162 = sext i32 0 to i64
  %r.14161 = call i64 @kx_list_get(i64 %r.14160, i64 %ext.14162)
  %ext.14163 = sext i32 1 to i64
  %t.14164 = add i64 %r.14161, %ext.14163
  %ext.14165 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14158, i64 %ext.14165, i64 %t.14164)
  %t.14166 = load i64, ptr %g.addr
  %r.14167 = call i64 @kx_struct_get(i64 %t.14166, i32 4)
  %ext.14169 = sext i32 0 to i64
  %r.14168 = call i64 @kx_list_get(i64 %r.14167, i64 %ext.14169)
  %r.14170 = call ptr @kx_int_str(i64 %r.14168)
  %r.14172 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14170)
  %ext.505 = alloca ptr
  store ptr %r.14172, ptr %ext.505
  %t.14173 = load i64, ptr %g.addr
  %t.14174 = load ptr, ptr %ext.505
  %r.14176 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14174)
  %r.14178 = call ptr @kx_str_cat(ptr %r.14176, ptr @.str.275)
  %t.14179 = load i64, ptr %av.504
  %ext.14181 = call ptr @kx_int_str(i64 %t.14179)
  %r.14182 = call ptr @kx_str_cat(ptr %r.14178, ptr %ext.14181)
  %r.14184 = call ptr @kx_str_cat(ptr %r.14182, ptr @.str.274)
  %r.14185 = call i64 @Emit(i64 %t.14173, ptr %r.14184)
  %t.14186 = load ptr, ptr %ext.505
  %ptrtoint.14187 = ptrtoint ptr %t.14186 to i64
  store i64 %ptrtoint.14187, ptr %av.504
  br label %if.merge.14155
if.else.14156:
  %t.14188 = load ptr, ptr %a.503
  %r.14189 = call i64 @XType(ptr %t.14188)
  %ext.14191 = inttoptr i64 %r.14189 to ptr
  %r.14192 = call i1 @kx_str_eq(ptr %ext.14191, ptr @.str.271)
  br i1 %r.14192, label %if.then.14193, label %if.merge.14194
if.then.14193:
  %t.14195 = load i64, ptr %g.addr
  %r.14196 = call i64 @kx_struct_get(i64 %t.14195, i32 4)
  %t.14197 = load i64, ptr %g.addr
  %r.14198 = call i64 @kx_struct_get(i64 %t.14197, i32 4)
  %ext.14200 = sext i32 0 to i64
  %r.14199 = call i64 @kx_list_get(i64 %r.14198, i64 %ext.14200)
  %ext.14201 = sext i32 1 to i64
  %t.14202 = add i64 %r.14199, %ext.14201
  %ext.14203 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14196, i64 %ext.14203, i64 %t.14202)
  %t.14204 = load i64, ptr %g.addr
  %r.14205 = call i64 @kx_struct_get(i64 %t.14204, i32 4)
  %ext.14207 = sext i32 0 to i64
  %r.14206 = call i64 @kx_list_get(i64 %r.14205, i64 %ext.14207)
  %r.14208 = call ptr @kx_int_str(i64 %r.14206)
  %r.14210 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14208)
  %ext.506 = alloca ptr
  store ptr %r.14210, ptr %ext.506
  %t.14211 = load i64, ptr %g.addr
  %t.14212 = load ptr, ptr %ext.506
  %r.14214 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14212)
  %r.14216 = call ptr @kx_str_cat(ptr %r.14214, ptr @.str.273)
  %t.14217 = load i64, ptr %av.504
  %ext.14219 = call ptr @kx_int_str(i64 %t.14217)
  %r.14220 = call ptr @kx_str_cat(ptr %r.14216, ptr %ext.14219)
  %r.14222 = call ptr @kx_str_cat(ptr %r.14220, ptr @.str.274)
  %r.14223 = call i64 @Emit(i64 %t.14211, ptr %r.14222)
  %t.14224 = load ptr, ptr %ext.506
  %ptrtoint.14225 = ptrtoint ptr %t.14224 to i64
  store i64 %ptrtoint.14225, ptr %av.504
  br label %if.merge.14194
if.merge.14194:
  br label %if.merge.14155
if.merge.14155:
  %t.14226 = load i64, ptr %g.addr
  %r.14227 = call i64 @kx_struct_get(i64 %t.14226, i32 4)
  %t.14228 = load i64, ptr %g.addr
  %r.14229 = call i64 @kx_struct_get(i64 %t.14228, i32 4)
  %ext.14231 = sext i32 0 to i64
  %r.14230 = call i64 @kx_list_get(i64 %r.14229, i64 %ext.14231)
  %ext.14232 = sext i32 1 to i64
  %t.14233 = add i64 %r.14230, %ext.14232
  %ext.14234 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14227, i64 %ext.14234, i64 %t.14233)
  %t.14235 = load i64, ptr %g.addr
  %r.14236 = call i64 @kx_struct_get(i64 %t.14235, i32 4)
  %ext.14238 = sext i32 0 to i64
  %r.14237 = call i64 @kx_list_get(i64 %r.14236, i64 %ext.14238)
  %r.14239 = call ptr @kx_int_str(i64 %r.14237)
  %r.14241 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14239)
  %r.507 = alloca ptr
  store ptr %r.14241, ptr %r.507
  %t.14242 = load i64, ptr %g.addr
  %t.14243 = load ptr, ptr %r.507
  %r.14245 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14243)
  %r.14247 = call ptr @kx_str_cat(ptr %r.14245, ptr @.str.394)
  %t.14248 = load i64, ptr %av.504
  %ext.14250 = call ptr @kx_int_str(i64 %t.14248)
  %r.14251 = call ptr @kx_str_cat(ptr %r.14247, ptr %ext.14250)
  %r.14253 = call ptr @kx_str_cat(ptr %r.14251, ptr @.str.100)
  %r.14254 = call i64 @Emit(i64 %t.14242, ptr %r.14253)
  %t.14255 = load ptr, ptr %r.507
  %r.14257 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.14255)
  ret ptr %r.14257
dead.14258:
  br label %if.merge.14139
if.merge.14139:
  %t.14259 = load i64, ptr %callee.425
  %ext.14261 = inttoptr i64 %t.14259 to ptr
  %r.14262 = call i1 @kx_str_eq(ptr %ext.14261, ptr @.str.314)
  br i1 %r.14262, label %if.then.14263, label %if.merge.14264
if.then.14263:
  %t.14265 = load i64, ptr %g.addr
  %r.14266 = call i64 @kx_struct_get(i64 %t.14265, i32 4)
  %t.14267 = load i64, ptr %g.addr
  %r.14268 = call i64 @kx_struct_get(i64 %t.14267, i32 4)
  %ext.14270 = sext i32 0 to i64
  %r.14269 = call i64 @kx_list_get(i64 %r.14268, i64 %ext.14270)
  %ext.14271 = sext i32 1 to i64
  %t.14272 = add i64 %r.14269, %ext.14271
  %ext.14273 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14266, i64 %ext.14273, i64 %t.14272)
  %t.14274 = load i64, ptr %g.addr
  %r.14275 = call i64 @kx_struct_get(i64 %t.14274, i32 4)
  %ext.14277 = sext i32 0 to i64
  %r.14276 = call i64 @kx_list_get(i64 %r.14275, i64 %ext.14277)
  %r.14278 = call ptr @kx_int_str(i64 %r.14276)
  %r.14280 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14278)
  %r.508 = alloca ptr
  store ptr %r.14280, ptr %r.508
  %t.14281 = load i64, ptr %g.addr
  %t.14282 = load ptr, ptr %r.508
  %r.14284 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14282)
  %r.14286 = call ptr @kx_str_cat(ptr %r.14284, ptr @.str.478)
  %r.14287 = call i64 @Emit(i64 %t.14281, ptr %r.14286)
  %t.14288 = load ptr, ptr %r.508
  %r.14290 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14288)
  ret ptr %r.14290
dead.14291:
  br label %if.merge.14264
if.merge.14264:
  %t.14292 = load i64, ptr %callee.425
  %ext.14294 = inttoptr i64 %t.14292 to ptr
  %r.14295 = call i1 @kx_str_eq(ptr %ext.14294, ptr @.str.315)
  br i1 %r.14295, label %if.then.14296, label %if.merge.14297
if.then.14296:
  %t.14298 = load i64, ptr %g.addr
  %r.14299 = call i64 @kx_struct_get(i64 %t.14298, i32 4)
  %t.14300 = load i64, ptr %g.addr
  %r.14301 = call i64 @kx_struct_get(i64 %t.14300, i32 4)
  %ext.14303 = sext i32 0 to i64
  %r.14302 = call i64 @kx_list_get(i64 %r.14301, i64 %ext.14303)
  %ext.14304 = sext i32 1 to i64
  %t.14305 = add i64 %r.14302, %ext.14304
  %ext.14306 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14299, i64 %ext.14306, i64 %t.14305)
  %t.14307 = load i64, ptr %g.addr
  %r.14308 = call i64 @kx_struct_get(i64 %t.14307, i32 4)
  %ext.14310 = sext i32 0 to i64
  %r.14309 = call i64 @kx_list_get(i64 %r.14308, i64 %ext.14310)
  %r.14311 = call ptr @kx_int_str(i64 %r.14309)
  %r.14313 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14311)
  %r.509 = alloca ptr
  store ptr %r.14313, ptr %r.509
  %t.14314 = load i64, ptr %g.addr
  %t.14315 = load ptr, ptr %r.509
  %r.14317 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14315)
  %r.14319 = call ptr @kx_str_cat(ptr %r.14317, ptr @.str.479)
  %r.14320 = call i64 @Emit(i64 %t.14314, ptr %r.14319)
  %t.14321 = load ptr, ptr %r.509
  %r.14323 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14321)
  ret ptr %r.14323
dead.14324:
  br label %if.merge.14297
if.merge.14297:
  %t.14325 = load i64, ptr %callee.425
  %ext.14327 = inttoptr i64 %t.14325 to ptr
  %r.14328 = call i1 @kx_str_eq(ptr %ext.14327, ptr @.str.54)
  br i1 %r.14328, label %if.then.14329, label %if.merge.14330
if.then.14329:
  %t.14331 = load i64, ptr %g.addr
  %t.14332 = load i64, ptr %arena.addr
  %t.14333 = load i64, ptr %e.addr
  %cast.14334 = sext i32 1 to i64
  %r.14335 = call i64 @Child(i64 %t.14332, i64 %t.14333, i64 %cast.14334)
  %t.14336 = load i64, ptr %arena.addr
  %r.14337 = call ptr @GenExpr(i64 %t.14331, i64 %r.14335, i64 %t.14336)
  %a.510 = alloca ptr
  store ptr %r.14337, ptr %a.510
  %t.14338 = load i64, ptr %g.addr
  %t.14339 = load ptr, ptr %a.510
  %r.14340 = call i64 @XVal(ptr %t.14339)
  %ext.14342 = call ptr @kx_int_str(i64 %r.14340)
  %r.14343 = call ptr @kx_str_cat(ptr @.str.480, ptr %ext.14342)
  %r.14345 = call ptr @kx_str_cat(ptr %r.14343, ptr @.str.100)
  %r.14346 = call i64 @Emit(i64 %t.14338, ptr %r.14345)
  ret ptr @.str.445
dead.14347:
  br label %if.merge.14330
if.merge.14330:
  %t.14348 = load i64, ptr %callee.425
  %ext.14350 = inttoptr i64 %t.14348 to ptr
  %r.14351 = call i1 @kx_str_eq(ptr %ext.14350, ptr @.str.308)
  br i1 %r.14351, label %if.then.14352, label %if.merge.14353
if.then.14352:
  %t.14354 = load i64, ptr %g.addr
  %t.14355 = load i64, ptr %arena.addr
  %t.14356 = load i64, ptr %e.addr
  %cast.14357 = sext i32 1 to i64
  %r.14358 = call i64 @Child(i64 %t.14355, i64 %t.14356, i64 %cast.14357)
  %t.14359 = load i64, ptr %arena.addr
  %r.14360 = call ptr @GenExpr(i64 %t.14354, i64 %r.14358, i64 %t.14359)
  %a.511 = alloca ptr
  store ptr %r.14360, ptr %a.511
  %t.14361 = load i64, ptr %g.addr
  %t.14362 = load ptr, ptr %a.511
  %r.14363 = call i64 @XVal(ptr %t.14362)
  %ext.14365 = call ptr @kx_int_str(i64 %r.14363)
  %r.14366 = call ptr @kx_str_cat(ptr @.str.453, ptr %ext.14365)
  %r.14368 = call ptr @kx_str_cat(ptr %r.14366, ptr @.str.100)
  %r.14369 = call i64 @Emit(i64 %t.14361, ptr %r.14368)
  ret ptr @.str.445
dead.14370:
  br label %if.merge.14353
if.merge.14353:
  %t.14371 = load i64, ptr %callee.425
  %ext.14373 = inttoptr i64 %t.14371 to ptr
  %r.14374 = call i1 @kx_str_eq(ptr %ext.14373, ptr @.str.481)
  br i1 %r.14374, label %if.then.14375, label %if.merge.14376
if.then.14375:
  %t.14377 = load i64, ptr %g.addr
  %t.14378 = load i64, ptr %arena.addr
  %t.14379 = load i64, ptr %e.addr
  %cast.14380 = sext i32 1 to i64
  %r.14381 = call i64 @Child(i64 %t.14378, i64 %t.14379, i64 %cast.14380)
  %t.14382 = load i64, ptr %arena.addr
  %r.14383 = call ptr @GenExpr(i64 %t.14377, i64 %r.14381, i64 %t.14382)
  %a.512 = alloca ptr
  store ptr %r.14383, ptr %a.512
  %t.14384 = load i64, ptr %g.addr
  %r.14385 = call i64 @kx_struct_get(i64 %t.14384, i32 4)
  %t.14386 = load i64, ptr %g.addr
  %r.14387 = call i64 @kx_struct_get(i64 %t.14386, i32 4)
  %ext.14389 = sext i32 0 to i64
  %r.14388 = call i64 @kx_list_get(i64 %r.14387, i64 %ext.14389)
  %ext.14390 = sext i32 1 to i64
  %t.14391 = add i64 %r.14388, %ext.14390
  %ext.14392 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14385, i64 %ext.14392, i64 %t.14391)
  %t.14393 = load i64, ptr %g.addr
  %r.14394 = call i64 @kx_struct_get(i64 %t.14393, i32 4)
  %ext.14396 = sext i32 0 to i64
  %r.14395 = call i64 @kx_list_get(i64 %r.14394, i64 %ext.14396)
  %r.14397 = call ptr @kx_int_str(i64 %r.14395)
  %r.14399 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14397)
  %r.513 = alloca ptr
  store ptr %r.14399, ptr %r.513
  %t.14400 = load i64, ptr %g.addr
  %t.14401 = load ptr, ptr %r.513
  %r.14403 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14401)
  %r.14405 = call ptr @kx_str_cat(ptr %r.14403, ptr @.str.394)
  %t.14406 = load ptr, ptr %a.512
  %r.14407 = call i64 @XVal(ptr %t.14406)
  %ext.14409 = call ptr @kx_int_str(i64 %r.14407)
  %r.14410 = call ptr @kx_str_cat(ptr %r.14405, ptr %ext.14409)
  %r.14412 = call ptr @kx_str_cat(ptr %r.14410, ptr @.str.100)
  %r.14413 = call i64 @Emit(i64 %t.14400, ptr %r.14412)
  %t.14414 = load ptr, ptr %r.513
  %r.14416 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.14414)
  ret ptr %r.14416
dead.14417:
  br label %if.merge.14376
if.merge.14376:
  %t.14418 = load i64, ptr %callee.425
  %ext.14420 = inttoptr i64 %t.14418 to ptr
  %r.14421 = call i1 @kx_str_eq(ptr %ext.14420, ptr @.str.482)
  br i1 %r.14421, label %if.then.14422, label %if.merge.14423
if.then.14422:
  %t.14424 = load i64, ptr %g.addr
  %t.14425 = load i64, ptr %arena.addr
  %t.14426 = load i64, ptr %e.addr
  %cast.14427 = sext i32 1 to i64
  %r.14428 = call i64 @Child(i64 %t.14425, i64 %t.14426, i64 %cast.14427)
  %t.14429 = load i64, ptr %arena.addr
  %r.14430 = call ptr @GenExpr(i64 %t.14424, i64 %r.14428, i64 %t.14429)
  %a.514 = alloca ptr
  store ptr %r.14430, ptr %a.514
  %t.14431 = load i64, ptr %g.addr
  %r.14432 = call i64 @kx_struct_get(i64 %t.14431, i32 4)
  %t.14433 = load i64, ptr %g.addr
  %r.14434 = call i64 @kx_struct_get(i64 %t.14433, i32 4)
  %ext.14436 = sext i32 0 to i64
  %r.14435 = call i64 @kx_list_get(i64 %r.14434, i64 %ext.14436)
  %ext.14437 = sext i32 1 to i64
  %t.14438 = add i64 %r.14435, %ext.14437
  %ext.14439 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14432, i64 %ext.14439, i64 %t.14438)
  %t.14440 = load i64, ptr %g.addr
  %r.14441 = call i64 @kx_struct_get(i64 %t.14440, i32 4)
  %ext.14443 = sext i32 0 to i64
  %r.14442 = call i64 @kx_list_get(i64 %r.14441, i64 %ext.14443)
  %r.14444 = call ptr @kx_int_str(i64 %r.14442)
  %r.14446 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14444)
  %r.515 = alloca ptr
  store ptr %r.14446, ptr %r.515
  %t.14447 = load i64, ptr %g.addr
  %t.14448 = load ptr, ptr %r.515
  %r.14450 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14448)
  %r.14452 = call ptr @kx_str_cat(ptr %r.14450, ptr @.str.441)
  %t.14453 = load ptr, ptr %a.514
  %r.14454 = call i64 @XVal(ptr %t.14453)
  %ext.14456 = call ptr @kx_int_str(i64 %r.14454)
  %r.14457 = call ptr @kx_str_cat(ptr %r.14452, ptr %ext.14456)
  %r.14459 = call ptr @kx_str_cat(ptr %r.14457, ptr @.str.100)
  %r.14460 = call i64 @Emit(i64 %t.14447, ptr %r.14459)
  %t.14461 = load ptr, ptr %r.515
  %r.14463 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14461)
  ret ptr %r.14463
dead.14464:
  br label %if.merge.14423
if.merge.14423:
  %t.14465 = load i64, ptr %g.addr
  %r.14466 = call i64 @kx_struct_get(i64 %t.14465, i32 12)
  %t.14467 = load i64, ptr %callee.425
  %r.14468 = call i1 @kx_map_has(i64 %r.14466, i64 %t.14467)
  br i1 %r.14468, label %tern.then.14469, label %tern.else.14470
tern.then.14469:
  %t.14472 = load i64, ptr %g.addr
  %r.14473 = call i64 @kx_struct_get(i64 %t.14472, i32 12)
  %t.14474 = load i64, ptr %callee.425
  %r.14475 = call i64 @kx_list_get(i64 %r.14473, i64 %t.14474)
  br label %tern.merge.14471
tern.else.14470:
  %ext.14476 = ptrtoint ptr @.str.483 to i64
  br label %tern.merge.14471
tern.merge.14471:
  %phi.14477 = phi i64 [%r.14475, %tern.then.14469], [%ext.14476, %tern.else.14470]
  %signature.516 = alloca i64
  store i64 %phi.14477, ptr %signature.516
  %t.14478 = load i64, ptr %signature.516
  %cast.14479 = inttoptr i64 %t.14478 to ptr
  %r.14480 = call i64 @SigRet(ptr %cast.14479)
  %callRet.517 = alloca i64
  store i64 %r.14480, ptr %callRet.517
  %t.14481 = load i64, ptr %signature.516
  %cast.14482 = inttoptr i64 %t.14481 to ptr
  %r.14483 = call i64 @SigParams(ptr %cast.14482)
  %callParams.518 = alloca i64
  store i64 %r.14483, ptr %callParams.518
  %argStr.519 = alloca ptr
  store ptr @.str.12, ptr %argStr.519
  %ai.520 = alloca i32
  store i32 1, ptr %ai.520
  br label %for.cond.14484
for.cond.14484:
  %t.14488 = load i32, ptr %ai.520
  %t.14489 = load i64, ptr %e.addr
  %r.14490 = call i64 @kx_struct_get(i64 %t.14489, i32 4)
  %r.14491 = call i64 @kx_list_size(i64 %r.14490)
  %ext.14492 = sext i32 %t.14488 to i64
  %t.14493 = icmp slt i64 %ext.14492, %r.14491
  br i1 %t.14493, label %for.body.14485, label %for.end.14487
for.body.14485:
  %t.14494 = load i32, ptr %ai.520
  %t.14495 = icmp sgt i32 %t.14494, 1
  br i1 %t.14495, label %if.then.14496, label %if.merge.14497
if.then.14496:
  %t.14498 = load ptr, ptr %argStr.519
  %r.14500 = call ptr @kx_str_cat(ptr %t.14498, ptr @.str.403)
  store ptr %r.14500, ptr %argStr.519
  br label %if.merge.14497
if.merge.14497:
  %t.14501 = load i64, ptr %g.addr
  %t.14502 = load i64, ptr %arena.addr
  %t.14503 = load i64, ptr %e.addr
  %t.14504 = load i32, ptr %ai.520
  %cast.14505 = sext i32 %t.14504 to i64
  %r.14506 = call i64 @Child(i64 %t.14502, i64 %t.14503, i64 %cast.14505)
  %t.14507 = load i64, ptr %arena.addr
  %r.14508 = call ptr @GenExpr(i64 %t.14501, i64 %r.14506, i64 %t.14507)
  %a.521 = alloca ptr
  store ptr %r.14508, ptr %a.521
  %t.14509 = load i32, ptr %ai.520
  %t.14510 = sub i32 %t.14509, 1
  %t.14511 = load i64, ptr %callParams.518
  %r.14512 = call i64 @kx_list_size(i64 %t.14511)
  %ext.14513 = sext i32 %t.14510 to i64
  %t.14514 = icmp slt i64 %ext.14513, %r.14512
  br i1 %t.14514, label %tern.then.14515, label %tern.else.14516
tern.then.14515:
  %t.14518 = load i64, ptr %callParams.518
  %t.14519 = load i32, ptr %ai.520
  %t.14520 = sub i32 %t.14519, 1
  %ext.14522 = sext i32 %t.14520 to i64
  %r.14521 = call i64 @kx_list_get(i64 %t.14518, i64 %ext.14522)
  br label %tern.merge.14517
tern.else.14516:
  %t.14523 = load ptr, ptr %a.521
  %r.14524 = call i64 @XType(ptr %t.14523)
  br label %tern.merge.14517
tern.merge.14517:
  %phi.14525 = phi i64 [%r.14521, %tern.then.14515], [%r.14524, %tern.else.14516]
  %wantSemantic.522 = alloca i64
  store i64 %phi.14525, ptr %wantSemantic.522
  %t.14526 = load i64, ptr %wantSemantic.522
  %cast.14527 = inttoptr i64 %t.14526 to ptr
  %r.14528 = call ptr @KxType(ptr %cast.14527)
  %want.523 = alloca ptr
  store ptr %r.14528, ptr %want.523
  %t.14529 = load i64, ptr %g.addr
  %t.14530 = load ptr, ptr %a.521
  %t.14531 = load ptr, ptr %want.523
  %r.14532 = call ptr @Coerce(i64 %t.14529, ptr %t.14530, ptr %t.14531)
  %av.524 = alloca ptr
  store ptr %r.14532, ptr %av.524
  %t.14533 = load ptr, ptr %argStr.519
  %t.14534 = load ptr, ptr %want.523
  %r.14536 = call ptr @kx_str_cat(ptr %t.14533, ptr %t.14534)
  %r.14538 = call ptr @kx_str_cat(ptr %r.14536, ptr @.str.8)
  %t.14539 = load ptr, ptr %av.524
  %r.14541 = call ptr @kx_str_cat(ptr %r.14538, ptr %t.14539)
  store ptr %r.14541, ptr %argStr.519
  br label %for.inc.14486
for.inc.14486:
  %t.14542 = load i32, ptr %ai.520
  %t.14543 = add i32 %t.14542, 1
  store i32 %t.14543, ptr %ai.520
  br label %for.cond.14484
for.end.14487:
  %t.14544 = load i64, ptr %g.addr
  %r.14545 = call i64 @kx_struct_get(i64 %t.14544, i32 4)
  %t.14546 = load i64, ptr %g.addr
  %r.14547 = call i64 @kx_struct_get(i64 %t.14546, i32 4)
  %ext.14549 = sext i32 0 to i64
  %r.14548 = call i64 @kx_list_get(i64 %r.14547, i64 %ext.14549)
  %ext.14550 = sext i32 1 to i64
  %t.14551 = add i64 %r.14548, %ext.14550
  %ext.14552 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14545, i64 %ext.14552, i64 %t.14551)
  %t.14553 = load i64, ptr %g.addr
  %r.14554 = call i64 @kx_struct_get(i64 %t.14553, i32 4)
  %ext.14556 = sext i32 0 to i64
  %r.14555 = call i64 @kx_list_get(i64 %r.14554, i64 %ext.14556)
  %r.14557 = call ptr @kx_int_str(i64 %r.14555)
  %r.14559 = call ptr @kx_str_cat(ptr @.str.388, ptr %r.14557)
  %r.525 = alloca ptr
  store ptr %r.14559, ptr %r.525
  %t.14560 = load i64, ptr %callRet.517
  %cast.14561 = inttoptr i64 %t.14560 to ptr
  %r.14562 = call ptr @KxType(ptr %cast.14561)
  %callRetIR.526 = alloca ptr
  store ptr %r.14562, ptr %callRetIR.526
  %t.14563 = load ptr, ptr %callRetIR.526
  %r.14565 = call i1 @kx_str_eq(ptr %t.14563, ptr @.str.23)
  br i1 %r.14565, label %if.then.14566, label %if.merge.14567
if.then.14566:
  %t.14568 = load i64, ptr %g.addr
  %t.14569 = load i64, ptr %callee.425
  %ext.14571 = call ptr @kx_int_str(i64 %t.14569)
  %r.14572 = call ptr @kx_str_cat(ptr @.str.484, ptr %ext.14571)
  %r.14574 = call ptr @kx_str_cat(ptr %r.14572, ptr @.str.99)
  %t.14575 = load ptr, ptr %argStr.519
  %r.14577 = call ptr @kx_str_cat(ptr %r.14574, ptr %t.14575)
  %r.14579 = call ptr @kx_str_cat(ptr %r.14577, ptr @.str.100)
  %r.14580 = call i64 @Emit(i64 %t.14568, ptr %r.14579)
  ret ptr @.str.445
dead.14581:
  br label %if.merge.14567
if.merge.14567:
  %t.14582 = load i64, ptr %g.addr
  %t.14583 = load ptr, ptr %r.525
  %r.14585 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14583)
  %r.14587 = call ptr @kx_str_cat(ptr %r.14585, ptr @.str.485)
  %t.14588 = load ptr, ptr %callRetIR.526
  %r.14590 = call ptr @kx_str_cat(ptr %r.14587, ptr %t.14588)
  %r.14592 = call ptr @kx_str_cat(ptr %r.14590, ptr @.str.486)
  %t.14593 = load i64, ptr %callee.425
  %ext.14595 = call ptr @kx_int_str(i64 %t.14593)
  %r.14596 = call ptr @kx_str_cat(ptr %r.14592, ptr %ext.14595)
  %r.14598 = call ptr @kx_str_cat(ptr %r.14596, ptr @.str.99)
  %t.14599 = load ptr, ptr %argStr.519
  %r.14601 = call ptr @kx_str_cat(ptr %r.14598, ptr %t.14599)
  %r.14603 = call ptr @kx_str_cat(ptr %r.14601, ptr @.str.100)
  %r.14604 = call i64 @Emit(i64 %t.14582, ptr %r.14603)
  %t.14605 = load ptr, ptr %callRetIR.526
  %r.14607 = call ptr @kx_str_cat(ptr %t.14605, ptr @.str.8)
  %t.14608 = load ptr, ptr %r.525
  %r.14610 = call ptr @kx_str_cat(ptr %r.14607, ptr %t.14608)
  ret ptr %r.14610
dead.14611:
  br label %if.merge.14133
if.merge.14133:
  ret ptr @.str.393
dead.14612:
  br label %if.merge.12302
if.merge.12302:
  %t.14613 = load i64, ptr %e.addr
  %r.14614 = call i64 @kx_struct_get(i64 %t.14613, i32 0)
  %field.14615 = inttoptr i64 %r.14614 to ptr
  %r.14617 = call i1 @kx_str_eq(ptr %field.14615, ptr @.str.137)
  br i1 %r.14617, label %if.then.14618, label %if.merge.14619
if.then.14618:
  %t.14620 = load i64, ptr %g.addr
  %t.14621 = load i64, ptr %arena.addr
  %t.14622 = load i64, ptr %e.addr
  %cast.14623 = sext i32 0 to i64
  %r.14624 = call i64 @Child(i64 %t.14621, i64 %t.14622, i64 %cast.14623)
  %t.14625 = load i64, ptr %arena.addr
  %r.14626 = call ptr @GenExpr(i64 %t.14620, i64 %r.14624, i64 %t.14625)
  %cond.527 = alloca ptr
  store ptr %r.14626, ptr %cond.527
  %t.14627 = load ptr, ptr %cond.527
  %r.14628 = call i64 @XVal(ptr %t.14627)
  %cv.528 = alloca i64
  store i64 %r.14628, ptr %cv.528
  %t.14629 = load ptr, ptr %cond.527
  %r.14630 = call i64 @XType(ptr %t.14629)
  %ext.14632 = inttoptr i64 %r.14630 to ptr
  %r.14633 = call i1 @kx_str_eq(ptr %ext.14632, ptr @.str.269)
  br i1 %r.14633, label %if.then.14634, label %if.merge.14635
if.then.14634:
  %t.14636 = load i64, ptr %g.addr
  %r.14637 = call i64 @kx_struct_get(i64 %t.14636, i32 4)
  %t.14638 = load i64, ptr %g.addr
  %r.14639 = call i64 @kx_struct_get(i64 %t.14638, i32 4)
  %ext.14641 = sext i32 0 to i64
  %r.14640 = call i64 @kx_list_get(i64 %r.14639, i64 %ext.14641)
  %ext.14642 = sext i32 1 to i64
  %t.14643 = add i64 %r.14640, %ext.14642
  %ext.14644 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14637, i64 %ext.14644, i64 %t.14643)
  %t.14645 = load i64, ptr %g.addr
  %r.14646 = call i64 @kx_struct_get(i64 %t.14645, i32 4)
  %ext.14648 = sext i32 0 to i64
  %r.14647 = call i64 @kx_list_get(i64 %r.14646, i64 %ext.14648)
  %r.14649 = call ptr @kx_int_str(i64 %r.14647)
  %r.14651 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14649)
  %ext.529 = alloca ptr
  store ptr %r.14651, ptr %ext.529
  %t.14652 = load i64, ptr %g.addr
  %t.14653 = load ptr, ptr %ext.529
  %r.14655 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14653)
  %r.14657 = call ptr @kx_str_cat(ptr %r.14655, ptr @.str.281)
  %t.14658 = load i64, ptr %cv.528
  %ext.14660 = call ptr @kx_int_str(i64 %t.14658)
  %r.14661 = call ptr @kx_str_cat(ptr %r.14657, ptr %ext.14660)
  %r.14663 = call ptr @kx_str_cat(ptr %r.14661, ptr @.str.282)
  %r.14664 = call i64 @Emit(i64 %t.14652, ptr %r.14663)
  %t.14665 = load ptr, ptr %ext.529
  %ptrtoint.14666 = ptrtoint ptr %t.14665 to i64
  store i64 %ptrtoint.14666, ptr %cv.528
  br label %if.merge.14635
if.merge.14635:
  %t.14667 = load i64, ptr %g.addr
  %r.14668 = call i64 @kx_struct_get(i64 %t.14667, i32 4)
  %t.14669 = load i64, ptr %g.addr
  %r.14670 = call i64 @kx_struct_get(i64 %t.14669, i32 4)
  %ext.14672 = sext i32 0 to i64
  %r.14671 = call i64 @kx_list_get(i64 %r.14670, i64 %ext.14672)
  %ext.14673 = sext i32 1 to i64
  %t.14674 = add i64 %r.14671, %ext.14673
  %ext.14675 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14668, i64 %ext.14675, i64 %t.14674)
  %t.14676 = load i64, ptr %g.addr
  %r.14677 = call i64 @kx_struct_get(i64 %t.14676, i32 4)
  %ext.14679 = sext i32 0 to i64
  %r.14678 = call i64 @kx_list_get(i64 %r.14677, i64 %ext.14679)
  %r.14680 = call ptr @kx_int_str(i64 %r.14678)
  %r.14682 = call ptr @kx_str_cat(ptr @.str.487, ptr %r.14680)
  %tl.530 = alloca ptr
  store ptr %r.14682, ptr %tl.530
  %t.14683 = load i64, ptr %g.addr
  %r.14684 = call i64 @kx_struct_get(i64 %t.14683, i32 4)
  %t.14685 = load i64, ptr %g.addr
  %r.14686 = call i64 @kx_struct_get(i64 %t.14685, i32 4)
  %ext.14688 = sext i32 0 to i64
  %r.14687 = call i64 @kx_list_get(i64 %r.14686, i64 %ext.14688)
  %ext.14689 = sext i32 1 to i64
  %t.14690 = add i64 %r.14687, %ext.14689
  %ext.14691 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14684, i64 %ext.14691, i64 %t.14690)
  %t.14692 = load i64, ptr %g.addr
  %r.14693 = call i64 @kx_struct_get(i64 %t.14692, i32 4)
  %ext.14695 = sext i32 0 to i64
  %r.14694 = call i64 @kx_list_get(i64 %r.14693, i64 %ext.14695)
  %r.14696 = call ptr @kx_int_str(i64 %r.14694)
  %r.14698 = call ptr @kx_str_cat(ptr @.str.488, ptr %r.14696)
  %el.531 = alloca ptr
  store ptr %r.14698, ptr %el.531
  %t.14699 = load i64, ptr %g.addr
  %r.14700 = call i64 @kx_struct_get(i64 %t.14699, i32 4)
  %t.14701 = load i64, ptr %g.addr
  %r.14702 = call i64 @kx_struct_get(i64 %t.14701, i32 4)
  %ext.14704 = sext i32 0 to i64
  %r.14703 = call i64 @kx_list_get(i64 %r.14702, i64 %ext.14704)
  %ext.14705 = sext i32 1 to i64
  %t.14706 = add i64 %r.14703, %ext.14705
  %ext.14707 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14700, i64 %ext.14707, i64 %t.14706)
  %t.14708 = load i64, ptr %g.addr
  %r.14709 = call i64 @kx_struct_get(i64 %t.14708, i32 4)
  %ext.14711 = sext i32 0 to i64
  %r.14710 = call i64 @kx_list_get(i64 %r.14709, i64 %ext.14711)
  %r.14712 = call ptr @kx_int_str(i64 %r.14710)
  %r.14714 = call ptr @kx_str_cat(ptr @.str.489, ptr %r.14712)
  %ml.532 = alloca ptr
  store ptr %r.14714, ptr %ml.532
  %t.14715 = load i64, ptr %g.addr
  %t.14716 = load i64, ptr %cv.528
  %ext.14718 = call ptr @kx_int_str(i64 %t.14716)
  %r.14719 = call ptr @kx_str_cat(ptr @.str.490, ptr %ext.14718)
  %r.14721 = call ptr @kx_str_cat(ptr %r.14719, ptr @.str.491)
  %t.14722 = load ptr, ptr %tl.530
  %r.14724 = call ptr @kx_str_cat(ptr %r.14721, ptr %t.14722)
  %r.14726 = call ptr @kx_str_cat(ptr %r.14724, ptr @.str.491)
  %t.14727 = load ptr, ptr %el.531
  %r.14729 = call ptr @kx_str_cat(ptr %r.14726, ptr %t.14727)
  %r.14730 = call i64 @Emit(i64 %t.14715, ptr %r.14729)
  %t.14731 = load i64, ptr %g.addr
  %t.14732 = load ptr, ptr %tl.530
  %r.14734 = call ptr @kx_str_cat(ptr %t.14732, ptr @.str.89)
  %r.14735 = call i64 @Emit(i64 %t.14731, ptr %r.14734)
  %t.14736 = load i64, ptr %g.addr
  %t.14737 = load i64, ptr %arena.addr
  %t.14738 = load i64, ptr %e.addr
  %cast.14739 = sext i32 1 to i64
  %r.14740 = call i64 @Child(i64 %t.14737, i64 %t.14738, i64 %cast.14739)
  %t.14741 = load i64, ptr %arena.addr
  %r.14742 = call ptr @GenExpr(i64 %t.14736, i64 %r.14740, i64 %t.14741)
  %tv.533 = alloca ptr
  store ptr %r.14742, ptr %tv.533
  %t.14743 = load i64, ptr %g.addr
  %t.14744 = load ptr, ptr %ml.532
  %r.14746 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.14744)
  %r.14747 = call i64 @Emit(i64 %t.14743, ptr %r.14746)
  %t.14748 = load i64, ptr %g.addr
  %t.14749 = load ptr, ptr %el.531
  %r.14751 = call ptr @kx_str_cat(ptr %t.14749, ptr @.str.89)
  %r.14752 = call i64 @Emit(i64 %t.14748, ptr %r.14751)
  %t.14753 = load i64, ptr %g.addr
  %t.14754 = load i64, ptr %arena.addr
  %t.14755 = load i64, ptr %e.addr
  %cast.14756 = sext i32 2 to i64
  %r.14757 = call i64 @Child(i64 %t.14754, i64 %t.14755, i64 %cast.14756)
  %t.14758 = load i64, ptr %arena.addr
  %r.14759 = call ptr @GenExpr(i64 %t.14753, i64 %r.14757, i64 %t.14758)
  %fv.534 = alloca ptr
  store ptr %r.14759, ptr %fv.534
  %t.14760 = load ptr, ptr %tv.533
  %r.14761 = call i64 @XType(ptr %t.14760)
  %tt.535 = alloca i64
  store i64 %r.14761, ptr %tt.535
  %t.14762 = load ptr, ptr %fv.534
  %r.14763 = call i64 @XType(ptr %t.14762)
  %ft.536 = alloca i64
  store i64 %r.14763, ptr %ft.536
  %t.14764 = load i64, ptr %tt.535
  %t.14765 = load i64, ptr %ft.536
  %t.14766 = icmp ne i64 %t.14764, %t.14765
  %t.14767 = load i64, ptr %tt.535
  %ext.14769 = inttoptr i64 %t.14767 to ptr
  %r.14770 = call i1 @kx_str_eq(ptr %ext.14769, ptr @.str.269)
  %t.14771 = and i1 %t.14766, %r.14770
  %t.14772 = load i64, ptr %ft.536
  %ext.14774 = inttoptr i64 %t.14772 to ptr
  %r.14775 = call i1 @kx_str_eq(ptr %ext.14774, ptr @.str.271)
  %t.14776 = and i1 %t.14771, %r.14775
  br i1 %t.14776, label %if.then.14777, label %if.else.14779
if.then.14777:
  %t.14780 = load i64, ptr %g.addr
  %r.14781 = call i64 @kx_struct_get(i64 %t.14780, i32 4)
  %t.14782 = load i64, ptr %g.addr
  %r.14783 = call i64 @kx_struct_get(i64 %t.14782, i32 4)
  %ext.14785 = sext i32 0 to i64
  %r.14784 = call i64 @kx_list_get(i64 %r.14783, i64 %ext.14785)
  %ext.14786 = sext i32 1 to i64
  %t.14787 = add i64 %r.14784, %ext.14786
  %ext.14788 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14781, i64 %ext.14788, i64 %t.14787)
  %t.14789 = load i64, ptr %g.addr
  %r.14790 = call i64 @kx_struct_get(i64 %t.14789, i32 4)
  %ext.14792 = sext i32 0 to i64
  %r.14791 = call i64 @kx_list_get(i64 %r.14790, i64 %ext.14792)
  %r.14793 = call ptr @kx_int_str(i64 %r.14791)
  %r.14795 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14793)
  %ext.537 = alloca ptr
  store ptr %r.14795, ptr %ext.537
  %t.14796 = load i64, ptr %g.addr
  %t.14797 = load ptr, ptr %ext.537
  %r.14799 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14797)
  %r.14801 = call ptr @kx_str_cat(ptr %r.14799, ptr @.str.273)
  %t.14802 = load ptr, ptr %fv.534
  %r.14803 = call i64 @XVal(ptr %t.14802)
  %ext.14805 = call ptr @kx_int_str(i64 %r.14803)
  %r.14806 = call ptr @kx_str_cat(ptr %r.14801, ptr %ext.14805)
  %r.14808 = call ptr @kx_str_cat(ptr %r.14806, ptr @.str.274)
  %r.14809 = call i64 @Emit(i64 %t.14796, ptr %r.14808)
  %t.14810 = load ptr, ptr %ext.537
  %r.14812 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14810)
  store ptr %r.14812, ptr %fv.534
  br label %if.merge.14778
if.else.14779:
  %t.14813 = load i64, ptr %tt.535
  %t.14814 = load i64, ptr %ft.536
  %t.14815 = icmp ne i64 %t.14813, %t.14814
  %t.14816 = load i64, ptr %tt.535
  %ext.14818 = inttoptr i64 %t.14816 to ptr
  %r.14819 = call i1 @kx_str_eq(ptr %ext.14818, ptr @.str.269)
  %t.14820 = and i1 %t.14815, %r.14819
  %t.14821 = load i64, ptr %ft.536
  %ext.14823 = inttoptr i64 %t.14821 to ptr
  %r.14824 = call i1 @kx_str_eq(ptr %ext.14823, ptr @.str.279)
  %t.14825 = and i1 %t.14820, %r.14824
  br i1 %t.14825, label %if.then.14826, label %if.else.14828
if.then.14826:
  %t.14829 = load i64, ptr %g.addr
  %r.14830 = call i64 @kx_struct_get(i64 %t.14829, i32 4)
  %t.14831 = load i64, ptr %g.addr
  %r.14832 = call i64 @kx_struct_get(i64 %t.14831, i32 4)
  %ext.14834 = sext i32 0 to i64
  %r.14833 = call i64 @kx_list_get(i64 %r.14832, i64 %ext.14834)
  %ext.14835 = sext i32 1 to i64
  %t.14836 = add i64 %r.14833, %ext.14835
  %ext.14837 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14830, i64 %ext.14837, i64 %t.14836)
  %t.14838 = load i64, ptr %g.addr
  %r.14839 = call i64 @kx_struct_get(i64 %t.14838, i32 4)
  %ext.14841 = sext i32 0 to i64
  %r.14840 = call i64 @kx_list_get(i64 %r.14839, i64 %ext.14841)
  %r.14842 = call ptr @kx_int_str(i64 %r.14840)
  %r.14844 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14842)
  %ext.538 = alloca ptr
  store ptr %r.14844, ptr %ext.538
  %t.14845 = load i64, ptr %g.addr
  %t.14846 = load ptr, ptr %ext.538
  %r.14848 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14846)
  %r.14850 = call ptr @kx_str_cat(ptr %r.14848, ptr @.str.275)
  %t.14851 = load ptr, ptr %fv.534
  %r.14852 = call i64 @XVal(ptr %t.14851)
  %ext.14854 = call ptr @kx_int_str(i64 %r.14852)
  %r.14855 = call ptr @kx_str_cat(ptr %r.14850, ptr %ext.14854)
  %r.14857 = call ptr @kx_str_cat(ptr %r.14855, ptr @.str.274)
  %r.14858 = call i64 @Emit(i64 %t.14845, ptr %r.14857)
  %t.14859 = load ptr, ptr %ext.538
  %r.14861 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14859)
  store ptr %r.14861, ptr %fv.534
  br label %if.merge.14827
if.else.14828:
  %t.14862 = load i64, ptr %tt.535
  %t.14863 = load i64, ptr %ft.536
  %t.14864 = icmp ne i64 %t.14862, %t.14863
  %t.14865 = load i64, ptr %tt.535
  %ext.14867 = inttoptr i64 %t.14865 to ptr
  %r.14868 = call i1 @kx_str_eq(ptr %ext.14867, ptr @.str.269)
  %t.14869 = and i1 %t.14864, %r.14868
  %t.14870 = load i64, ptr %ft.536
  %ext.14872 = inttoptr i64 %t.14870 to ptr
  %r.14873 = call i1 @kx_str_eq(ptr %ext.14872, ptr @.str.280)
  %t.14874 = and i1 %t.14869, %r.14873
  br i1 %t.14874, label %if.then.14875, label %if.else.14877
if.then.14875:
  %t.14878 = load i64, ptr %g.addr
  %r.14879 = call i64 @kx_struct_get(i64 %t.14878, i32 4)
  %t.14880 = load i64, ptr %g.addr
  %r.14881 = call i64 @kx_struct_get(i64 %t.14880, i32 4)
  %ext.14883 = sext i32 0 to i64
  %r.14882 = call i64 @kx_list_get(i64 %r.14881, i64 %ext.14883)
  %ext.14884 = sext i32 1 to i64
  %t.14885 = add i64 %r.14882, %ext.14884
  %ext.14886 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14879, i64 %ext.14886, i64 %t.14885)
  %t.14887 = load i64, ptr %g.addr
  %r.14888 = call i64 @kx_struct_get(i64 %t.14887, i32 4)
  %ext.14890 = sext i32 0 to i64
  %r.14889 = call i64 @kx_list_get(i64 %r.14888, i64 %ext.14890)
  %r.14891 = call ptr @kx_int_str(i64 %r.14889)
  %r.14893 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14891)
  %ext.539 = alloca ptr
  store ptr %r.14893, ptr %ext.539
  %t.14894 = load i64, ptr %g.addr
  %t.14895 = load ptr, ptr %ext.539
  %r.14897 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14895)
  %r.14899 = call ptr @kx_str_cat(ptr %r.14897, ptr @.str.283)
  %t.14900 = load ptr, ptr %fv.534
  %r.14901 = call i64 @XVal(ptr %t.14900)
  %ext.14903 = call ptr @kx_int_str(i64 %r.14901)
  %r.14904 = call ptr @kx_str_cat(ptr %r.14899, ptr %ext.14903)
  %r.14906 = call ptr @kx_str_cat(ptr %r.14904, ptr @.str.274)
  %r.14907 = call i64 @Emit(i64 %t.14894, ptr %r.14906)
  %t.14908 = load ptr, ptr %ext.539
  %r.14910 = call ptr @kx_str_cat(ptr @.str.386, ptr %t.14908)
  store ptr %r.14910, ptr %fv.534
  br label %if.merge.14876
if.else.14877:
  %t.14911 = load i64, ptr %tt.535
  %t.14912 = load i64, ptr %ft.536
  %t.14913 = icmp ne i64 %t.14911, %t.14912
  %t.14914 = load i64, ptr %tt.535
  %ext.14916 = inttoptr i64 %t.14914 to ptr
  %r.14917 = call i1 @kx_str_eq(ptr %ext.14916, ptr @.str.279)
  %t.14918 = and i1 %t.14913, %r.14917
  %t.14919 = load i64, ptr %ft.536
  %ext.14921 = inttoptr i64 %t.14919 to ptr
  %r.14922 = call i1 @kx_str_eq(ptr %ext.14921, ptr @.str.269)
  %t.14923 = and i1 %t.14918, %r.14922
  br i1 %t.14923, label %if.then.14924, label %if.else.14926
if.then.14924:
  %t.14927 = load i64, ptr %g.addr
  %r.14928 = call i64 @kx_struct_get(i64 %t.14927, i32 4)
  %t.14929 = load i64, ptr %g.addr
  %r.14930 = call i64 @kx_struct_get(i64 %t.14929, i32 4)
  %ext.14932 = sext i32 0 to i64
  %r.14931 = call i64 @kx_list_get(i64 %r.14930, i64 %ext.14932)
  %ext.14933 = sext i32 1 to i64
  %t.14934 = add i64 %r.14931, %ext.14933
  %ext.14935 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14928, i64 %ext.14935, i64 %t.14934)
  %t.14936 = load i64, ptr %g.addr
  %r.14937 = call i64 @kx_struct_get(i64 %t.14936, i32 4)
  %ext.14939 = sext i32 0 to i64
  %r.14938 = call i64 @kx_list_get(i64 %r.14937, i64 %ext.14939)
  %r.14940 = call ptr @kx_int_str(i64 %r.14938)
  %r.14942 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14940)
  %ext.540 = alloca ptr
  store ptr %r.14942, ptr %ext.540
  %t.14943 = load i64, ptr %g.addr
  %t.14944 = load ptr, ptr %ext.540
  %r.14946 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14944)
  %r.14948 = call ptr @kx_str_cat(ptr %r.14946, ptr @.str.493)
  %t.14949 = load ptr, ptr %fv.534
  %r.14950 = call i64 @XVal(ptr %t.14949)
  %ext.14952 = call ptr @kx_int_str(i64 %r.14950)
  %r.14953 = call ptr @kx_str_cat(ptr %r.14948, ptr %ext.14952)
  %r.14955 = call ptr @kx_str_cat(ptr %r.14953, ptr @.str.494)
  %r.14956 = call i64 @Emit(i64 %t.14943, ptr %r.14955)
  %t.14957 = load ptr, ptr %ext.540
  %r.14959 = call ptr @kx_str_cat(ptr @.str.385, ptr %t.14957)
  store ptr %r.14959, ptr %fv.534
  br label %if.merge.14925
if.else.14926:
  %t.14960 = load i64, ptr %tt.535
  %t.14961 = load i64, ptr %ft.536
  %t.14962 = icmp ne i64 %t.14960, %t.14961
  %t.14963 = load i64, ptr %tt.535
  %ext.14965 = inttoptr i64 %t.14963 to ptr
  %r.14966 = call i1 @kx_str_eq(ptr %ext.14965, ptr @.str.280)
  %t.14967 = and i1 %t.14962, %r.14966
  %t.14968 = load i64, ptr %ft.536
  %ext.14970 = inttoptr i64 %t.14968 to ptr
  %r.14971 = call i1 @kx_str_eq(ptr %ext.14970, ptr @.str.269)
  %t.14972 = and i1 %t.14967, %r.14971
  br i1 %t.14972, label %if.then.14973, label %if.else.14975
if.then.14973:
  %t.14976 = load i64, ptr %g.addr
  %r.14977 = call i64 @kx_struct_get(i64 %t.14976, i32 4)
  %t.14978 = load i64, ptr %g.addr
  %r.14979 = call i64 @kx_struct_get(i64 %t.14978, i32 4)
  %ext.14981 = sext i32 0 to i64
  %r.14980 = call i64 @kx_list_get(i64 %r.14979, i64 %ext.14981)
  %ext.14982 = sext i32 1 to i64
  %t.14983 = add i64 %r.14980, %ext.14982
  %ext.14984 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.14977, i64 %ext.14984, i64 %t.14983)
  %t.14985 = load i64, ptr %g.addr
  %r.14986 = call i64 @kx_struct_get(i64 %t.14985, i32 4)
  %ext.14988 = sext i32 0 to i64
  %r.14987 = call i64 @kx_list_get(i64 %r.14986, i64 %ext.14988)
  %r.14989 = call ptr @kx_int_str(i64 %r.14987)
  %r.14991 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.14989)
  %ext.541 = alloca ptr
  store ptr %r.14991, ptr %ext.541
  %t.14992 = load i64, ptr %g.addr
  %t.14993 = load ptr, ptr %ext.541
  %r.14995 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.14993)
  %r.14997 = call ptr @kx_str_cat(ptr %r.14995, ptr @.str.281)
  %t.14998 = load ptr, ptr %fv.534
  %r.14999 = call i64 @XVal(ptr %t.14998)
  %ext.15001 = call ptr @kx_int_str(i64 %r.14999)
  %r.15002 = call ptr @kx_str_cat(ptr %r.14997, ptr %ext.15001)
  %r.15004 = call ptr @kx_str_cat(ptr %r.15002, ptr @.str.282)
  %r.15005 = call i64 @Emit(i64 %t.14992, ptr %r.15004)
  %t.15006 = load ptr, ptr %ext.541
  %r.15008 = call ptr @kx_str_cat(ptr @.str.397, ptr %t.15006)
  store ptr %r.15008, ptr %fv.534
  br label %if.merge.14974
if.else.14975:
  %t.15009 = load i64, ptr %tt.535
  %t.15010 = load i64, ptr %ft.536
  %t.15011 = icmp ne i64 %t.15009, %t.15010
  %t.15012 = load i64, ptr %tt.535
  %ext.15014 = inttoptr i64 %t.15012 to ptr
  %r.15015 = call i1 @kx_str_eq(ptr %ext.15014, ptr @.str.271)
  %t.15016 = and i1 %t.15011, %r.15015
  %t.15017 = load i64, ptr %ft.536
  %ext.15019 = inttoptr i64 %t.15017 to ptr
  %r.15020 = call i1 @kx_str_eq(ptr %ext.15019, ptr @.str.269)
  %t.15021 = and i1 %t.15016, %r.15020
  br i1 %t.15021, label %if.then.15022, label %if.merge.15023
if.then.15022:
  %t.15024 = load i64, ptr %g.addr
  %r.15025 = call i64 @kx_struct_get(i64 %t.15024, i32 4)
  %t.15026 = load i64, ptr %g.addr
  %r.15027 = call i64 @kx_struct_get(i64 %t.15026, i32 4)
  %ext.15029 = sext i32 0 to i64
  %r.15028 = call i64 @kx_list_get(i64 %r.15027, i64 %ext.15029)
  %ext.15030 = sext i32 1 to i64
  %t.15031 = add i64 %r.15028, %ext.15030
  %ext.15032 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15025, i64 %ext.15032, i64 %t.15031)
  %t.15033 = load i64, ptr %g.addr
  %r.15034 = call i64 @kx_struct_get(i64 %t.15033, i32 4)
  %ext.15036 = sext i32 0 to i64
  %r.15035 = call i64 @kx_list_get(i64 %r.15034, i64 %ext.15036)
  %r.15037 = call ptr @kx_int_str(i64 %r.15035)
  %r.15039 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15037)
  %ext.542 = alloca ptr
  store ptr %r.15039, ptr %ext.542
  %t.15040 = load i64, ptr %g.addr
  %t.15041 = load ptr, ptr %ext.542
  %r.15043 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15041)
  %r.15045 = call ptr @kx_str_cat(ptr %r.15043, ptr @.str.277)
  %t.15046 = load ptr, ptr %fv.534
  %r.15047 = call i64 @XVal(ptr %t.15046)
  %ext.15049 = call ptr @kx_int_str(i64 %r.15047)
  %r.15050 = call ptr @kx_str_cat(ptr %r.15045, ptr %ext.15049)
  %r.15052 = call ptr @kx_str_cat(ptr %r.15050, ptr @.str.278)
  %r.15053 = call i64 @Emit(i64 %t.15040, ptr %r.15052)
  %t.15054 = load ptr, ptr %ext.542
  %r.15056 = call ptr @kx_str_cat(ptr @.str.387, ptr %t.15054)
  store ptr %r.15056, ptr %fv.534
  br label %if.merge.15023
if.merge.15023:
  br label %if.merge.14974
if.merge.14974:
  br label %if.merge.14925
if.merge.14925:
  br label %if.merge.14876
if.merge.14876:
  br label %if.merge.14827
if.merge.14827:
  br label %if.merge.14778
if.merge.14778:
  %t.15057 = load i64, ptr %g.addr
  %t.15058 = load ptr, ptr %ml.532
  %r.15060 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.15058)
  %r.15061 = call i64 @Emit(i64 %t.15057, ptr %r.15060)
  %t.15062 = load i64, ptr %g.addr
  %t.15063 = load ptr, ptr %ml.532
  %r.15065 = call ptr @kx_str_cat(ptr %t.15063, ptr @.str.89)
  %r.15066 = call i64 @Emit(i64 %t.15062, ptr %r.15065)
  %t.15067 = load i64, ptr %g.addr
  %r.15068 = call i64 @kx_struct_get(i64 %t.15067, i32 4)
  %t.15069 = load i64, ptr %g.addr
  %r.15070 = call i64 @kx_struct_get(i64 %t.15069, i32 4)
  %ext.15072 = sext i32 0 to i64
  %r.15071 = call i64 @kx_list_get(i64 %r.15070, i64 %ext.15072)
  %ext.15073 = sext i32 1 to i64
  %t.15074 = add i64 %r.15071, %ext.15073
  %ext.15075 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15068, i64 %ext.15075, i64 %t.15074)
  %t.15076 = load i64, ptr %g.addr
  %r.15077 = call i64 @kx_struct_get(i64 %t.15076, i32 4)
  %ext.15079 = sext i32 0 to i64
  %r.15078 = call i64 @kx_list_get(i64 %r.15077, i64 %ext.15079)
  %r.15080 = call ptr @kx_int_str(i64 %r.15078)
  %r.15082 = call ptr @kx_str_cat(ptr @.str.495, ptr %r.15080)
  %t.543 = alloca ptr
  store ptr %r.15082, ptr %t.543
  %t.15083 = load i64, ptr %g.addr
  %t.15084 = load ptr, ptr %t.543
  %r.15086 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15084)
  %r.15088 = call ptr @kx_str_cat(ptr %r.15086, ptr @.str.496)
  %t.15089 = load ptr, ptr %tv.533
  %r.15090 = call i64 @XType(ptr %t.15089)
  %ext.15092 = call ptr @kx_int_str(i64 %r.15090)
  %r.15093 = call ptr @kx_str_cat(ptr %r.15088, ptr %ext.15092)
  %r.15095 = call ptr @kx_str_cat(ptr %r.15093, ptr @.str.262)
  %t.15096 = load ptr, ptr %tv.533
  %r.15097 = call i64 @XVal(ptr %t.15096)
  %ext.15099 = call ptr @kx_int_str(i64 %r.15097)
  %r.15100 = call ptr @kx_str_cat(ptr %r.15095, ptr %ext.15099)
  %r.15102 = call ptr @kx_str_cat(ptr %r.15100, ptr @.str.497)
  %t.15103 = load ptr, ptr %tl.530
  %r.15105 = call ptr @kx_str_cat(ptr %r.15102, ptr %t.15103)
  %r.15107 = call ptr @kx_str_cat(ptr %r.15105, ptr @.str.498)
  %t.15108 = load ptr, ptr %fv.534
  %r.15109 = call i64 @XVal(ptr %t.15108)
  %ext.15111 = call ptr @kx_int_str(i64 %r.15109)
  %r.15112 = call ptr @kx_str_cat(ptr %r.15107, ptr %ext.15111)
  %r.15114 = call ptr @kx_str_cat(ptr %r.15112, ptr @.str.497)
  %t.15115 = load ptr, ptr %el.531
  %r.15117 = call ptr @kx_str_cat(ptr %r.15114, ptr %t.15115)
  %r.15119 = call ptr @kx_str_cat(ptr %r.15117, ptr @.str.148)
  %r.15120 = call i64 @Emit(i64 %t.15083, ptr %r.15119)
  %t.15121 = load ptr, ptr %tv.533
  %r.15122 = call i64 @XType(ptr %t.15121)
  %ext.15124 = call ptr @kx_int_str(i64 %r.15122)
  %r.15125 = call ptr @kx_str_cat(ptr %ext.15124, ptr @.str.8)
  %t.15126 = load ptr, ptr %t.543
  %r.15128 = call ptr @kx_str_cat(ptr %r.15125, ptr %t.15126)
  ret ptr %r.15128
dead.15129:
  br label %if.merge.14619
if.merge.14619:
  %t.15130 = load i64, ptr %e.addr
  %r.15131 = call i64 @kx_struct_get(i64 %t.15130, i32 0)
  %field.15132 = inttoptr i64 %r.15131 to ptr
  %r.15134 = call i1 @kx_str_eq(ptr %field.15132, ptr @.str.139)
  br i1 %r.15134, label %if.then.15135, label %if.merge.15136
if.then.15135:
  %t.15137 = load i64, ptr %g.addr
  %t.15138 = load i64, ptr %arena.addr
  %t.15139 = load i64, ptr %e.addr
  %cast.15140 = sext i32 1 to i64
  %r.15141 = call i64 @Child(i64 %t.15138, i64 %t.15139, i64 %cast.15140)
  %t.15142 = load i64, ptr %arena.addr
  %r.15143 = call ptr @GenExpr(i64 %t.15137, i64 %r.15141, i64 %t.15142)
  %rhs.544 = alloca ptr
  store ptr %r.15143, ptr %rhs.544
  %t.15144 = load i64, ptr %arena.addr
  %t.15145 = load i64, ptr %e.addr
  %cast.15146 = sext i32 0 to i64
  %r.15147 = call i64 @Child(i64 %t.15144, i64 %t.15145, i64 %cast.15146)
  %lhs.545 = alloca i64
  store i64 %r.15147, ptr %lhs.545
  %t.15148 = load i64, ptr %lhs.545
  %ext.15150 = inttoptr i64 %t.15148 to ptr
  %r.15151 = call i1 @kx_str_eq(ptr %ext.15150, ptr @.str.92)
  %t.15152 = load i64, ptr %g.addr
  %r.15153 = call i64 @kx_struct_get(i64 %t.15152, i32 7)
  %t.15154 = load i64, ptr %lhs.545
  %r.15155 = call i1 @kx_map_has(i64 %r.15153, i64 %t.15154)
  %t.15156 = and i1 %r.15151, %r.15155
  br i1 %t.15156, label %if.then.15157, label %if.merge.15158
if.then.15157:
  %t.15159 = load i64, ptr %g.addr
  %r.15160 = call i64 @kx_struct_get(i64 %t.15159, i32 6)
  %t.15161 = load i64, ptr %lhs.545
  %r.15162 = call i64 @kx_list_get(i64 %r.15160, i64 %t.15161)
  %lhsType.546 = alloca i64
  store i64 %r.15162, ptr %lhsType.546
  %t.15163 = load ptr, ptr %rhs.544
  %r.15164 = call i64 @XType(ptr %t.15163)
  %rhsType.547 = alloca i64
  store i64 %r.15164, ptr %rhsType.547
  %t.15165 = load ptr, ptr %rhs.544
  %r.15166 = call i64 @XVal(ptr %t.15165)
  %rhsVal.548 = alloca i64
  store i64 %r.15166, ptr %rhsVal.548
  %t.15167 = load i64, ptr %lhsType.546
  %t.15168 = load i64, ptr %rhsType.547
  %t.15169 = icmp ne i64 %t.15167, %t.15168
  br i1 %t.15169, label %if.then.15170, label %if.merge.15171
if.then.15170:
  %t.15172 = load i64, ptr %lhsType.546
  %ext.15174 = inttoptr i64 %t.15172 to ptr
  %r.15175 = call i1 @kx_str_eq(ptr %ext.15174, ptr @.str.269)
  %t.15176 = load i64, ptr %rhsType.547
  %ext.15178 = inttoptr i64 %t.15176 to ptr
  %r.15179 = call i1 @kx_str_eq(ptr %ext.15178, ptr @.str.279)
  %t.15180 = and i1 %r.15175, %r.15179
  br i1 %t.15180, label %if.then.15181, label %if.else.15183
if.then.15181:
  %t.15184 = load i64, ptr %g.addr
  %r.15185 = call i64 @kx_struct_get(i64 %t.15184, i32 4)
  %t.15186 = load i64, ptr %g.addr
  %r.15187 = call i64 @kx_struct_get(i64 %t.15186, i32 4)
  %ext.15189 = sext i32 0 to i64
  %r.15188 = call i64 @kx_list_get(i64 %r.15187, i64 %ext.15189)
  %ext.15190 = sext i32 1 to i64
  %t.15191 = add i64 %r.15188, %ext.15190
  %ext.15192 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15185, i64 %ext.15192, i64 %t.15191)
  %t.15193 = load i64, ptr %g.addr
  %r.15194 = call i64 @kx_struct_get(i64 %t.15193, i32 4)
  %ext.15196 = sext i32 0 to i64
  %r.15195 = call i64 @kx_list_get(i64 %r.15194, i64 %ext.15196)
  %r.15197 = call ptr @kx_int_str(i64 %r.15195)
  %r.15199 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15197)
  %ext.549 = alloca ptr
  store ptr %r.15199, ptr %ext.549
  %t.15200 = load i64, ptr %g.addr
  %t.15201 = load ptr, ptr %ext.549
  %r.15203 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15201)
  %r.15205 = call ptr @kx_str_cat(ptr %r.15203, ptr @.str.275)
  %t.15206 = load i64, ptr %rhsVal.548
  %ext.15208 = call ptr @kx_int_str(i64 %t.15206)
  %r.15209 = call ptr @kx_str_cat(ptr %r.15205, ptr %ext.15208)
  %r.15211 = call ptr @kx_str_cat(ptr %r.15209, ptr @.str.274)
  %r.15212 = call i64 @Emit(i64 %t.15200, ptr %r.15211)
  %t.15213 = load ptr, ptr %ext.549
  %ptrtoint.15214 = ptrtoint ptr %t.15213 to i64
  store i64 %ptrtoint.15214, ptr %rhsVal.548
  %ptrtoint.15215 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.15215, ptr %rhsType.547
  br label %if.merge.15182
if.else.15183:
  %t.15216 = load i64, ptr %lhsType.546
  %ext.15218 = inttoptr i64 %t.15216 to ptr
  %r.15219 = call i1 @kx_str_eq(ptr %ext.15218, ptr @.str.279)
  %t.15220 = load i64, ptr %rhsType.547
  %ext.15222 = inttoptr i64 %t.15220 to ptr
  %r.15223 = call i1 @kx_str_eq(ptr %ext.15222, ptr @.str.269)
  %t.15224 = and i1 %r.15219, %r.15223
  br i1 %t.15224, label %if.then.15225, label %if.else.15227
if.then.15225:
  %t.15228 = load i64, ptr %g.addr
  %r.15229 = call i64 @kx_struct_get(i64 %t.15228, i32 4)
  %t.15230 = load i64, ptr %g.addr
  %r.15231 = call i64 @kx_struct_get(i64 %t.15230, i32 4)
  %ext.15233 = sext i32 0 to i64
  %r.15232 = call i64 @kx_list_get(i64 %r.15231, i64 %ext.15233)
  %ext.15234 = sext i32 1 to i64
  %t.15235 = add i64 %r.15232, %ext.15234
  %ext.15236 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15229, i64 %ext.15236, i64 %t.15235)
  %t.15237 = load i64, ptr %g.addr
  %r.15238 = call i64 @kx_struct_get(i64 %t.15237, i32 4)
  %ext.15240 = sext i32 0 to i64
  %r.15239 = call i64 @kx_list_get(i64 %r.15238, i64 %ext.15240)
  %r.15241 = call ptr @kx_int_str(i64 %r.15239)
  %r.15243 = call ptr @kx_str_cat(ptr @.str.499, ptr %r.15241)
  %trunc.550 = alloca ptr
  store ptr %r.15243, ptr %trunc.550
  %t.15244 = load i64, ptr %g.addr
  %t.15245 = load ptr, ptr %trunc.550
  %r.15247 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15245)
  %r.15249 = call ptr @kx_str_cat(ptr %r.15247, ptr @.str.493)
  %t.15250 = load i64, ptr %rhsVal.548
  %ext.15252 = call ptr @kx_int_str(i64 %t.15250)
  %r.15253 = call ptr @kx_str_cat(ptr %r.15249, ptr %ext.15252)
  %r.15255 = call ptr @kx_str_cat(ptr %r.15253, ptr @.str.494)
  %r.15256 = call i64 @Emit(i64 %t.15244, ptr %r.15255)
  %t.15257 = load ptr, ptr %trunc.550
  %ptrtoint.15258 = ptrtoint ptr %t.15257 to i64
  store i64 %ptrtoint.15258, ptr %rhsVal.548
  %ptrtoint.15259 = ptrtoint ptr @.str.279 to i64
  store i64 %ptrtoint.15259, ptr %rhsType.547
  br label %if.merge.15226
if.else.15227:
  %t.15260 = load i64, ptr %lhsType.546
  %ext.15262 = inttoptr i64 %t.15260 to ptr
  %r.15263 = call i1 @kx_str_eq(ptr %ext.15262, ptr @.str.271)
  %t.15264 = load i64, ptr %rhsType.547
  %ext.15266 = inttoptr i64 %t.15264 to ptr
  %r.15267 = call i1 @kx_str_eq(ptr %ext.15266, ptr @.str.269)
  %t.15268 = and i1 %r.15263, %r.15267
  br i1 %t.15268, label %if.then.15269, label %if.else.15271
if.then.15269:
  %t.15272 = load i64, ptr %g.addr
  %r.15273 = call i64 @kx_struct_get(i64 %t.15272, i32 4)
  %t.15274 = load i64, ptr %g.addr
  %r.15275 = call i64 @kx_struct_get(i64 %t.15274, i32 4)
  %ext.15277 = sext i32 0 to i64
  %r.15276 = call i64 @kx_list_get(i64 %r.15275, i64 %ext.15277)
  %ext.15278 = sext i32 1 to i64
  %t.15279 = add i64 %r.15276, %ext.15278
  %ext.15280 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15273, i64 %ext.15280, i64 %t.15279)
  %t.15281 = load i64, ptr %g.addr
  %r.15282 = call i64 @kx_struct_get(i64 %t.15281, i32 4)
  %ext.15284 = sext i32 0 to i64
  %r.15283 = call i64 @kx_list_get(i64 %r.15282, i64 %ext.15284)
  %r.15285 = call ptr @kx_int_str(i64 %r.15283)
  %r.15287 = call ptr @kx_str_cat(ptr @.str.500, ptr %r.15285)
  %cast.551 = alloca ptr
  store ptr %r.15287, ptr %cast.551
  %t.15288 = load i64, ptr %g.addr
  %t.15289 = load ptr, ptr %cast.551
  %r.15291 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15289)
  %r.15293 = call ptr @kx_str_cat(ptr %r.15291, ptr @.str.277)
  %t.15294 = load i64, ptr %rhsVal.548
  %ext.15296 = call ptr @kx_int_str(i64 %t.15294)
  %r.15297 = call ptr @kx_str_cat(ptr %r.15293, ptr %ext.15296)
  %r.15299 = call ptr @kx_str_cat(ptr %r.15297, ptr @.str.278)
  %r.15300 = call i64 @Emit(i64 %t.15288, ptr %r.15299)
  %t.15301 = load ptr, ptr %cast.551
  %ptrtoint.15302 = ptrtoint ptr %t.15301 to i64
  store i64 %ptrtoint.15302, ptr %rhsVal.548
  %ptrtoint.15303 = ptrtoint ptr @.str.271 to i64
  store i64 %ptrtoint.15303, ptr %rhsType.547
  br label %if.merge.15270
if.else.15271:
  %t.15304 = load i64, ptr %lhsType.546
  %ext.15306 = inttoptr i64 %t.15304 to ptr
  %r.15307 = call i1 @kx_str_eq(ptr %ext.15306, ptr @.str.269)
  %t.15308 = load i64, ptr %rhsType.547
  %ext.15310 = inttoptr i64 %t.15308 to ptr
  %r.15311 = call i1 @kx_str_eq(ptr %ext.15310, ptr @.str.271)
  %t.15312 = and i1 %r.15307, %r.15311
  br i1 %t.15312, label %if.then.15313, label %if.merge.15314
if.then.15313:
  %t.15315 = load i64, ptr %g.addr
  %r.15316 = call i64 @kx_struct_get(i64 %t.15315, i32 4)
  %t.15317 = load i64, ptr %g.addr
  %r.15318 = call i64 @kx_struct_get(i64 %t.15317, i32 4)
  %ext.15320 = sext i32 0 to i64
  %r.15319 = call i64 @kx_list_get(i64 %r.15318, i64 %ext.15320)
  %ext.15321 = sext i32 1 to i64
  %t.15322 = add i64 %r.15319, %ext.15321
  %ext.15323 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15316, i64 %ext.15323, i64 %t.15322)
  %t.15324 = load i64, ptr %g.addr
  %r.15325 = call i64 @kx_struct_get(i64 %t.15324, i32 4)
  %ext.15327 = sext i32 0 to i64
  %r.15326 = call i64 @kx_list_get(i64 %r.15325, i64 %ext.15327)
  %r.15328 = call ptr @kx_int_str(i64 %r.15326)
  %r.15330 = call ptr @kx_str_cat(ptr @.str.501, ptr %r.15328)
  %cast.552 = alloca ptr
  store ptr %r.15330, ptr %cast.552
  %t.15331 = load i64, ptr %g.addr
  %t.15332 = load ptr, ptr %cast.552
  %r.15334 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15332)
  %r.15336 = call ptr @kx_str_cat(ptr %r.15334, ptr @.str.273)
  %t.15337 = load i64, ptr %rhsVal.548
  %ext.15339 = call ptr @kx_int_str(i64 %t.15337)
  %r.15340 = call ptr @kx_str_cat(ptr %r.15336, ptr %ext.15339)
  %r.15342 = call ptr @kx_str_cat(ptr %r.15340, ptr @.str.274)
  %r.15343 = call i64 @Emit(i64 %t.15331, ptr %r.15342)
  %t.15344 = load ptr, ptr %cast.552
  %ptrtoint.15345 = ptrtoint ptr %t.15344 to i64
  store i64 %ptrtoint.15345, ptr %rhsVal.548
  %ptrtoint.15346 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.15346, ptr %rhsType.547
  br label %if.merge.15314
if.merge.15314:
  br label %if.merge.15270
if.merge.15270:
  br label %if.merge.15226
if.merge.15226:
  br label %if.merge.15182
if.merge.15182:
  br label %if.merge.15171
if.merge.15171:
  %t.15347 = load i64, ptr %g.addr
  %t.15348 = load i64, ptr %rhsType.547
  %ext.15350 = call ptr @kx_int_str(i64 %t.15348)
  %r.15351 = call ptr @kx_str_cat(ptr @.str.502, ptr %ext.15350)
  %r.15353 = call ptr @kx_str_cat(ptr %r.15351, ptr @.str.8)
  %t.15354 = load i64, ptr %rhsVal.548
  %ext.15356 = call ptr @kx_int_str(i64 %t.15354)
  %r.15357 = call ptr @kx_str_cat(ptr %r.15353, ptr %ext.15356)
  %r.15359 = call ptr @kx_str_cat(ptr %r.15357, ptr @.str.396)
  %t.15360 = load i64, ptr %g.addr
  %r.15361 = call i64 @kx_struct_get(i64 %t.15360, i32 7)
  %t.15362 = load i64, ptr %lhs.545
  %r.15363 = call i64 @kx_list_get(i64 %r.15361, i64 %t.15362)
  %ext.15365 = call ptr @kx_int_str(i64 %r.15363)
  %r.15366 = call ptr @kx_str_cat(ptr %r.15359, ptr %ext.15365)
  %r.15367 = call i64 @Emit(i64 %t.15347, ptr %r.15366)
  %t.15368 = load i64, ptr %lhsType.546
  %ext.15370 = call ptr @kx_int_str(i64 %t.15368)
  %r.15371 = call ptr @kx_str_cat(ptr %ext.15370, ptr @.str.8)
  %t.15372 = load i64, ptr %rhsVal.548
  %ext.15374 = call ptr @kx_int_str(i64 %t.15372)
  %r.15375 = call ptr @kx_str_cat(ptr %r.15371, ptr %ext.15374)
  ret ptr %r.15375
dead.15376:
  br label %if.merge.15158
if.merge.15158:
  %t.15377 = load ptr, ptr %rhs.544
  ret ptr %t.15377
dead.15378:
  br label %if.merge.15136
if.merge.15136:
  ret ptr @.str.393
dead.15379:
  ret ptr null
}

define i64 @GenStmt(i64 %g, i64 %s, i64 %arena) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %s.addr = alloca i64
  store i64 %s, ptr %s.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %t.15380 = load i64, ptr %s.addr
  %r.15381 = call i64 @kx_struct_get(i64 %t.15380, i32 0)
  %field.15382 = inttoptr i64 %r.15381 to ptr
  %r.15384 = call i1 @kx_str_eq(ptr %field.15382, ptr @.str.161)
  br i1 %r.15384, label %if.then.15385, label %if.merge.15386
if.then.15385:
  %t.15387 = load i64, ptr %arena.addr
  %t.15388 = load i64, ptr %s.addr
  %cast.15389 = sext i32 0 to i64
  %r.15390 = call i64 @Child(i64 %t.15387, i64 %t.15388, i64 %cast.15389)
  %r.15391 = call i64 @kx_struct_get(i64 %r.15390, i32 1)
  %field.15392 = inttoptr i64 %r.15391 to ptr
  %nm.553 = alloca ptr
  store ptr %field.15392, ptr %nm.553
  %t.15393 = load i64, ptr %g.addr
  %t.15394 = load i64, ptr %arena.addr
  %t.15395 = load i64, ptr %s.addr
  %cast.15396 = sext i32 1 to i64
  %r.15397 = call i64 @Child(i64 %t.15394, i64 %t.15395, i64 %cast.15396)
  %t.15398 = load i64, ptr %arena.addr
  %r.15399 = call ptr @GenExpr(i64 %t.15393, i64 %r.15397, i64 %t.15398)
  %rhs.554 = alloca ptr
  store ptr %r.15399, ptr %rhs.554
  %t.15400 = load ptr, ptr %rhs.554
  %r.15401 = call i64 @XType(ptr %t.15400)
  %rt.555 = alloca i64
  store i64 %r.15401, ptr %rt.555
  %t.15402 = load ptr, ptr %rhs.554
  %r.15403 = call i64 @XVal(ptr %t.15402)
  %rv.556 = alloca i64
  store i64 %r.15403, ptr %rv.556
  %t.15404 = load ptr, ptr %nm.553
  %r.15406 = call ptr @kx_str_cat(ptr %t.15404, ptr @.str.60)
  %t.15407 = load i64, ptr %g.addr
  %r.15408 = call i64 @kx_struct_get(i64 %t.15407, i32 5)
  %ext.15410 = sext i32 0 to i64
  %r.15409 = call i64 @kx_list_get(i64 %r.15408, i64 %ext.15410)
  %r.15411 = call ptr @kx_int_str(i64 %r.15409)
  %r.15413 = call ptr @kx_str_cat(ptr %r.15406, ptr %r.15411)
  %uniqueNm.557 = alloca ptr
  store ptr %r.15413, ptr %uniqueNm.557
  %t.15414 = load i64, ptr %g.addr
  %r.15415 = call i64 @kx_struct_get(i64 %t.15414, i32 5)
  %t.15416 = load i64, ptr %g.addr
  %r.15417 = call i64 @kx_struct_get(i64 %t.15416, i32 5)
  %ext.15419 = sext i32 0 to i64
  %r.15418 = call i64 @kx_list_get(i64 %r.15417, i64 %ext.15419)
  %ext.15420 = sext i32 1 to i64
  %t.15421 = add i64 %r.15418, %ext.15420
  %ext.15422 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15415, i64 %ext.15422, i64 %t.15421)
  %t.15423 = load i64, ptr %arena.addr
  %t.15424 = load i64, ptr %s.addr
  %cast.15425 = sext i32 1 to i64
  %r.15426 = call i64 @Child(i64 %t.15423, i64 %t.15424, i64 %cast.15425)
  %r.15427 = call i64 @kx_struct_get(i64 %r.15426, i32 0)
  %field.15428 = inttoptr i64 %r.15427 to ptr
  %r.15430 = call i1 @kx_str_eq(ptr %field.15428, ptr @.str.93)
  br i1 %r.15430, label %if.then.15431, label %if.merge.15432
if.then.15431:
  %t.15433 = load i64, ptr %arena.addr
  %t.15434 = load i64, ptr %s.addr
  %cast.15435 = sext i32 1 to i64
  %r.15436 = call i64 @Child(i64 %t.15433, i64 %t.15434, i64 %cast.15435)
  %r.15437 = call i64 @kx_struct_get(i64 %r.15436, i32 1)
  %field.15438 = inttoptr i64 %r.15437 to ptr
  %structName.558 = alloca ptr
  store ptr %field.15438, ptr %structName.558
  %t.15439 = load i64, ptr %g.addr
  %r.15440 = call i64 @kx_struct_get(i64 %t.15439, i32 8)
  %t.15441 = load ptr, ptr %structName.558
  %c.15442 = ptrtoint ptr %t.15441 to i64
  %r.15443 = call i1 @kx_map_has(i64 %r.15440, i64 %c.15442)
  br i1 %r.15443, label %if.then.15444, label %if.merge.15445
if.then.15444:
  %t.15446 = load i64, ptr %g.addr
  %t.15447 = load ptr, ptr %uniqueNm.557
  %r.15449 = call ptr @kx_str_cat(ptr @.str.503, ptr %t.15447)
  %r.15451 = call ptr @kx_str_cat(ptr %r.15449, ptr @.str.437)
  %r.15452 = call i64 @Emit(i64 %t.15446, ptr %r.15451)
  %t.15453 = load i64, ptr %g.addr
  %t.15454 = load i64, ptr %rv.556
  %ext.15456 = call ptr @kx_int_str(i64 %t.15454)
  %r.15457 = call ptr @kx_str_cat(ptr @.str.428, ptr %ext.15456)
  %r.15459 = call ptr @kx_str_cat(ptr %r.15457, ptr @.str.504)
  %t.15460 = load ptr, ptr %uniqueNm.557
  %r.15462 = call ptr @kx_str_cat(ptr %r.15459, ptr %t.15460)
  %r.15463 = call i64 @Emit(i64 %t.15453, ptr %r.15462)
  %t.15464 = load i64, ptr %g.addr
  %r.15465 = call i64 @kx_struct_get(i64 %t.15464, i32 6)
  %t.15466 = load ptr, ptr %nm.553
  %t.15467 = load ptr, ptr %structName.558
  %r.15469 = call ptr @kx_str_cat(ptr @.str.286, ptr %t.15467)
  %c.15470 = ptrtoint ptr %t.15466 to i64
  %c.15471 = ptrtoint ptr %r.15469 to i64
  call void @kx_map_set(i64 %r.15465, i64 %c.15470, i64 %c.15471)
  %t.15472 = load i64, ptr %g.addr
  %r.15473 = call i64 @kx_struct_get(i64 %t.15472, i32 7)
  %t.15474 = load ptr, ptr %nm.553
  %t.15475 = load ptr, ptr %uniqueNm.557
  %r.15477 = call ptr @kx_str_cat(ptr @.str.123, ptr %t.15475)
  %c.15478 = ptrtoint ptr %t.15474 to i64
  %c.15479 = ptrtoint ptr %r.15477 to i64
  call void @kx_map_set(i64 %r.15473, i64 %c.15478, i64 %c.15479)
  %ext.15480 = sext i32 0 to i64
  ret i64 %ext.15480
dead.15481:
  br label %if.merge.15445
if.merge.15445:
  br label %if.merge.15432
if.merge.15432:
  %t.15482 = load i64, ptr %g.addr
  %t.15483 = load ptr, ptr %uniqueNm.557
  %r.15485 = call ptr @kx_str_cat(ptr @.str.503, ptr %t.15483)
  %r.15487 = call ptr @kx_str_cat(ptr %r.15485, ptr @.str.505)
  %t.15488 = load i64, ptr %rt.555
  %ext.15490 = call ptr @kx_int_str(i64 %t.15488)
  %r.15491 = call ptr @kx_str_cat(ptr %r.15487, ptr %ext.15490)
  %r.15492 = call i64 @Emit(i64 %t.15482, ptr %r.15491)
  %t.15493 = load i64, ptr %g.addr
  %t.15494 = load i64, ptr %rt.555
  %ext.15496 = call ptr @kx_int_str(i64 %t.15494)
  %r.15497 = call ptr @kx_str_cat(ptr @.str.502, ptr %ext.15496)
  %r.15499 = call ptr @kx_str_cat(ptr %r.15497, ptr @.str.8)
  %t.15500 = load i64, ptr %rv.556
  %ext.15502 = call ptr @kx_int_str(i64 %t.15500)
  %r.15503 = call ptr @kx_str_cat(ptr %r.15499, ptr %ext.15502)
  %r.15505 = call ptr @kx_str_cat(ptr %r.15503, ptr @.str.504)
  %t.15506 = load ptr, ptr %uniqueNm.557
  %r.15508 = call ptr @kx_str_cat(ptr %r.15505, ptr %t.15506)
  %r.15509 = call i64 @Emit(i64 %t.15493, ptr %r.15508)
  %t.15510 = load i64, ptr %g.addr
  %r.15511 = call i64 @kx_struct_get(i64 %t.15510, i32 6)
  %t.15512 = load ptr, ptr %nm.553
  %t.15513 = load i64, ptr %rt.555
  %c.15514 = ptrtoint ptr %t.15512 to i64
  call void @kx_map_set(i64 %r.15511, i64 %c.15514, i64 %t.15513)
  %t.15515 = load i64, ptr %g.addr
  %r.15516 = call i64 @kx_struct_get(i64 %t.15515, i32 7)
  %t.15517 = load ptr, ptr %nm.553
  %t.15518 = load ptr, ptr %uniqueNm.557
  %r.15520 = call ptr @kx_str_cat(ptr @.str.123, ptr %t.15518)
  %c.15521 = ptrtoint ptr %t.15517 to i64
  %c.15522 = ptrtoint ptr %r.15520 to i64
  call void @kx_map_set(i64 %r.15516, i64 %c.15521, i64 %c.15522)
  %t.15523 = load i64, ptr %arena.addr
  %t.15524 = load i64, ptr %s.addr
  %cast.15525 = sext i32 1 to i64
  %r.15526 = call i64 @Child(i64 %t.15523, i64 %t.15524, i64 %cast.15525)
  %rhsNode.559 = alloca i64
  store i64 %r.15526, ptr %rhsNode.559
  %t.15527 = load i64, ptr %rhsNode.559
  %ext.15529 = inttoptr i64 %t.15527 to ptr
  %r.15530 = call i1 @kx_str_eq(ptr %ext.15529, ptr @.str.103)
  %t.15531 = load i64, ptr %rhsNode.559
  %r.15532 = call i64 @kx_list_size(i64 %t.15531)
  %ext.15533 = sext i32 0 to i64
  %t.15534 = icmp sgt i64 %r.15532, %ext.15533
  %t.15535 = and i1 %r.15530, %t.15534
  br i1 %t.15535, label %if.then.15536, label %if.merge.15537
if.then.15536:
  %t.15538 = load i64, ptr %arena.addr
  %t.15539 = load i64, ptr %rhsNode.559
  %cast.15540 = sext i32 0 to i64
  %r.15541 = call i64 @Child(i64 %t.15538, i64 %t.15539, i64 %cast.15540)
  %callee.560 = alloca i64
  store i64 %r.15541, ptr %callee.560
  %t.15542 = load i64, ptr %callee.560
  %ext.15544 = inttoptr i64 %t.15542 to ptr
  %r.15545 = call i1 @kx_str_eq(ptr %ext.15544, ptr @.str.92)
  %t.15546 = load i64, ptr %callee.560
  %ext.15548 = inttoptr i64 %t.15546 to ptr
  %r.15549 = call i1 @kx_str_eq(ptr %ext.15548, ptr @.str.314)
  %t.15550 = and i1 %r.15545, %r.15549
  %t.15551 = load i64, ptr %rhsNode.559
  %r.15552 = call i64 @kx_list_size(i64 %t.15551)
  %ext.15553 = sext i32 1 to i64
  %t.15554 = icmp sgt i64 %r.15552, %ext.15553
  %t.15555 = and i1 %t.15550, %t.15554
  br i1 %t.15555, label %if.then.15556, label %if.merge.15557
if.then.15556:
  %t.15558 = load i64, ptr %arena.addr
  %t.15559 = load i64, ptr %rhsNode.559
  %cast.15560 = sext i32 1 to i64
  %r.15561 = call i64 @Child(i64 %t.15558, i64 %t.15559, i64 %cast.15560)
  %ta.561 = alloca i64
  store i64 %r.15561, ptr %ta.561
  %t.15562 = load i64, ptr %ta.561
  %ext.15564 = inttoptr i64 %t.15562 to ptr
  %r.15565 = call i1 @kx_str_eq(ptr %ext.15564, ptr @.str.104)
  br i1 %r.15565, label %if.then.15566, label %if.merge.15567
if.then.15566:
  %t.15568 = load i64, ptr %g.addr
  %r.15569 = call i64 @kx_struct_get(i64 %t.15568, i32 16)
  %t.15570 = load ptr, ptr %nm.553
  %t.15571 = load i64, ptr %ta.561
  %c.15572 = ptrtoint ptr %t.15570 to i64
  call void @kx_map_set(i64 %r.15569, i64 %c.15572, i64 %t.15571)
  br label %if.merge.15567
if.merge.15567:
  br label %if.merge.15557
if.merge.15557:
  br label %if.merge.15537
if.merge.15537:
  %ext.15573 = sext i32 0 to i64
  ret i64 %ext.15573
dead.15574:
  br label %if.merge.15386
if.merge.15386:
  %t.15575 = load i64, ptr %s.addr
  %r.15576 = call i64 @kx_struct_get(i64 %t.15575, i32 0)
  %field.15577 = inttoptr i64 %r.15576 to ptr
  %r.15579 = call i1 @kx_str_eq(ptr %field.15577, ptr @.str.198)
  br i1 %r.15579, label %if.then.15580, label %if.merge.15581
if.then.15580:
  %t.15582 = load i64, ptr %g.addr
  %t.15583 = load i64, ptr %arena.addr
  %t.15584 = load i64, ptr %s.addr
  %cast.15585 = sext i32 0 to i64
  %r.15586 = call i64 @Child(i64 %t.15583, i64 %t.15584, i64 %cast.15585)
  %t.15587 = load i64, ptr %arena.addr
  %r.15588 = call ptr @GenExpr(i64 %t.15582, i64 %r.15586, i64 %t.15587)
  %ext.15589 = sext i32 0 to i64
  ret i64 %ext.15589
dead.15590:
  br label %if.merge.15581
if.merge.15581:
  %t.15591 = load i64, ptr %s.addr
  %r.15592 = call i64 @kx_struct_get(i64 %t.15591, i32 0)
  %field.15593 = inttoptr i64 %r.15592 to ptr
  %r.15595 = call i1 @kx_str_eq(ptr %field.15593, ptr @.str.39)
  br i1 %r.15595, label %if.then.15596, label %if.merge.15597
if.then.15596:
  %t.15598 = load i64, ptr %s.addr
  %r.15599 = call i64 @kx_struct_get(i64 %t.15598, i32 4)
  %r.15600 = call i64 @kx_list_size(i64 %r.15599)
  %ext.15601 = sext i32 0 to i64
  %t.15602 = icmp sgt i64 %r.15600, %ext.15601
  br i1 %t.15602, label %if.then.15603, label %if.else.15605
if.then.15603:
  %t.15606 = load i64, ptr %g.addr
  %t.15607 = load i64, ptr %arena.addr
  %t.15608 = load i64, ptr %s.addr
  %cast.15609 = sext i32 0 to i64
  %r.15610 = call i64 @Child(i64 %t.15607, i64 %t.15608, i64 %cast.15609)
  %t.15611 = load i64, ptr %arena.addr
  %r.15612 = call ptr @GenExpr(i64 %t.15606, i64 %r.15610, i64 %t.15611)
  %v.562 = alloca ptr
  store ptr %r.15612, ptr %v.562
  %t.15613 = load ptr, ptr %v.562
  %r.15614 = call i64 @XType(ptr %t.15613)
  %vt.563 = alloca i64
  store i64 %r.15614, ptr %vt.563
  %t.15615 = load ptr, ptr %v.562
  %r.15616 = call i64 @XVal(ptr %t.15615)
  %vv.564 = alloca i64
  store i64 %r.15616, ptr %vv.564
  %t.15617 = load i64, ptr %g.addr
  %r.15618 = call i64 @kx_struct_get(i64 %t.15617, i32 10)
  %ext.15620 = inttoptr i64 %r.15618 to ptr
  %r.15621 = call i1 @kx_str_eq(ptr %ext.15620, ptr @.str.269)
  %t.15622 = load i64, ptr %vt.563
  %ext.15624 = inttoptr i64 %t.15622 to ptr
  %r.15625 = call i1 @kx_str_eq(ptr %ext.15624, ptr @.str.280)
  %t.15626 = and i1 %r.15621, %r.15625
  br i1 %t.15626, label %if.then.15627, label %if.else.15629
if.then.15627:
  %t.15630 = load i64, ptr %g.addr
  %r.15631 = call i64 @kx_struct_get(i64 %t.15630, i32 4)
  %t.15632 = load i64, ptr %g.addr
  %r.15633 = call i64 @kx_struct_get(i64 %t.15632, i32 4)
  %ext.15635 = sext i32 0 to i64
  %r.15634 = call i64 @kx_list_get(i64 %r.15633, i64 %ext.15635)
  %ext.15636 = sext i32 1 to i64
  %t.15637 = add i64 %r.15634, %ext.15636
  %ext.15638 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15631, i64 %ext.15638, i64 %t.15637)
  %t.15639 = load i64, ptr %g.addr
  %r.15640 = call i64 @kx_struct_get(i64 %t.15639, i32 4)
  %ext.15642 = sext i32 0 to i64
  %r.15641 = call i64 @kx_list_get(i64 %r.15640, i64 %ext.15642)
  %r.15643 = call ptr @kx_int_str(i64 %r.15641)
  %r.15645 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15643)
  %ext.565 = alloca ptr
  store ptr %r.15645, ptr %ext.565
  %t.15646 = load i64, ptr %g.addr
  %t.15647 = load ptr, ptr %ext.565
  %r.15649 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15647)
  %r.15651 = call ptr @kx_str_cat(ptr %r.15649, ptr @.str.283)
  %t.15652 = load i64, ptr %vv.564
  %ext.15654 = call ptr @kx_int_str(i64 %t.15652)
  %r.15655 = call ptr @kx_str_cat(ptr %r.15651, ptr %ext.15654)
  %r.15657 = call ptr @kx_str_cat(ptr %r.15655, ptr @.str.274)
  %r.15658 = call i64 @Emit(i64 %t.15646, ptr %r.15657)
  %t.15659 = load ptr, ptr %ext.565
  %ptrtoint.15660 = ptrtoint ptr %t.15659 to i64
  store i64 %ptrtoint.15660, ptr %vv.564
  %ptrtoint.15661 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.15661, ptr %vt.563
  br label %if.merge.15628
if.else.15629:
  %t.15662 = load i64, ptr %g.addr
  %r.15663 = call i64 @kx_struct_get(i64 %t.15662, i32 10)
  %ext.15665 = inttoptr i64 %r.15663 to ptr
  %r.15666 = call i1 @kx_str_eq(ptr %ext.15665, ptr @.str.269)
  %t.15667 = load i64, ptr %vt.563
  %ext.15669 = inttoptr i64 %t.15667 to ptr
  %r.15670 = call i1 @kx_str_eq(ptr %ext.15669, ptr @.str.279)
  %t.15671 = and i1 %r.15666, %r.15670
  br i1 %t.15671, label %if.then.15672, label %if.else.15674
if.then.15672:
  %t.15675 = load i64, ptr %g.addr
  %r.15676 = call i64 @kx_struct_get(i64 %t.15675, i32 4)
  %t.15677 = load i64, ptr %g.addr
  %r.15678 = call i64 @kx_struct_get(i64 %t.15677, i32 4)
  %ext.15680 = sext i32 0 to i64
  %r.15679 = call i64 @kx_list_get(i64 %r.15678, i64 %ext.15680)
  %ext.15681 = sext i32 1 to i64
  %t.15682 = add i64 %r.15679, %ext.15681
  %ext.15683 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15676, i64 %ext.15683, i64 %t.15682)
  %t.15684 = load i64, ptr %g.addr
  %r.15685 = call i64 @kx_struct_get(i64 %t.15684, i32 4)
  %ext.15687 = sext i32 0 to i64
  %r.15686 = call i64 @kx_list_get(i64 %r.15685, i64 %ext.15687)
  %r.15688 = call ptr @kx_int_str(i64 %r.15686)
  %r.15690 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15688)
  %ext.566 = alloca ptr
  store ptr %r.15690, ptr %ext.566
  %t.15691 = load i64, ptr %g.addr
  %t.15692 = load ptr, ptr %ext.566
  %r.15694 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15692)
  %r.15696 = call ptr @kx_str_cat(ptr %r.15694, ptr @.str.275)
  %t.15697 = load i64, ptr %vv.564
  %ext.15699 = call ptr @kx_int_str(i64 %t.15697)
  %r.15700 = call ptr @kx_str_cat(ptr %r.15696, ptr %ext.15699)
  %r.15702 = call ptr @kx_str_cat(ptr %r.15700, ptr @.str.274)
  %r.15703 = call i64 @Emit(i64 %t.15691, ptr %r.15702)
  %t.15704 = load ptr, ptr %ext.566
  %ptrtoint.15705 = ptrtoint ptr %t.15704 to i64
  store i64 %ptrtoint.15705, ptr %vv.564
  %ptrtoint.15706 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.15706, ptr %vt.563
  br label %if.merge.15673
if.else.15674:
  %t.15707 = load i64, ptr %g.addr
  %r.15708 = call i64 @kx_struct_get(i64 %t.15707, i32 10)
  %ext.15710 = inttoptr i64 %r.15708 to ptr
  %r.15711 = call i1 @kx_str_eq(ptr %ext.15710, ptr @.str.269)
  %t.15712 = load i64, ptr %vt.563
  %ext.15714 = inttoptr i64 %t.15712 to ptr
  %r.15715 = call i1 @kx_str_eq(ptr %ext.15714, ptr @.str.271)
  %t.15716 = and i1 %r.15711, %r.15715
  br i1 %t.15716, label %if.then.15717, label %if.else.15719
if.then.15717:
  %t.15720 = load i64, ptr %g.addr
  %r.15721 = call i64 @kx_struct_get(i64 %t.15720, i32 4)
  %t.15722 = load i64, ptr %g.addr
  %r.15723 = call i64 @kx_struct_get(i64 %t.15722, i32 4)
  %ext.15725 = sext i32 0 to i64
  %r.15724 = call i64 @kx_list_get(i64 %r.15723, i64 %ext.15725)
  %ext.15726 = sext i32 1 to i64
  %t.15727 = add i64 %r.15724, %ext.15726
  %ext.15728 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15721, i64 %ext.15728, i64 %t.15727)
  %t.15729 = load i64, ptr %g.addr
  %r.15730 = call i64 @kx_struct_get(i64 %t.15729, i32 4)
  %ext.15732 = sext i32 0 to i64
  %r.15731 = call i64 @kx_list_get(i64 %r.15730, i64 %ext.15732)
  %r.15733 = call ptr @kx_int_str(i64 %r.15731)
  %r.15735 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15733)
  %ext.567 = alloca ptr
  store ptr %r.15735, ptr %ext.567
  %t.15736 = load i64, ptr %g.addr
  %t.15737 = load ptr, ptr %ext.567
  %r.15739 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15737)
  %r.15741 = call ptr @kx_str_cat(ptr %r.15739, ptr @.str.273)
  %t.15742 = load i64, ptr %vv.564
  %ext.15744 = call ptr @kx_int_str(i64 %t.15742)
  %r.15745 = call ptr @kx_str_cat(ptr %r.15741, ptr %ext.15744)
  %r.15747 = call ptr @kx_str_cat(ptr %r.15745, ptr @.str.274)
  %r.15748 = call i64 @Emit(i64 %t.15736, ptr %r.15747)
  %t.15749 = load ptr, ptr %ext.567
  %ptrtoint.15750 = ptrtoint ptr %t.15749 to i64
  store i64 %ptrtoint.15750, ptr %vv.564
  %ptrtoint.15751 = ptrtoint ptr @.str.269 to i64
  store i64 %ptrtoint.15751, ptr %vt.563
  br label %if.merge.15718
if.else.15719:
  %t.15752 = load i64, ptr %g.addr
  %r.15753 = call i64 @kx_struct_get(i64 %t.15752, i32 10)
  %ext.15755 = inttoptr i64 %r.15753 to ptr
  %r.15756 = call i1 @kx_str_eq(ptr %ext.15755, ptr @.str.280)
  %t.15757 = load i64, ptr %vt.563
  %ext.15759 = inttoptr i64 %t.15757 to ptr
  %r.15760 = call i1 @kx_str_eq(ptr %ext.15759, ptr @.str.269)
  %t.15761 = and i1 %r.15756, %r.15760
  br i1 %t.15761, label %if.then.15762, label %if.else.15764
if.then.15762:
  %t.15765 = load i64, ptr %g.addr
  %r.15766 = call i64 @kx_struct_get(i64 %t.15765, i32 4)
  %t.15767 = load i64, ptr %g.addr
  %r.15768 = call i64 @kx_struct_get(i64 %t.15767, i32 4)
  %ext.15770 = sext i32 0 to i64
  %r.15769 = call i64 @kx_list_get(i64 %r.15768, i64 %ext.15770)
  %ext.15771 = sext i32 1 to i64
  %t.15772 = add i64 %r.15769, %ext.15771
  %ext.15773 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15766, i64 %ext.15773, i64 %t.15772)
  %t.15774 = load i64, ptr %g.addr
  %r.15775 = call i64 @kx_struct_get(i64 %t.15774, i32 4)
  %ext.15777 = sext i32 0 to i64
  %r.15776 = call i64 @kx_list_get(i64 %r.15775, i64 %ext.15777)
  %r.15778 = call ptr @kx_int_str(i64 %r.15776)
  %r.15780 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15778)
  %ext.568 = alloca ptr
  store ptr %r.15780, ptr %ext.568
  %t.15781 = load i64, ptr %g.addr
  %t.15782 = load ptr, ptr %ext.568
  %r.15784 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15782)
  %r.15786 = call ptr @kx_str_cat(ptr %r.15784, ptr @.str.281)
  %t.15787 = load i64, ptr %vv.564
  %ext.15789 = call ptr @kx_int_str(i64 %t.15787)
  %r.15790 = call ptr @kx_str_cat(ptr %r.15786, ptr %ext.15789)
  %r.15792 = call ptr @kx_str_cat(ptr %r.15790, ptr @.str.282)
  %r.15793 = call i64 @Emit(i64 %t.15781, ptr %r.15792)
  %t.15794 = load ptr, ptr %ext.568
  %ptrtoint.15795 = ptrtoint ptr %t.15794 to i64
  store i64 %ptrtoint.15795, ptr %vv.564
  %ptrtoint.15796 = ptrtoint ptr @.str.280 to i64
  store i64 %ptrtoint.15796, ptr %vt.563
  br label %if.merge.15763
if.else.15764:
  %t.15797 = load i64, ptr %g.addr
  %r.15798 = call i64 @kx_struct_get(i64 %t.15797, i32 10)
  %ext.15800 = inttoptr i64 %r.15798 to ptr
  %r.15801 = call i1 @kx_str_eq(ptr %ext.15800, ptr @.str.279)
  %t.15802 = load i64, ptr %vt.563
  %ext.15804 = inttoptr i64 %t.15802 to ptr
  %r.15805 = call i1 @kx_str_eq(ptr %ext.15804, ptr @.str.269)
  %t.15806 = and i1 %r.15801, %r.15805
  br i1 %t.15806, label %if.then.15807, label %if.else.15809
if.then.15807:
  %t.15810 = load i64, ptr %g.addr
  %r.15811 = call i64 @kx_struct_get(i64 %t.15810, i32 4)
  %t.15812 = load i64, ptr %g.addr
  %r.15813 = call i64 @kx_struct_get(i64 %t.15812, i32 4)
  %ext.15815 = sext i32 0 to i64
  %r.15814 = call i64 @kx_list_get(i64 %r.15813, i64 %ext.15815)
  %ext.15816 = sext i32 1 to i64
  %t.15817 = add i64 %r.15814, %ext.15816
  %ext.15818 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15811, i64 %ext.15818, i64 %t.15817)
  %t.15819 = load i64, ptr %g.addr
  %r.15820 = call i64 @kx_struct_get(i64 %t.15819, i32 4)
  %ext.15822 = sext i32 0 to i64
  %r.15821 = call i64 @kx_list_get(i64 %r.15820, i64 %ext.15822)
  %r.15823 = call ptr @kx_int_str(i64 %r.15821)
  %r.15825 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15823)
  %ext.569 = alloca ptr
  store ptr %r.15825, ptr %ext.569
  %t.15826 = load i64, ptr %g.addr
  %t.15827 = load ptr, ptr %ext.569
  %r.15829 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15827)
  %r.15831 = call ptr @kx_str_cat(ptr %r.15829, ptr @.str.493)
  %t.15832 = load i64, ptr %vv.564
  %ext.15834 = call ptr @kx_int_str(i64 %t.15832)
  %r.15835 = call ptr @kx_str_cat(ptr %r.15831, ptr %ext.15834)
  %r.15837 = call ptr @kx_str_cat(ptr %r.15835, ptr @.str.494)
  %r.15838 = call i64 @Emit(i64 %t.15826, ptr %r.15837)
  %t.15839 = load ptr, ptr %ext.569
  %ptrtoint.15840 = ptrtoint ptr %t.15839 to i64
  store i64 %ptrtoint.15840, ptr %vv.564
  %ptrtoint.15841 = ptrtoint ptr @.str.279 to i64
  store i64 %ptrtoint.15841, ptr %vt.563
  br label %if.merge.15808
if.else.15809:
  %t.15842 = load i64, ptr %g.addr
  %r.15843 = call i64 @kx_struct_get(i64 %t.15842, i32 10)
  %ext.15845 = inttoptr i64 %r.15843 to ptr
  %r.15846 = call i1 @kx_str_eq(ptr %ext.15845, ptr @.str.279)
  %t.15847 = load i64, ptr %vt.563
  %ext.15849 = inttoptr i64 %t.15847 to ptr
  %r.15850 = call i1 @kx_str_eq(ptr %ext.15849, ptr @.str.280)
  %t.15851 = and i1 %r.15846, %r.15850
  br i1 %t.15851, label %if.then.15852, label %if.else.15854
if.then.15852:
  %t.15855 = load i64, ptr %g.addr
  %r.15856 = call i64 @kx_struct_get(i64 %t.15855, i32 4)
  %t.15857 = load i64, ptr %g.addr
  %r.15858 = call i64 @kx_struct_get(i64 %t.15857, i32 4)
  %ext.15860 = sext i32 0 to i64
  %r.15859 = call i64 @kx_list_get(i64 %r.15858, i64 %ext.15860)
  %ext.15861 = sext i32 1 to i64
  %t.15862 = add i64 %r.15859, %ext.15861
  %ext.15863 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15856, i64 %ext.15863, i64 %t.15862)
  %t.15864 = load i64, ptr %g.addr
  %r.15865 = call i64 @kx_struct_get(i64 %t.15864, i32 4)
  %ext.15867 = sext i32 0 to i64
  %r.15866 = call i64 @kx_list_get(i64 %r.15865, i64 %ext.15867)
  %r.15868 = call ptr @kx_int_str(i64 %r.15866)
  %r.15870 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15868)
  %ext.570 = alloca ptr
  store ptr %r.15870, ptr %ext.570
  %t.15871 = load i64, ptr %g.addr
  %t.15872 = load ptr, ptr %ext.570
  %r.15874 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15872)
  %r.15876 = call ptr @kx_str_cat(ptr %r.15874, ptr @.str.283)
  %t.15877 = load i64, ptr %vv.564
  %ext.15879 = call ptr @kx_int_str(i64 %t.15877)
  %r.15880 = call ptr @kx_str_cat(ptr %r.15876, ptr %ext.15879)
  %r.15882 = call ptr @kx_str_cat(ptr %r.15880, ptr @.str.494)
  %r.15883 = call i64 @Emit(i64 %t.15871, ptr %r.15882)
  %t.15884 = load ptr, ptr %ext.570
  %ptrtoint.15885 = ptrtoint ptr %t.15884 to i64
  store i64 %ptrtoint.15885, ptr %vv.564
  %ptrtoint.15886 = ptrtoint ptr @.str.279 to i64
  store i64 %ptrtoint.15886, ptr %vt.563
  br label %if.merge.15853
if.else.15854:
  %t.15887 = load i64, ptr %g.addr
  %r.15888 = call i64 @kx_struct_get(i64 %t.15887, i32 10)
  %ext.15890 = inttoptr i64 %r.15888 to ptr
  %r.15891 = call i1 @kx_str_eq(ptr %ext.15890, ptr @.str.271)
  %t.15892 = load i64, ptr %vt.563
  %ext.15894 = inttoptr i64 %t.15892 to ptr
  %r.15895 = call i1 @kx_str_eq(ptr %ext.15894, ptr @.str.269)
  %t.15896 = and i1 %r.15891, %r.15895
  br i1 %t.15896, label %if.then.15897, label %if.merge.15898
if.then.15897:
  %t.15899 = load i64, ptr %g.addr
  %r.15900 = call i64 @kx_struct_get(i64 %t.15899, i32 4)
  %t.15901 = load i64, ptr %g.addr
  %r.15902 = call i64 @kx_struct_get(i64 %t.15901, i32 4)
  %ext.15904 = sext i32 0 to i64
  %r.15903 = call i64 @kx_list_get(i64 %r.15902, i64 %ext.15904)
  %ext.15905 = sext i32 1 to i64
  %t.15906 = add i64 %r.15903, %ext.15905
  %ext.15907 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.15900, i64 %ext.15907, i64 %t.15906)
  %t.15908 = load i64, ptr %g.addr
  %r.15909 = call i64 @kx_struct_get(i64 %t.15908, i32 4)
  %ext.15911 = sext i32 0 to i64
  %r.15910 = call i64 @kx_list_get(i64 %r.15909, i64 %ext.15911)
  %r.15912 = call ptr @kx_int_str(i64 %r.15910)
  %r.15914 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.15912)
  %ext.571 = alloca ptr
  store ptr %r.15914, ptr %ext.571
  %t.15915 = load i64, ptr %g.addr
  %t.15916 = load ptr, ptr %ext.571
  %r.15918 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.15916)
  %r.15920 = call ptr @kx_str_cat(ptr %r.15918, ptr @.str.277)
  %t.15921 = load i64, ptr %vv.564
  %ext.15923 = call ptr @kx_int_str(i64 %t.15921)
  %r.15924 = call ptr @kx_str_cat(ptr %r.15920, ptr %ext.15923)
  %r.15926 = call ptr @kx_str_cat(ptr %r.15924, ptr @.str.278)
  %r.15927 = call i64 @Emit(i64 %t.15915, ptr %r.15926)
  %t.15928 = load ptr, ptr %ext.571
  %ptrtoint.15929 = ptrtoint ptr %t.15928 to i64
  store i64 %ptrtoint.15929, ptr %vv.564
  %ptrtoint.15930 = ptrtoint ptr @.str.271 to i64
  store i64 %ptrtoint.15930, ptr %vt.563
  br label %if.merge.15898
if.merge.15898:
  br label %if.merge.15853
if.merge.15853:
  br label %if.merge.15808
if.merge.15808:
  br label %if.merge.15763
if.merge.15763:
  br label %if.merge.15718
if.merge.15718:
  br label %if.merge.15673
if.merge.15673:
  br label %if.merge.15628
if.merge.15628:
  %t.15931 = load i64, ptr %g.addr
  %t.15932 = load i64, ptr %vt.563
  %ext.15934 = call ptr @kx_int_str(i64 %t.15932)
  %r.15935 = call ptr @kx_str_cat(ptr @.str.320, ptr %ext.15934)
  %r.15937 = call ptr @kx_str_cat(ptr %r.15935, ptr @.str.8)
  %t.15938 = load i64, ptr %vv.564
  %ext.15940 = call ptr @kx_int_str(i64 %t.15938)
  %r.15941 = call ptr @kx_str_cat(ptr %r.15937, ptr %ext.15940)
  %r.15942 = call i64 @Emit(i64 %t.15931, ptr %r.15941)
  br label %if.merge.15604
if.else.15605:
  %t.15943 = load i64, ptr %g.addr
  %r.15944 = call i64 @Emit(i64 %t.15943, ptr @.str.506)
  br label %if.merge.15604
if.merge.15604:
  %ext.15945 = sext i32 0 to i64
  ret i64 %ext.15945
dead.15946:
  br label %if.merge.15597
if.merge.15597:
  %t.15947 = load i64, ptr %s.addr
  %r.15948 = call i64 @kx_struct_get(i64 %t.15947, i32 0)
  %field.15949 = inttoptr i64 %r.15948 to ptr
  %r.15951 = call i1 @kx_str_eq(ptr %field.15949, ptr @.str.158)
  br i1 %r.15951, label %if.then.15952, label %if.merge.15953
if.then.15952:
  %i.572 = alloca i32
  store i32 0, ptr %i.572
  br label %for.cond.15954
for.cond.15954:
  %t.15958 = load i32, ptr %i.572
  %t.15959 = load i64, ptr %s.addr
  %r.15960 = call i64 @kx_struct_get(i64 %t.15959, i32 4)
  %r.15961 = call i64 @kx_list_size(i64 %r.15960)
  %ext.15962 = sext i32 %t.15958 to i64
  %t.15963 = icmp slt i64 %ext.15962, %r.15961
  br i1 %t.15963, label %for.body.15955, label %for.end.15957
for.body.15955:
  %t.15964 = load i64, ptr %g.addr
  %t.15965 = load i64, ptr %arena.addr
  %t.15966 = load i64, ptr %s.addr
  %t.15967 = load i32, ptr %i.572
  %cast.15968 = sext i32 %t.15967 to i64
  %r.15969 = call i64 @Child(i64 %t.15965, i64 %t.15966, i64 %cast.15968)
  %t.15970 = load i64, ptr %arena.addr
  %r.15971 = call i64 @GenStmt(i64 %t.15964, i64 %r.15969, i64 %t.15970)
  br label %for.inc.15956
for.inc.15956:
  %t.15972 = load i32, ptr %i.572
  %t.15973 = add i32 %t.15972, 1
  store i32 %t.15973, ptr %i.572
  br label %for.cond.15954
for.end.15957:
  %ext.15974 = sext i32 0 to i64
  ret i64 %ext.15974
dead.15975:
  br label %if.merge.15953
if.merge.15953:
  %t.15976 = load i64, ptr %s.addr
  %r.15977 = call i64 @kx_struct_get(i64 %t.15976, i32 0)
  %field.15978 = inttoptr i64 %r.15977 to ptr
  %r.15980 = call i1 @kx_str_eq(ptr %field.15978, ptr @.str.31)
  br i1 %r.15980, label %if.then.15981, label %if.merge.15982
if.then.15981:
  %t.15983 = load i64, ptr %g.addr
  %t.15984 = load i64, ptr %arena.addr
  %t.15985 = load i64, ptr %s.addr
  %cast.15986 = sext i32 0 to i64
  %r.15987 = call i64 @Child(i64 %t.15984, i64 %t.15985, i64 %cast.15986)
  %t.15988 = load i64, ptr %arena.addr
  %r.15989 = call ptr @GenExpr(i64 %t.15983, i64 %r.15987, i64 %t.15988)
  %c.573 = alloca ptr
  store ptr %r.15989, ptr %c.573
  %t.15990 = load ptr, ptr %c.573
  %r.15991 = call i64 @XVal(ptr %t.15990)
  %cv.574 = alloca i64
  store i64 %r.15991, ptr %cv.574
  %t.15992 = load ptr, ptr %c.573
  %r.15993 = call i64 @XType(ptr %t.15992)
  %ext.15995 = inttoptr i64 %r.15993 to ptr
  %r.15996 = call i1 @kx_str_eq(ptr %ext.15995, ptr @.str.269)
  br i1 %r.15996, label %if.then.15997, label %if.merge.15998
if.then.15997:
  %t.15999 = load i64, ptr %g.addr
  %r.16000 = call i64 @kx_struct_get(i64 %t.15999, i32 4)
  %t.16001 = load i64, ptr %g.addr
  %r.16002 = call i64 @kx_struct_get(i64 %t.16001, i32 4)
  %ext.16004 = sext i32 0 to i64
  %r.16003 = call i64 @kx_list_get(i64 %r.16002, i64 %ext.16004)
  %ext.16005 = sext i32 1 to i64
  %t.16006 = add i64 %r.16003, %ext.16005
  %ext.16007 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16000, i64 %ext.16007, i64 %t.16006)
  %t.16008 = load i64, ptr %g.addr
  %r.16009 = call i64 @kx_struct_get(i64 %t.16008, i32 4)
  %ext.16011 = sext i32 0 to i64
  %r.16010 = call i64 @kx_list_get(i64 %r.16009, i64 %ext.16011)
  %r.16012 = call ptr @kx_int_str(i64 %r.16010)
  %r.16014 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.16012)
  %ext.575 = alloca ptr
  store ptr %r.16014, ptr %ext.575
  %t.16015 = load i64, ptr %g.addr
  %t.16016 = load ptr, ptr %ext.575
  %r.16018 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16016)
  %r.16020 = call ptr @kx_str_cat(ptr %r.16018, ptr @.str.281)
  %t.16021 = load i64, ptr %cv.574
  %ext.16023 = call ptr @kx_int_str(i64 %t.16021)
  %r.16024 = call ptr @kx_str_cat(ptr %r.16020, ptr %ext.16023)
  %r.16026 = call ptr @kx_str_cat(ptr %r.16024, ptr @.str.282)
  %r.16027 = call i64 @Emit(i64 %t.16015, ptr %r.16026)
  %t.16028 = load ptr, ptr %ext.575
  %ptrtoint.16029 = ptrtoint ptr %t.16028 to i64
  store i64 %ptrtoint.16029, ptr %cv.574
  br label %if.merge.15998
if.merge.15998:
  %t.16030 = load i64, ptr %g.addr
  %r.16031 = call i64 @kx_struct_get(i64 %t.16030, i32 4)
  %t.16032 = load i64, ptr %g.addr
  %r.16033 = call i64 @kx_struct_get(i64 %t.16032, i32 4)
  %ext.16035 = sext i32 0 to i64
  %r.16034 = call i64 @kx_list_get(i64 %r.16033, i64 %ext.16035)
  %ext.16036 = sext i32 1 to i64
  %t.16037 = add i64 %r.16034, %ext.16036
  %ext.16038 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16031, i64 %ext.16038, i64 %t.16037)
  %t.16039 = load i64, ptr %g.addr
  %r.16040 = call i64 @kx_struct_get(i64 %t.16039, i32 4)
  %ext.16042 = sext i32 0 to i64
  %r.16041 = call i64 @kx_list_get(i64 %r.16040, i64 %ext.16042)
  %r.16043 = call ptr @kx_int_str(i64 %r.16041)
  %r.16045 = call ptr @kx_str_cat(ptr @.str.507, ptr %r.16043)
  %tl.576 = alloca ptr
  store ptr %r.16045, ptr %tl.576
  %t.16046 = load i64, ptr %g.addr
  %r.16047 = call i64 @kx_struct_get(i64 %t.16046, i32 4)
  %t.16048 = load i64, ptr %g.addr
  %r.16049 = call i64 @kx_struct_get(i64 %t.16048, i32 4)
  %ext.16051 = sext i32 0 to i64
  %r.16050 = call i64 @kx_list_get(i64 %r.16049, i64 %ext.16051)
  %ext.16052 = sext i32 1 to i64
  %t.16053 = add i64 %r.16050, %ext.16052
  %ext.16054 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16047, i64 %ext.16054, i64 %t.16053)
  %t.16055 = load i64, ptr %g.addr
  %r.16056 = call i64 @kx_struct_get(i64 %t.16055, i32 4)
  %ext.16058 = sext i32 0 to i64
  %r.16057 = call i64 @kx_list_get(i64 %r.16056, i64 %ext.16058)
  %r.16059 = call ptr @kx_int_str(i64 %r.16057)
  %r.16061 = call ptr @kx_str_cat(ptr @.str.508, ptr %r.16059)
  %ml.577 = alloca ptr
  store ptr %r.16061, ptr %ml.577
  %t.16062 = load i64, ptr %s.addr
  %r.16063 = call i64 @kx_struct_get(i64 %t.16062, i32 4)
  %r.16064 = call i64 @kx_list_size(i64 %r.16063)
  %ext.16065 = sext i32 2 to i64
  %t.16066 = icmp sgt i64 %r.16064, %ext.16065
  br i1 %t.16066, label %if.then.16067, label %if.else.16069
if.then.16067:
  %t.16070 = load i64, ptr %g.addr
  %r.16071 = call i64 @kx_struct_get(i64 %t.16070, i32 4)
  %t.16072 = load i64, ptr %g.addr
  %r.16073 = call i64 @kx_struct_get(i64 %t.16072, i32 4)
  %ext.16075 = sext i32 0 to i64
  %r.16074 = call i64 @kx_list_get(i64 %r.16073, i64 %ext.16075)
  %ext.16076 = sext i32 1 to i64
  %t.16077 = add i64 %r.16074, %ext.16076
  %ext.16078 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16071, i64 %ext.16078, i64 %t.16077)
  %t.16079 = load i64, ptr %g.addr
  %r.16080 = call i64 @kx_struct_get(i64 %t.16079, i32 4)
  %ext.16082 = sext i32 0 to i64
  %r.16081 = call i64 @kx_list_get(i64 %r.16080, i64 %ext.16082)
  %r.16083 = call ptr @kx_int_str(i64 %r.16081)
  %r.16085 = call ptr @kx_str_cat(ptr @.str.509, ptr %r.16083)
  %el.578 = alloca ptr
  store ptr %r.16085, ptr %el.578
  %t.16086 = load i64, ptr %g.addr
  %t.16087 = load i64, ptr %cv.574
  %ext.16089 = call ptr @kx_int_str(i64 %t.16087)
  %r.16090 = call ptr @kx_str_cat(ptr @.str.490, ptr %ext.16089)
  %r.16092 = call ptr @kx_str_cat(ptr %r.16090, ptr @.str.491)
  %t.16093 = load ptr, ptr %tl.576
  %r.16095 = call ptr @kx_str_cat(ptr %r.16092, ptr %t.16093)
  %r.16097 = call ptr @kx_str_cat(ptr %r.16095, ptr @.str.491)
  %t.16098 = load ptr, ptr %el.578
  %r.16100 = call ptr @kx_str_cat(ptr %r.16097, ptr %t.16098)
  %r.16101 = call i64 @Emit(i64 %t.16086, ptr %r.16100)
  %t.16102 = load i64, ptr %g.addr
  %t.16103 = load ptr, ptr %tl.576
  %r.16105 = call ptr @kx_str_cat(ptr %t.16103, ptr @.str.89)
  %r.16106 = call i64 @Emit(i64 %t.16102, ptr %r.16105)
  %t.16107 = load i64, ptr %g.addr
  %t.16108 = load i64, ptr %arena.addr
  %t.16109 = load i64, ptr %s.addr
  %cast.16110 = sext i32 1 to i64
  %r.16111 = call i64 @Child(i64 %t.16108, i64 %t.16109, i64 %cast.16110)
  %t.16112 = load i64, ptr %arena.addr
  %r.16113 = call i64 @GenStmt(i64 %t.16107, i64 %r.16111, i64 %t.16112)
  %t.16114 = load i64, ptr %g.addr
  %t.16115 = load ptr, ptr %ml.577
  %r.16117 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16115)
  %r.16118 = call i64 @Emit(i64 %t.16114, ptr %r.16117)
  %t.16119 = load i64, ptr %g.addr
  %t.16120 = load ptr, ptr %el.578
  %r.16122 = call ptr @kx_str_cat(ptr %t.16120, ptr @.str.89)
  %r.16123 = call i64 @Emit(i64 %t.16119, ptr %r.16122)
  %t.16124 = load i64, ptr %g.addr
  %t.16125 = load i64, ptr %arena.addr
  %t.16126 = load i64, ptr %s.addr
  %cast.16127 = sext i32 2 to i64
  %r.16128 = call i64 @Child(i64 %t.16125, i64 %t.16126, i64 %cast.16127)
  %t.16129 = load i64, ptr %arena.addr
  %r.16130 = call i64 @GenStmt(i64 %t.16124, i64 %r.16128, i64 %t.16129)
  %t.16131 = load i64, ptr %g.addr
  %t.16132 = load ptr, ptr %ml.577
  %r.16134 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16132)
  %r.16135 = call i64 @Emit(i64 %t.16131, ptr %r.16134)
  br label %if.merge.16068
if.else.16069:
  %t.16136 = load i64, ptr %g.addr
  %t.16137 = load i64, ptr %cv.574
  %ext.16139 = call ptr @kx_int_str(i64 %t.16137)
  %r.16140 = call ptr @kx_str_cat(ptr @.str.490, ptr %ext.16139)
  %r.16142 = call ptr @kx_str_cat(ptr %r.16140, ptr @.str.491)
  %t.16143 = load ptr, ptr %tl.576
  %r.16145 = call ptr @kx_str_cat(ptr %r.16142, ptr %t.16143)
  %r.16147 = call ptr @kx_str_cat(ptr %r.16145, ptr @.str.491)
  %t.16148 = load ptr, ptr %ml.577
  %r.16150 = call ptr @kx_str_cat(ptr %r.16147, ptr %t.16148)
  %r.16151 = call i64 @Emit(i64 %t.16136, ptr %r.16150)
  %t.16152 = load i64, ptr %g.addr
  %t.16153 = load ptr, ptr %tl.576
  %r.16155 = call ptr @kx_str_cat(ptr %t.16153, ptr @.str.89)
  %r.16156 = call i64 @Emit(i64 %t.16152, ptr %r.16155)
  %t.16157 = load i64, ptr %g.addr
  %t.16158 = load i64, ptr %arena.addr
  %t.16159 = load i64, ptr %s.addr
  %cast.16160 = sext i32 1 to i64
  %r.16161 = call i64 @Child(i64 %t.16158, i64 %t.16159, i64 %cast.16160)
  %t.16162 = load i64, ptr %arena.addr
  %r.16163 = call i64 @GenStmt(i64 %t.16157, i64 %r.16161, i64 %t.16162)
  %t.16164 = load i64, ptr %g.addr
  %t.16165 = load ptr, ptr %ml.577
  %r.16167 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16165)
  %r.16168 = call i64 @Emit(i64 %t.16164, ptr %r.16167)
  br label %if.merge.16068
if.merge.16068:
  %t.16169 = load i64, ptr %g.addr
  %t.16170 = load ptr, ptr %ml.577
  %r.16172 = call ptr @kx_str_cat(ptr %t.16170, ptr @.str.89)
  %r.16173 = call i64 @Emit(i64 %t.16169, ptr %r.16172)
  %ext.16174 = sext i32 0 to i64
  ret i64 %ext.16174
dead.16175:
  br label %if.merge.15982
if.merge.15982:
  %t.16176 = load i64, ptr %s.addr
  %r.16177 = call i64 @kx_struct_get(i64 %t.16176, i32 0)
  %field.16178 = inttoptr i64 %r.16177 to ptr
  %r.16180 = call i1 @kx_str_eq(ptr %field.16178, ptr @.str.33)
  br i1 %r.16180, label %if.then.16181, label %if.merge.16182
if.then.16181:
  %t.16183 = load i64, ptr %g.addr
  %r.16184 = call i64 @kx_struct_get(i64 %t.16183, i32 4)
  %t.16185 = load i64, ptr %g.addr
  %r.16186 = call i64 @kx_struct_get(i64 %t.16185, i32 4)
  %ext.16188 = sext i32 0 to i64
  %r.16187 = call i64 @kx_list_get(i64 %r.16186, i64 %ext.16188)
  %ext.16189 = sext i32 1 to i64
  %t.16190 = add i64 %r.16187, %ext.16189
  %ext.16191 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16184, i64 %ext.16191, i64 %t.16190)
  %t.16192 = load i64, ptr %g.addr
  %r.16193 = call i64 @kx_struct_get(i64 %t.16192, i32 4)
  %ext.16195 = sext i32 0 to i64
  %r.16194 = call i64 @kx_list_get(i64 %r.16193, i64 %ext.16195)
  %r.16196 = call ptr @kx_int_str(i64 %r.16194)
  %r.16198 = call ptr @kx_str_cat(ptr @.str.510, ptr %r.16196)
  %cl.579 = alloca ptr
  store ptr %r.16198, ptr %cl.579
  %t.16199 = load i64, ptr %g.addr
  %r.16200 = call i64 @kx_struct_get(i64 %t.16199, i32 4)
  %t.16201 = load i64, ptr %g.addr
  %r.16202 = call i64 @kx_struct_get(i64 %t.16201, i32 4)
  %ext.16204 = sext i32 0 to i64
  %r.16203 = call i64 @kx_list_get(i64 %r.16202, i64 %ext.16204)
  %ext.16205 = sext i32 1 to i64
  %t.16206 = add i64 %r.16203, %ext.16205
  %ext.16207 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16200, i64 %ext.16207, i64 %t.16206)
  %t.16208 = load i64, ptr %g.addr
  %r.16209 = call i64 @kx_struct_get(i64 %t.16208, i32 4)
  %ext.16211 = sext i32 0 to i64
  %r.16210 = call i64 @kx_list_get(i64 %r.16209, i64 %ext.16211)
  %r.16212 = call ptr @kx_int_str(i64 %r.16210)
  %r.16214 = call ptr @kx_str_cat(ptr @.str.511, ptr %r.16212)
  %bl.580 = alloca ptr
  store ptr %r.16214, ptr %bl.580
  %t.16215 = load i64, ptr %g.addr
  %r.16216 = call i64 @kx_struct_get(i64 %t.16215, i32 4)
  %t.16217 = load i64, ptr %g.addr
  %r.16218 = call i64 @kx_struct_get(i64 %t.16217, i32 4)
  %ext.16220 = sext i32 0 to i64
  %r.16219 = call i64 @kx_list_get(i64 %r.16218, i64 %ext.16220)
  %ext.16221 = sext i32 1 to i64
  %t.16222 = add i64 %r.16219, %ext.16221
  %ext.16223 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16216, i64 %ext.16223, i64 %t.16222)
  %t.16224 = load i64, ptr %g.addr
  %r.16225 = call i64 @kx_struct_get(i64 %t.16224, i32 4)
  %ext.16227 = sext i32 0 to i64
  %r.16226 = call i64 @kx_list_get(i64 %r.16225, i64 %ext.16227)
  %r.16228 = call ptr @kx_int_str(i64 %r.16226)
  %r.16230 = call ptr @kx_str_cat(ptr @.str.512, ptr %r.16228)
  %el.581 = alloca ptr
  store ptr %r.16230, ptr %el.581
  %t.16231 = load i64, ptr %g.addr
  %t.16232 = load ptr, ptr %cl.579
  %r.16234 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16232)
  %r.16235 = call i64 @Emit(i64 %t.16231, ptr %r.16234)
  %t.16236 = load i64, ptr %g.addr
  %t.16237 = load ptr, ptr %cl.579
  %r.16239 = call ptr @kx_str_cat(ptr %t.16237, ptr @.str.89)
  %r.16240 = call i64 @Emit(i64 %t.16236, ptr %r.16239)
  %t.16241 = load i64, ptr %g.addr
  %t.16242 = load i64, ptr %arena.addr
  %t.16243 = load i64, ptr %s.addr
  %cast.16244 = sext i32 0 to i64
  %r.16245 = call i64 @Child(i64 %t.16242, i64 %t.16243, i64 %cast.16244)
  %t.16246 = load i64, ptr %arena.addr
  %r.16247 = call ptr @GenExpr(i64 %t.16241, i64 %r.16245, i64 %t.16246)
  %c.582 = alloca ptr
  store ptr %r.16247, ptr %c.582
  %t.16248 = load ptr, ptr %c.582
  %r.16249 = call i64 @XVal(ptr %t.16248)
  %cv.583 = alloca i64
  store i64 %r.16249, ptr %cv.583
  %t.16250 = load ptr, ptr %c.582
  %r.16251 = call i64 @XType(ptr %t.16250)
  %ext.16253 = inttoptr i64 %r.16251 to ptr
  %r.16254 = call i1 @kx_str_eq(ptr %ext.16253, ptr @.str.269)
  br i1 %r.16254, label %if.then.16255, label %if.merge.16256
if.then.16255:
  %t.16257 = load i64, ptr %g.addr
  %r.16258 = call i64 @kx_struct_get(i64 %t.16257, i32 4)
  %t.16259 = load i64, ptr %g.addr
  %r.16260 = call i64 @kx_struct_get(i64 %t.16259, i32 4)
  %ext.16262 = sext i32 0 to i64
  %r.16261 = call i64 @kx_list_get(i64 %r.16260, i64 %ext.16262)
  %ext.16263 = sext i32 1 to i64
  %t.16264 = add i64 %r.16261, %ext.16263
  %ext.16265 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16258, i64 %ext.16265, i64 %t.16264)
  %t.16266 = load i64, ptr %g.addr
  %r.16267 = call i64 @kx_struct_get(i64 %t.16266, i32 4)
  %ext.16269 = sext i32 0 to i64
  %r.16268 = call i64 @kx_list_get(i64 %r.16267, i64 %ext.16269)
  %r.16270 = call ptr @kx_int_str(i64 %r.16268)
  %r.16272 = call ptr @kx_str_cat(ptr @.str.270, ptr %r.16270)
  %ext.584 = alloca ptr
  store ptr %r.16272, ptr %ext.584
  %t.16273 = load i64, ptr %g.addr
  %t.16274 = load ptr, ptr %ext.584
  %r.16276 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16274)
  %r.16278 = call ptr @kx_str_cat(ptr %r.16276, ptr @.str.281)
  %t.16279 = load i64, ptr %cv.583
  %ext.16281 = call ptr @kx_int_str(i64 %t.16279)
  %r.16282 = call ptr @kx_str_cat(ptr %r.16278, ptr %ext.16281)
  %r.16284 = call ptr @kx_str_cat(ptr %r.16282, ptr @.str.282)
  %r.16285 = call i64 @Emit(i64 %t.16273, ptr %r.16284)
  %t.16286 = load ptr, ptr %ext.584
  %ptrtoint.16287 = ptrtoint ptr %t.16286 to i64
  store i64 %ptrtoint.16287, ptr %cv.583
  br label %if.merge.16256
if.merge.16256:
  %t.16288 = load i64, ptr %g.addr
  %t.16289 = load i64, ptr %cv.583
  %ext.16291 = call ptr @kx_int_str(i64 %t.16289)
  %r.16292 = call ptr @kx_str_cat(ptr @.str.490, ptr %ext.16291)
  %r.16294 = call ptr @kx_str_cat(ptr %r.16292, ptr @.str.491)
  %t.16295 = load ptr, ptr %bl.580
  %r.16297 = call ptr @kx_str_cat(ptr %r.16294, ptr %t.16295)
  %r.16299 = call ptr @kx_str_cat(ptr %r.16297, ptr @.str.491)
  %t.16300 = load ptr, ptr %el.581
  %r.16302 = call ptr @kx_str_cat(ptr %r.16299, ptr %t.16300)
  %r.16303 = call i64 @Emit(i64 %t.16288, ptr %r.16302)
  %t.16304 = load i64, ptr %g.addr
  %t.16305 = load ptr, ptr %bl.580
  %r.16307 = call ptr @kx_str_cat(ptr %t.16305, ptr @.str.89)
  %r.16308 = call i64 @Emit(i64 %t.16304, ptr %r.16307)
  %t.16309 = load i64, ptr %g.addr
  %r.16310 = call i64 @kx_struct_get(i64 %t.16309, i32 14)
  %t.16311 = load ptr, ptr %el.581
  %ext.16312 = ptrtoint ptr %t.16311 to i64
  call void @kx_list_add(i64 %r.16310, i64 %ext.16312)
  %t.16313 = load i64, ptr %g.addr
  %r.16314 = call i64 @kx_struct_get(i64 %t.16313, i32 15)
  %t.16315 = load ptr, ptr %cl.579
  %ext.16316 = ptrtoint ptr %t.16315 to i64
  call void @kx_list_add(i64 %r.16314, i64 %ext.16316)
  %t.16317 = load i64, ptr %g.addr
  %t.16318 = load i64, ptr %arena.addr
  %t.16319 = load i64, ptr %s.addr
  %cast.16320 = sext i32 1 to i64
  %r.16321 = call i64 @Child(i64 %t.16318, i64 %t.16319, i64 %cast.16320)
  %t.16322 = load i64, ptr %arena.addr
  %r.16323 = call i64 @GenStmt(i64 %t.16317, i64 %r.16321, i64 %t.16322)
  %t.16324 = load i64, ptr %g.addr
  %r.16325 = call i64 @kx_struct_get(i64 %t.16324, i32 14)
  %t.16326 = load i64, ptr %g.addr
  %r.16327 = call i64 @kx_struct_get(i64 %t.16326, i32 14)
  %r.16328 = call i64 @kx_list_size(i64 %r.16327)
  %ext.16329 = sext i32 1 to i64
  %t.16330 = sub i64 %r.16328, %ext.16329
  call void @kx_list_remove_at(i64 %r.16325, i64 %t.16330)
  %t.16331 = load i64, ptr %g.addr
  %r.16332 = call i64 @kx_struct_get(i64 %t.16331, i32 15)
  %t.16333 = load i64, ptr %g.addr
  %r.16334 = call i64 @kx_struct_get(i64 %t.16333, i32 15)
  %r.16335 = call i64 @kx_list_size(i64 %r.16334)
  %ext.16336 = sext i32 1 to i64
  %t.16337 = sub i64 %r.16335, %ext.16336
  call void @kx_list_remove_at(i64 %r.16332, i64 %t.16337)
  %t.16338 = load i64, ptr %g.addr
  %t.16339 = load ptr, ptr %cl.579
  %r.16341 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16339)
  %r.16342 = call i64 @Emit(i64 %t.16338, ptr %r.16341)
  %t.16343 = load i64, ptr %g.addr
  %t.16344 = load ptr, ptr %el.581
  %r.16346 = call ptr @kx_str_cat(ptr %t.16344, ptr @.str.89)
  %r.16347 = call i64 @Emit(i64 %t.16343, ptr %r.16346)
  %ext.16348 = sext i32 0 to i64
  ret i64 %ext.16348
dead.16349:
  br label %if.merge.16182
if.merge.16182:
  %t.16350 = load i64, ptr %s.addr
  %r.16351 = call i64 @kx_struct_get(i64 %t.16350, i32 0)
  %field.16352 = inttoptr i64 %r.16351 to ptr
  %r.16354 = call i1 @kx_str_eq(ptr %field.16352, ptr @.str.34)
  br i1 %r.16354, label %if.then.16355, label %if.merge.16356
if.then.16355:
  %t.16357 = load i64, ptr %s.addr
  %r.16358 = call i64 @kx_struct_get(i64 %t.16357, i32 4)
  %r.16359 = call i64 @kx_list_size(i64 %r.16358)
  %ext.16360 = sext i32 1 to i64
  %t.16361 = sub i64 %r.16359, %ext.16360
  %bodyIdx.585 = alloca i64
  store i64 %t.16361, ptr %bodyIdx.585
  %t.16362 = load i64, ptr %g.addr
  %r.16363 = call i64 @kx_struct_get(i64 %t.16362, i32 4)
  %t.16364 = load i64, ptr %g.addr
  %r.16365 = call i64 @kx_struct_get(i64 %t.16364, i32 4)
  %ext.16367 = sext i32 0 to i64
  %r.16366 = call i64 @kx_list_get(i64 %r.16365, i64 %ext.16367)
  %ext.16368 = sext i32 1 to i64
  %t.16369 = add i64 %r.16366, %ext.16368
  %ext.16370 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16363, i64 %ext.16370, i64 %t.16369)
  %t.16371 = load i64, ptr %g.addr
  %r.16372 = call i64 @kx_struct_get(i64 %t.16371, i32 4)
  %ext.16374 = sext i32 0 to i64
  %r.16373 = call i64 @kx_list_get(i64 %r.16372, i64 %ext.16374)
  %r.16375 = call ptr @kx_int_str(i64 %r.16373)
  %r.16377 = call ptr @kx_str_cat(ptr @.str.513, ptr %r.16375)
  %condLabel.586 = alloca ptr
  store ptr %r.16377, ptr %condLabel.586
  %t.16378 = load i64, ptr %g.addr
  %r.16379 = call i64 @kx_struct_get(i64 %t.16378, i32 4)
  %t.16380 = load i64, ptr %g.addr
  %r.16381 = call i64 @kx_struct_get(i64 %t.16380, i32 4)
  %ext.16383 = sext i32 0 to i64
  %r.16382 = call i64 @kx_list_get(i64 %r.16381, i64 %ext.16383)
  %ext.16384 = sext i32 1 to i64
  %t.16385 = add i64 %r.16382, %ext.16384
  %ext.16386 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16379, i64 %ext.16386, i64 %t.16385)
  %t.16387 = load i64, ptr %g.addr
  %r.16388 = call i64 @kx_struct_get(i64 %t.16387, i32 4)
  %ext.16390 = sext i32 0 to i64
  %r.16389 = call i64 @kx_list_get(i64 %r.16388, i64 %ext.16390)
  %r.16391 = call ptr @kx_int_str(i64 %r.16389)
  %r.16393 = call ptr @kx_str_cat(ptr @.str.514, ptr %r.16391)
  %bodyLabel.587 = alloca ptr
  store ptr %r.16393, ptr %bodyLabel.587
  %t.16394 = load i64, ptr %g.addr
  %r.16395 = call i64 @kx_struct_get(i64 %t.16394, i32 4)
  %t.16396 = load i64, ptr %g.addr
  %r.16397 = call i64 @kx_struct_get(i64 %t.16396, i32 4)
  %ext.16399 = sext i32 0 to i64
  %r.16398 = call i64 @kx_list_get(i64 %r.16397, i64 %ext.16399)
  %ext.16400 = sext i32 1 to i64
  %t.16401 = add i64 %r.16398, %ext.16400
  %ext.16402 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16395, i64 %ext.16402, i64 %t.16401)
  %t.16403 = load i64, ptr %g.addr
  %r.16404 = call i64 @kx_struct_get(i64 %t.16403, i32 4)
  %ext.16406 = sext i32 0 to i64
  %r.16405 = call i64 @kx_list_get(i64 %r.16404, i64 %ext.16406)
  %r.16407 = call ptr @kx_int_str(i64 %r.16405)
  %r.16409 = call ptr @kx_str_cat(ptr @.str.515, ptr %r.16407)
  %incLabel.588 = alloca ptr
  store ptr %r.16409, ptr %incLabel.588
  %t.16410 = load i64, ptr %g.addr
  %r.16411 = call i64 @kx_struct_get(i64 %t.16410, i32 4)
  %t.16412 = load i64, ptr %g.addr
  %r.16413 = call i64 @kx_struct_get(i64 %t.16412, i32 4)
  %ext.16415 = sext i32 0 to i64
  %r.16414 = call i64 @kx_list_get(i64 %r.16413, i64 %ext.16415)
  %ext.16416 = sext i32 1 to i64
  %t.16417 = add i64 %r.16414, %ext.16416
  %ext.16418 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16411, i64 %ext.16418, i64 %t.16417)
  %t.16419 = load i64, ptr %g.addr
  %r.16420 = call i64 @kx_struct_get(i64 %t.16419, i32 4)
  %ext.16422 = sext i32 0 to i64
  %r.16421 = call i64 @kx_list_get(i64 %r.16420, i64 %ext.16422)
  %r.16423 = call ptr @kx_int_str(i64 %r.16421)
  %r.16425 = call ptr @kx_str_cat(ptr @.str.516, ptr %r.16423)
  %endLabel.589 = alloca ptr
  store ptr %r.16425, ptr %endLabel.589
  %i.590 = alloca i32
  store i32 0, ptr %i.590
  %t.16426 = load i64, ptr %s.addr
  %r.16427 = call i64 @kx_struct_get(i64 %t.16426, i32 4)
  %r.16428 = call i64 @kx_list_size(i64 %r.16427)
  %ext.16429 = sext i32 1 to i64
  %t.16430 = icmp sgt i64 %r.16428, %ext.16429
  %t.16431 = load i64, ptr %arena.addr
  %t.16432 = load i64, ptr %s.addr
  %r.16433 = call i64 @kx_struct_get(i64 %t.16432, i32 4)
  %ext.16435 = sext i32 0 to i64
  %r.16434 = call i64 @kx_list_get(i64 %r.16433, i64 %ext.16435)
  %r.16436 = call i64 @kx_list_get(i64 %t.16431, i64 %r.16434)
  %ext.16438 = inttoptr i64 %r.16436 to ptr
  %r.16439 = call i1 @kx_str_eq(ptr %ext.16438, ptr @.str.161)
  %t.16440 = and i1 %t.16430, %r.16439
  br i1 %t.16440, label %if.then.16441, label %if.merge.16442
if.then.16441:
  %t.16443 = load i64, ptr %g.addr
  %t.16444 = load i64, ptr %arena.addr
  %t.16445 = load i64, ptr %s.addr
  %cast.16446 = sext i32 0 to i64
  %r.16447 = call i64 @Child(i64 %t.16444, i64 %t.16445, i64 %cast.16446)
  %t.16448 = load i64, ptr %arena.addr
  %r.16449 = call i64 @GenStmt(i64 %t.16443, i64 %r.16447, i64 %t.16448)
  store i32 1, ptr %i.590
  br label %if.merge.16442
if.merge.16442:
  %t.16450 = load i64, ptr %g.addr
  %t.16451 = load ptr, ptr %condLabel.586
  %r.16453 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16451)
  %r.16454 = call i64 @Emit(i64 %t.16450, ptr %r.16453)
  %t.16455 = load i64, ptr %g.addr
  %t.16456 = load ptr, ptr %condLabel.586
  %r.16458 = call ptr @kx_str_cat(ptr %t.16456, ptr @.str.89)
  %r.16459 = call i64 @Emit(i64 %t.16455, ptr %r.16458)
  %t.16460 = load i32, ptr %i.590
  %t.16461 = load i64, ptr %bodyIdx.585
  %ext.16462 = sext i32 %t.16460 to i64
  %t.16463 = icmp slt i64 %ext.16462, %t.16461
  br i1 %t.16463, label %if.then.16464, label %if.else.16466
if.then.16464:
  %t.16467 = load i64, ptr %g.addr
  %t.16468 = load i64, ptr %arena.addr
  %t.16469 = load i64, ptr %s.addr
  %t.16470 = load i32, ptr %i.590
  %cast.16471 = sext i32 %t.16470 to i64
  %r.16472 = call i64 @Child(i64 %t.16468, i64 %t.16469, i64 %cast.16471)
  %t.16473 = load i64, ptr %arena.addr
  %r.16474 = call ptr @GenExpr(i64 %t.16467, i64 %r.16472, i64 %t.16473)
  %cond.591 = alloca ptr
  store ptr %r.16474, ptr %cond.591
  %t.16475 = load i64, ptr %g.addr
  %t.16476 = load ptr, ptr %cond.591
  %r.16477 = call i64 @XVal(ptr %t.16476)
  %ext.16479 = call ptr @kx_int_str(i64 %r.16477)
  %r.16480 = call ptr @kx_str_cat(ptr @.str.490, ptr %ext.16479)
  %r.16482 = call ptr @kx_str_cat(ptr %r.16480, ptr @.str.491)
  %t.16483 = load ptr, ptr %bodyLabel.587
  %r.16485 = call ptr @kx_str_cat(ptr %r.16482, ptr %t.16483)
  %r.16487 = call ptr @kx_str_cat(ptr %r.16485, ptr @.str.491)
  %t.16488 = load ptr, ptr %endLabel.589
  %r.16490 = call ptr @kx_str_cat(ptr %r.16487, ptr %t.16488)
  %r.16491 = call i64 @Emit(i64 %t.16475, ptr %r.16490)
  %t.16492 = load i32, ptr %i.590
  %t.16493 = add i32 %t.16492, 1
  store i32 %t.16493, ptr %i.590
  br label %if.merge.16465
if.else.16466:
  %t.16494 = load i64, ptr %g.addr
  %t.16495 = load ptr, ptr %bodyLabel.587
  %r.16497 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16495)
  %r.16498 = call i64 @Emit(i64 %t.16494, ptr %r.16497)
  br label %if.merge.16465
if.merge.16465:
  %t.16499 = load i64, ptr %g.addr
  %t.16500 = load ptr, ptr %bodyLabel.587
  %r.16502 = call ptr @kx_str_cat(ptr %t.16500, ptr @.str.89)
  %r.16503 = call i64 @Emit(i64 %t.16499, ptr %r.16502)
  %t.16504 = load i64, ptr %g.addr
  %r.16505 = call i64 @kx_struct_get(i64 %t.16504, i32 14)
  %t.16506 = load ptr, ptr %endLabel.589
  %ext.16507 = ptrtoint ptr %t.16506 to i64
  call void @kx_list_add(i64 %r.16505, i64 %ext.16507)
  %t.16508 = load i64, ptr %g.addr
  %r.16509 = call i64 @kx_struct_get(i64 %t.16508, i32 15)
  %t.16510 = load ptr, ptr %incLabel.588
  %ext.16511 = ptrtoint ptr %t.16510 to i64
  call void @kx_list_add(i64 %r.16509, i64 %ext.16511)
  %t.16512 = load i64, ptr %g.addr
  %t.16513 = load i64, ptr %arena.addr
  %t.16514 = load i64, ptr %s.addr
  %t.16515 = load i64, ptr %bodyIdx.585
  %r.16516 = call i64 @Child(i64 %t.16513, i64 %t.16514, i64 %t.16515)
  %t.16517 = load i64, ptr %arena.addr
  %r.16518 = call i64 @GenStmt(i64 %t.16512, i64 %r.16516, i64 %t.16517)
  %t.16519 = load i64, ptr %g.addr
  %r.16520 = call i64 @kx_struct_get(i64 %t.16519, i32 14)
  %t.16521 = load i64, ptr %g.addr
  %r.16522 = call i64 @kx_struct_get(i64 %t.16521, i32 14)
  %r.16523 = call i64 @kx_list_size(i64 %r.16522)
  %ext.16524 = sext i32 1 to i64
  %t.16525 = sub i64 %r.16523, %ext.16524
  call void @kx_list_remove_at(i64 %r.16520, i64 %t.16525)
  %t.16526 = load i64, ptr %g.addr
  %r.16527 = call i64 @kx_struct_get(i64 %t.16526, i32 15)
  %t.16528 = load i64, ptr %g.addr
  %r.16529 = call i64 @kx_struct_get(i64 %t.16528, i32 15)
  %r.16530 = call i64 @kx_list_size(i64 %r.16529)
  %ext.16531 = sext i32 1 to i64
  %t.16532 = sub i64 %r.16530, %ext.16531
  call void @kx_list_remove_at(i64 %r.16527, i64 %t.16532)
  %t.16533 = load i64, ptr %g.addr
  %t.16534 = load ptr, ptr %incLabel.588
  %r.16536 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16534)
  %r.16537 = call i64 @Emit(i64 %t.16533, ptr %r.16536)
  %t.16538 = load i64, ptr %g.addr
  %t.16539 = load ptr, ptr %incLabel.588
  %r.16541 = call ptr @kx_str_cat(ptr %t.16539, ptr @.str.89)
  %r.16542 = call i64 @Emit(i64 %t.16538, ptr %r.16541)
  %t.16543 = load i32, ptr %i.590
  %t.16544 = load i64, ptr %bodyIdx.585
  %ext.16545 = sext i32 %t.16543 to i64
  %t.16546 = icmp slt i64 %ext.16545, %t.16544
  br i1 %t.16546, label %if.then.16547, label %if.merge.16548
if.then.16547:
  %t.16549 = load i64, ptr %g.addr
  %t.16550 = load i64, ptr %arena.addr
  %t.16551 = load i64, ptr %s.addr
  %t.16552 = load i32, ptr %i.590
  %cast.16553 = sext i32 %t.16552 to i64
  %r.16554 = call i64 @Child(i64 %t.16550, i64 %t.16551, i64 %cast.16553)
  %t.16555 = load i64, ptr %arena.addr
  %r.16556 = call ptr @GenExpr(i64 %t.16549, i64 %r.16554, i64 %t.16555)
  br label %if.merge.16548
if.merge.16548:
  %t.16557 = load i64, ptr %g.addr
  %t.16558 = load ptr, ptr %condLabel.586
  %r.16560 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16558)
  %r.16561 = call i64 @Emit(i64 %t.16557, ptr %r.16560)
  %t.16562 = load i64, ptr %g.addr
  %t.16563 = load ptr, ptr %endLabel.589
  %r.16565 = call ptr @kx_str_cat(ptr %t.16563, ptr @.str.89)
  %r.16566 = call i64 @Emit(i64 %t.16562, ptr %r.16565)
  %ext.16567 = sext i32 0 to i64
  ret i64 %ext.16567
dead.16568:
  br label %if.merge.16356
if.merge.16356:
  %t.16569 = load i64, ptr %s.addr
  %r.16570 = call i64 @kx_struct_get(i64 %t.16569, i32 0)
  %field.16571 = inttoptr i64 %r.16570 to ptr
  %r.16573 = call i1 @kx_str_eq(ptr %field.16571, ptr @.str.35)
  br i1 %r.16573, label %if.then.16574, label %if.merge.16575
if.then.16574:
  %t.16576 = load i64, ptr %arena.addr
  %t.16577 = load i64, ptr %s.addr
  %cast.16578 = sext i32 0 to i64
  %r.16579 = call i64 @Child(i64 %t.16576, i64 %t.16577, i64 %cast.16578)
  %r.16580 = call i64 @kx_struct_get(i64 %r.16579, i32 1)
  %field.16581 = inttoptr i64 %r.16580 to ptr
  %varNm.592 = alloca ptr
  store ptr %field.16581, ptr %varNm.592
  %t.16582 = load i64, ptr %g.addr
  %t.16583 = load i64, ptr %arena.addr
  %t.16584 = load i64, ptr %s.addr
  %cast.16585 = sext i32 1 to i64
  %r.16586 = call i64 @Child(i64 %t.16583, i64 %t.16584, i64 %cast.16585)
  %t.16587 = load i64, ptr %arena.addr
  %r.16588 = call ptr @GenExpr(i64 %t.16582, i64 %r.16586, i64 %t.16587)
  %container.593 = alloca ptr
  store ptr %r.16588, ptr %container.593
  %t.16589 = load ptr, ptr %container.593
  %r.16590 = call i64 @XVal(ptr %t.16589)
  %cv.594 = alloca i64
  store i64 %r.16590, ptr %cv.594
  %t.16591 = load i64, ptr %g.addr
  %r.16592 = call i64 @kx_struct_get(i64 %t.16591, i32 4)
  %t.16593 = load i64, ptr %g.addr
  %r.16594 = call i64 @kx_struct_get(i64 %t.16593, i32 4)
  %ext.16596 = sext i32 0 to i64
  %r.16595 = call i64 @kx_list_get(i64 %r.16594, i64 %ext.16596)
  %ext.16597 = sext i32 1 to i64
  %t.16598 = add i64 %r.16595, %ext.16597
  %ext.16599 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16592, i64 %ext.16599, i64 %t.16598)
  %t.16600 = load i64, ptr %g.addr
  %r.16601 = call i64 @kx_struct_get(i64 %t.16600, i32 4)
  %ext.16603 = sext i32 0 to i64
  %r.16602 = call i64 @kx_list_get(i64 %r.16601, i64 %ext.16603)
  %r.16604 = call ptr @kx_int_str(i64 %r.16602)
  %r.16606 = call ptr @kx_str_cat(ptr @.str.517, ptr %r.16604)
  %idxVar.595 = alloca ptr
  store ptr %r.16606, ptr %idxVar.595
  %t.16607 = load i64, ptr %g.addr
  %r.16608 = call i64 @kx_struct_get(i64 %t.16607, i32 4)
  %t.16609 = load i64, ptr %g.addr
  %r.16610 = call i64 @kx_struct_get(i64 %t.16609, i32 4)
  %ext.16612 = sext i32 0 to i64
  %r.16611 = call i64 @kx_list_get(i64 %r.16610, i64 %ext.16612)
  %ext.16613 = sext i32 1 to i64
  %t.16614 = add i64 %r.16611, %ext.16613
  %ext.16615 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16608, i64 %ext.16615, i64 %t.16614)
  %t.16616 = load i64, ptr %g.addr
  %r.16617 = call i64 @kx_struct_get(i64 %t.16616, i32 4)
  %ext.16619 = sext i32 0 to i64
  %r.16618 = call i64 @kx_list_get(i64 %r.16617, i64 %ext.16619)
  %r.16620 = call ptr @kx_int_str(i64 %r.16618)
  %r.16622 = call ptr @kx_str_cat(ptr @.str.518, ptr %r.16620)
  %elemVar.596 = alloca ptr
  store ptr %r.16622, ptr %elemVar.596
  %t.16623 = load i64, ptr %g.addr
  %t.16624 = load ptr, ptr %elemVar.596
  %r.16626 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16624)
  %r.16628 = call ptr @kx_str_cat(ptr %r.16626, ptr @.str.437)
  %r.16629 = call i64 @Emit(i64 %t.16623, ptr %r.16628)
  %t.16630 = load i64, ptr %g.addr
  %t.16631 = load ptr, ptr %idxVar.595
  %r.16633 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16631)
  %r.16635 = call ptr @kx_str_cat(ptr %r.16633, ptr @.str.437)
  %r.16636 = call i64 @Emit(i64 %t.16630, ptr %r.16635)
  %t.16637 = load i64, ptr %g.addr
  %t.16638 = load ptr, ptr %idxVar.595
  %r.16640 = call ptr @kx_str_cat(ptr @.str.519, ptr %t.16638)
  %r.16641 = call i64 @Emit(i64 %t.16637, ptr %r.16640)
  %t.16642 = load i64, ptr %g.addr
  %r.16643 = call i64 @kx_struct_get(i64 %t.16642, i32 4)
  %t.16644 = load i64, ptr %g.addr
  %r.16645 = call i64 @kx_struct_get(i64 %t.16644, i32 4)
  %ext.16647 = sext i32 0 to i64
  %r.16646 = call i64 @kx_list_get(i64 %r.16645, i64 %ext.16647)
  %ext.16648 = sext i32 1 to i64
  %t.16649 = add i64 %r.16646, %ext.16648
  %ext.16650 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16643, i64 %ext.16650, i64 %t.16649)
  %t.16651 = load i64, ptr %g.addr
  %r.16652 = call i64 @kx_struct_get(i64 %t.16651, i32 4)
  %ext.16654 = sext i32 0 to i64
  %r.16653 = call i64 @kx_list_get(i64 %r.16652, i64 %ext.16654)
  %r.16655 = call ptr @kx_int_str(i64 %r.16653)
  %r.16657 = call ptr @kx_str_cat(ptr @.str.520, ptr %r.16655)
  %cl.597 = alloca ptr
  store ptr %r.16657, ptr %cl.597
  %t.16658 = load i64, ptr %g.addr
  %r.16659 = call i64 @kx_struct_get(i64 %t.16658, i32 4)
  %t.16660 = load i64, ptr %g.addr
  %r.16661 = call i64 @kx_struct_get(i64 %t.16660, i32 4)
  %ext.16663 = sext i32 0 to i64
  %r.16662 = call i64 @kx_list_get(i64 %r.16661, i64 %ext.16663)
  %ext.16664 = sext i32 1 to i64
  %t.16665 = add i64 %r.16662, %ext.16664
  %ext.16666 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16659, i64 %ext.16666, i64 %t.16665)
  %t.16667 = load i64, ptr %g.addr
  %r.16668 = call i64 @kx_struct_get(i64 %t.16667, i32 4)
  %ext.16670 = sext i32 0 to i64
  %r.16669 = call i64 @kx_list_get(i64 %r.16668, i64 %ext.16670)
  %r.16671 = call ptr @kx_int_str(i64 %r.16669)
  %r.16673 = call ptr @kx_str_cat(ptr @.str.521, ptr %r.16671)
  %bl.598 = alloca ptr
  store ptr %r.16673, ptr %bl.598
  %t.16674 = load i64, ptr %g.addr
  %r.16675 = call i64 @kx_struct_get(i64 %t.16674, i32 4)
  %t.16676 = load i64, ptr %g.addr
  %r.16677 = call i64 @kx_struct_get(i64 %t.16676, i32 4)
  %ext.16679 = sext i32 0 to i64
  %r.16678 = call i64 @kx_list_get(i64 %r.16677, i64 %ext.16679)
  %ext.16680 = sext i32 1 to i64
  %t.16681 = add i64 %r.16678, %ext.16680
  %ext.16682 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16675, i64 %ext.16682, i64 %t.16681)
  %t.16683 = load i64, ptr %g.addr
  %r.16684 = call i64 @kx_struct_get(i64 %t.16683, i32 4)
  %ext.16686 = sext i32 0 to i64
  %r.16685 = call i64 @kx_list_get(i64 %r.16684, i64 %ext.16686)
  %r.16687 = call ptr @kx_int_str(i64 %r.16685)
  %r.16689 = call ptr @kx_str_cat(ptr @.str.522, ptr %r.16687)
  %el.599 = alloca ptr
  store ptr %r.16689, ptr %el.599
  %t.16690 = load i64, ptr %g.addr
  %t.16691 = load ptr, ptr %cl.597
  %r.16693 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16691)
  %r.16694 = call i64 @Emit(i64 %t.16690, ptr %r.16693)
  %t.16695 = load i64, ptr %g.addr
  %t.16696 = load ptr, ptr %cl.597
  %r.16698 = call ptr @kx_str_cat(ptr %t.16696, ptr @.str.89)
  %r.16699 = call i64 @Emit(i64 %t.16695, ptr %r.16698)
  %t.16700 = load i64, ptr %g.addr
  %r.16701 = call i64 @kx_struct_get(i64 %t.16700, i32 4)
  %t.16702 = load i64, ptr %g.addr
  %r.16703 = call i64 @kx_struct_get(i64 %t.16702, i32 4)
  %ext.16705 = sext i32 0 to i64
  %r.16704 = call i64 @kx_list_get(i64 %r.16703, i64 %ext.16705)
  %ext.16706 = sext i32 1 to i64
  %t.16707 = add i64 %r.16704, %ext.16706
  %ext.16708 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16701, i64 %ext.16708, i64 %t.16707)
  %t.16709 = load i64, ptr %g.addr
  %r.16710 = call i64 @kx_struct_get(i64 %t.16709, i32 4)
  %ext.16712 = sext i32 0 to i64
  %r.16711 = call i64 @kx_list_get(i64 %r.16710, i64 %ext.16712)
  %r.16713 = call ptr @kx_int_str(i64 %r.16711)
  %r.16715 = call ptr @kx_str_cat(ptr @.str.523, ptr %r.16713)
  %idx.600 = alloca ptr
  store ptr %r.16715, ptr %idx.600
  %t.16716 = load i64, ptr %g.addr
  %t.16717 = load ptr, ptr %idx.600
  %r.16719 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16717)
  %r.16721 = call ptr @kx_str_cat(ptr %r.16719, ptr @.str.524)
  %t.16722 = load ptr, ptr %idxVar.595
  %r.16724 = call ptr @kx_str_cat(ptr %r.16721, ptr %t.16722)
  %r.16725 = call i64 @Emit(i64 %t.16716, ptr %r.16724)
  %t.16726 = load i64, ptr %g.addr
  %r.16727 = call i64 @kx_struct_get(i64 %t.16726, i32 4)
  %t.16728 = load i64, ptr %g.addr
  %r.16729 = call i64 @kx_struct_get(i64 %t.16728, i32 4)
  %ext.16731 = sext i32 0 to i64
  %r.16730 = call i64 @kx_list_get(i64 %r.16729, i64 %ext.16731)
  %ext.16732 = sext i32 1 to i64
  %t.16733 = add i64 %r.16730, %ext.16732
  %ext.16734 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16727, i64 %ext.16734, i64 %t.16733)
  %t.16735 = load i64, ptr %g.addr
  %r.16736 = call i64 @kx_struct_get(i64 %t.16735, i32 4)
  %ext.16738 = sext i32 0 to i64
  %r.16737 = call i64 @kx_list_get(i64 %r.16736, i64 %ext.16738)
  %r.16739 = call ptr @kx_int_str(i64 %r.16737)
  %r.16741 = call ptr @kx_str_cat(ptr @.str.525, ptr %r.16739)
  %len.601 = alloca ptr
  store ptr %r.16741, ptr %len.601
  %t.16742 = load i64, ptr %g.addr
  %t.16743 = load ptr, ptr %len.601
  %r.16745 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16743)
  %r.16747 = call ptr @kx_str_cat(ptr %r.16745, ptr @.str.440)
  %t.16748 = load i64, ptr %cv.594
  %ext.16750 = call ptr @kx_int_str(i64 %t.16748)
  %r.16751 = call ptr @kx_str_cat(ptr %r.16747, ptr %ext.16750)
  %r.16753 = call ptr @kx_str_cat(ptr %r.16751, ptr @.str.100)
  %r.16754 = call i64 @Emit(i64 %t.16742, ptr %r.16753)
  %t.16755 = load i64, ptr %g.addr
  %r.16756 = call i64 @kx_struct_get(i64 %t.16755, i32 4)
  %t.16757 = load i64, ptr %g.addr
  %r.16758 = call i64 @kx_struct_get(i64 %t.16757, i32 4)
  %ext.16760 = sext i32 0 to i64
  %r.16759 = call i64 @kx_list_get(i64 %r.16758, i64 %ext.16760)
  %ext.16761 = sext i32 1 to i64
  %t.16762 = add i64 %r.16759, %ext.16761
  %ext.16763 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16756, i64 %ext.16763, i64 %t.16762)
  %t.16764 = load i64, ptr %g.addr
  %r.16765 = call i64 @kx_struct_get(i64 %t.16764, i32 4)
  %ext.16767 = sext i32 0 to i64
  %r.16766 = call i64 @kx_list_get(i64 %r.16765, i64 %ext.16767)
  %r.16768 = call ptr @kx_int_str(i64 %r.16766)
  %r.16770 = call ptr @kx_str_cat(ptr @.str.526, ptr %r.16768)
  %cmp.602 = alloca ptr
  store ptr %r.16770, ptr %cmp.602
  %t.16771 = load i64, ptr %g.addr
  %t.16772 = load ptr, ptr %cmp.602
  %r.16774 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16772)
  %r.16776 = call ptr @kx_str_cat(ptr %r.16774, ptr @.str.527)
  %t.16777 = load ptr, ptr %idx.600
  %r.16779 = call ptr @kx_str_cat(ptr %r.16776, ptr %t.16777)
  %r.16781 = call ptr @kx_str_cat(ptr %r.16779, ptr @.str.403)
  %t.16782 = load ptr, ptr %len.601
  %r.16784 = call ptr @kx_str_cat(ptr %r.16781, ptr %t.16782)
  %r.16785 = call i64 @Emit(i64 %t.16771, ptr %r.16784)
  %t.16786 = load i64, ptr %g.addr
  %t.16787 = load ptr, ptr %cmp.602
  %r.16789 = call ptr @kx_str_cat(ptr @.str.490, ptr %t.16787)
  %r.16791 = call ptr @kx_str_cat(ptr %r.16789, ptr @.str.491)
  %t.16792 = load ptr, ptr %bl.598
  %r.16794 = call ptr @kx_str_cat(ptr %r.16791, ptr %t.16792)
  %r.16796 = call ptr @kx_str_cat(ptr %r.16794, ptr @.str.491)
  %t.16797 = load ptr, ptr %el.599
  %r.16799 = call ptr @kx_str_cat(ptr %r.16796, ptr %t.16797)
  %r.16800 = call i64 @Emit(i64 %t.16786, ptr %r.16799)
  %t.16801 = load i64, ptr %g.addr
  %t.16802 = load ptr, ptr %bl.598
  %r.16804 = call ptr @kx_str_cat(ptr %t.16802, ptr @.str.89)
  %r.16805 = call i64 @Emit(i64 %t.16801, ptr %r.16804)
  %t.16806 = load i64, ptr %g.addr
  %r.16807 = call i64 @kx_struct_get(i64 %t.16806, i32 4)
  %t.16808 = load i64, ptr %g.addr
  %r.16809 = call i64 @kx_struct_get(i64 %t.16808, i32 4)
  %ext.16811 = sext i32 0 to i64
  %r.16810 = call i64 @kx_list_get(i64 %r.16809, i64 %ext.16811)
  %ext.16812 = sext i32 1 to i64
  %t.16813 = add i64 %r.16810, %ext.16812
  %ext.16814 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16807, i64 %ext.16814, i64 %t.16813)
  %t.16815 = load i64, ptr %g.addr
  %r.16816 = call i64 @kx_struct_get(i64 %t.16815, i32 4)
  %ext.16818 = sext i32 0 to i64
  %r.16817 = call i64 @kx_list_get(i64 %r.16816, i64 %ext.16818)
  %r.16819 = call ptr @kx_int_str(i64 %r.16817)
  %r.16821 = call ptr @kx_str_cat(ptr @.str.528, ptr %r.16819)
  %elem.603 = alloca ptr
  store ptr %r.16821, ptr %elem.603
  %t.16822 = load i64, ptr %g.addr
  %t.16823 = load ptr, ptr %elem.603
  %r.16825 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16823)
  %r.16827 = call ptr @kx_str_cat(ptr %r.16825, ptr @.str.461)
  %t.16828 = load i64, ptr %cv.594
  %ext.16830 = call ptr @kx_int_str(i64 %t.16828)
  %r.16831 = call ptr @kx_str_cat(ptr %r.16827, ptr %ext.16830)
  %r.16833 = call ptr @kx_str_cat(ptr %r.16831, ptr @.str.392)
  %t.16834 = load ptr, ptr %idx.600
  %r.16836 = call ptr @kx_str_cat(ptr %r.16833, ptr %t.16834)
  %r.16838 = call ptr @kx_str_cat(ptr %r.16836, ptr @.str.100)
  %r.16839 = call i64 @Emit(i64 %t.16822, ptr %r.16838)
  %t.16840 = load i64, ptr %g.addr
  %t.16841 = load ptr, ptr %elem.603
  %r.16843 = call ptr @kx_str_cat(ptr @.str.428, ptr %t.16841)
  %r.16845 = call ptr @kx_str_cat(ptr %r.16843, ptr @.str.396)
  %t.16846 = load ptr, ptr %elemVar.596
  %r.16848 = call ptr @kx_str_cat(ptr %r.16845, ptr %t.16846)
  %r.16849 = call i64 @Emit(i64 %t.16840, ptr %r.16848)
  %t.16850 = load i64, ptr %g.addr
  %r.16851 = call i64 @kx_struct_get(i64 %t.16850, i32 6)
  %t.16852 = load ptr, ptr %varNm.592
  %c.16853 = ptrtoint ptr %t.16852 to i64
  %c.16854 = ptrtoint ptr @.str.269 to i64
  call void @kx_map_set(i64 %r.16851, i64 %c.16853, i64 %c.16854)
  %t.16855 = load i64, ptr %g.addr
  %r.16856 = call i64 @kx_struct_get(i64 %t.16855, i32 7)
  %t.16857 = load ptr, ptr %varNm.592
  %t.16858 = load ptr, ptr %elemVar.596
  %c.16859 = ptrtoint ptr %t.16857 to i64
  %c.16860 = ptrtoint ptr %t.16858 to i64
  call void @kx_map_set(i64 %r.16856, i64 %c.16859, i64 %c.16860)
  %t.16861 = load i64, ptr %g.addr
  %r.16862 = call i64 @kx_struct_get(i64 %t.16861, i32 14)
  %t.16863 = load ptr, ptr %el.599
  %ext.16864 = ptrtoint ptr %t.16863 to i64
  call void @kx_list_add(i64 %r.16862, i64 %ext.16864)
  %t.16865 = load i64, ptr %g.addr
  %r.16866 = call i64 @kx_struct_get(i64 %t.16865, i32 15)
  %t.16867 = load ptr, ptr %cl.597
  %ext.16868 = ptrtoint ptr %t.16867 to i64
  call void @kx_list_add(i64 %r.16866, i64 %ext.16868)
  %t.16869 = load i64, ptr %g.addr
  %t.16870 = load i64, ptr %arena.addr
  %t.16871 = load i64, ptr %s.addr
  %cast.16872 = sext i32 2 to i64
  %r.16873 = call i64 @Child(i64 %t.16870, i64 %t.16871, i64 %cast.16872)
  %t.16874 = load i64, ptr %arena.addr
  %r.16875 = call i64 @GenStmt(i64 %t.16869, i64 %r.16873, i64 %t.16874)
  %t.16876 = load i64, ptr %g.addr
  %r.16877 = call i64 @kx_struct_get(i64 %t.16876, i32 14)
  %t.16878 = load i64, ptr %g.addr
  %r.16879 = call i64 @kx_struct_get(i64 %t.16878, i32 14)
  %r.16880 = call i64 @kx_list_size(i64 %r.16879)
  %ext.16881 = sext i32 1 to i64
  %t.16882 = sub i64 %r.16880, %ext.16881
  call void @kx_list_remove_at(i64 %r.16877, i64 %t.16882)
  %t.16883 = load i64, ptr %g.addr
  %r.16884 = call i64 @kx_struct_get(i64 %t.16883, i32 15)
  %t.16885 = load i64, ptr %g.addr
  %r.16886 = call i64 @kx_struct_get(i64 %t.16885, i32 15)
  %r.16887 = call i64 @kx_list_size(i64 %r.16886)
  %ext.16888 = sext i32 1 to i64
  %t.16889 = sub i64 %r.16887, %ext.16888
  call void @kx_list_remove_at(i64 %r.16884, i64 %t.16889)
  %t.16890 = load i64, ptr %g.addr
  %r.16891 = call i64 @kx_struct_get(i64 %t.16890, i32 4)
  %t.16892 = load i64, ptr %g.addr
  %r.16893 = call i64 @kx_struct_get(i64 %t.16892, i32 4)
  %ext.16895 = sext i32 0 to i64
  %r.16894 = call i64 @kx_list_get(i64 %r.16893, i64 %ext.16895)
  %ext.16896 = sext i32 1 to i64
  %t.16897 = add i64 %r.16894, %ext.16896
  %ext.16898 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16891, i64 %ext.16898, i64 %t.16897)
  %t.16899 = load i64, ptr %g.addr
  %r.16900 = call i64 @kx_struct_get(i64 %t.16899, i32 4)
  %ext.16902 = sext i32 0 to i64
  %r.16901 = call i64 @kx_list_get(i64 %r.16900, i64 %ext.16902)
  %r.16903 = call ptr @kx_int_str(i64 %r.16901)
  %r.16905 = call ptr @kx_str_cat(ptr @.str.529, ptr %r.16903)
  %nextIdx.604 = alloca ptr
  store ptr %r.16905, ptr %nextIdx.604
  %t.16906 = load i64, ptr %g.addr
  %t.16907 = load ptr, ptr %nextIdx.604
  %r.16909 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.16907)
  %r.16911 = call ptr @kx_str_cat(ptr %r.16909, ptr @.str.426)
  %t.16912 = load ptr, ptr %idx.600
  %r.16914 = call ptr @kx_str_cat(ptr %r.16911, ptr %t.16912)
  %r.16916 = call ptr @kx_str_cat(ptr %r.16914, ptr @.str.427)
  %r.16917 = call i64 @Emit(i64 %t.16906, ptr %r.16916)
  %t.16918 = load i64, ptr %g.addr
  %t.16919 = load ptr, ptr %nextIdx.604
  %r.16921 = call ptr @kx_str_cat(ptr @.str.428, ptr %t.16919)
  %r.16923 = call ptr @kx_str_cat(ptr %r.16921, ptr @.str.396)
  %t.16924 = load ptr, ptr %idxVar.595
  %r.16926 = call ptr @kx_str_cat(ptr %r.16923, ptr %t.16924)
  %r.16927 = call i64 @Emit(i64 %t.16918, ptr %r.16926)
  %t.16928 = load i64, ptr %g.addr
  %t.16929 = load ptr, ptr %cl.597
  %r.16931 = call ptr @kx_str_cat(ptr @.str.492, ptr %t.16929)
  %r.16932 = call i64 @Emit(i64 %t.16928, ptr %r.16931)
  %t.16933 = load i64, ptr %g.addr
  %t.16934 = load ptr, ptr %el.599
  %r.16936 = call ptr @kx_str_cat(ptr %t.16934, ptr @.str.89)
  %r.16937 = call i64 @Emit(i64 %t.16933, ptr %r.16936)
  %ext.16938 = sext i32 0 to i64
  ret i64 %ext.16938
dead.16939:
  br label %if.merge.16575
if.merge.16575:
  %t.16940 = load i64, ptr %s.addr
  %r.16941 = call i64 @kx_struct_get(i64 %t.16940, i32 0)
  %field.16942 = inttoptr i64 %r.16941 to ptr
  %r.16944 = call i1 @kx_str_eq(ptr %field.16942, ptr @.str.55)
  br i1 %r.16944, label %if.then.16945, label %if.merge.16946
if.then.16945:
  %t.16947 = load i64, ptr %g.addr
  %t.16948 = load i64, ptr %arena.addr
  %t.16949 = load i64, ptr %s.addr
  %cast.16950 = sext i32 0 to i64
  %r.16951 = call i64 @Child(i64 %t.16948, i64 %t.16949, i64 %cast.16950)
  %t.16952 = load i64, ptr %arena.addr
  %r.16953 = call ptr @GenExpr(i64 %t.16947, i64 %r.16951, i64 %t.16952)
  %cond.605 = alloca ptr
  store ptr %r.16953, ptr %cond.605
  %t.16954 = load i64, ptr %g.addr
  %r.16955 = call i64 @kx_struct_get(i64 %t.16954, i32 4)
  %t.16956 = load i64, ptr %g.addr
  %r.16957 = call i64 @kx_struct_get(i64 %t.16956, i32 4)
  %ext.16959 = sext i32 0 to i64
  %r.16958 = call i64 @kx_list_get(i64 %r.16957, i64 %ext.16959)
  %ext.16960 = sext i32 1 to i64
  %t.16961 = add i64 %r.16958, %ext.16960
  %ext.16962 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16955, i64 %ext.16962, i64 %t.16961)
  %t.16963 = load i64, ptr %g.addr
  %r.16964 = call i64 @kx_struct_get(i64 %t.16963, i32 4)
  %ext.16966 = sext i32 0 to i64
  %r.16965 = call i64 @kx_list_get(i64 %r.16964, i64 %ext.16966)
  %r.16967 = call ptr @kx_int_str(i64 %r.16965)
  %r.16969 = call ptr @kx_str_cat(ptr @.str.530, ptr %r.16967)
  %endLabel.606 = alloca ptr
  store ptr %r.16969, ptr %endLabel.606
  %t.16970 = load ptr, ptr %endLabel.606
  %defaultLabel.607 = alloca ptr
  store ptr %t.16970, ptr %defaultLabel.607
  %r.16971 = call i64 @kx_list_new(i32 0)
  %caseLabels.608 = alloca i64
  store i64 %r.16971, ptr %caseLabels.608
  %ci.609 = alloca i32
  store i32 1, ptr %ci.609
  br label %for.cond.16972
for.cond.16972:
  %t.16976 = load i32, ptr %ci.609
  %t.16977 = load i64, ptr %s.addr
  %r.16978 = call i64 @kx_struct_get(i64 %t.16977, i32 4)
  %r.16979 = call i64 @kx_list_size(i64 %r.16978)
  %ext.16980 = sext i32 %t.16976 to i64
  %t.16981 = icmp slt i64 %ext.16980, %r.16979
  br i1 %t.16981, label %for.body.16973, label %for.end.16975
for.body.16973:
  %t.16982 = load i64, ptr %g.addr
  %r.16983 = call i64 @kx_struct_get(i64 %t.16982, i32 4)
  %t.16984 = load i64, ptr %g.addr
  %r.16985 = call i64 @kx_struct_get(i64 %t.16984, i32 4)
  %ext.16987 = sext i32 0 to i64
  %r.16986 = call i64 @kx_list_get(i64 %r.16985, i64 %ext.16987)
  %ext.16988 = sext i32 1 to i64
  %t.16989 = add i64 %r.16986, %ext.16988
  %ext.16990 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.16983, i64 %ext.16990, i64 %t.16989)
  %t.16991 = load i64, ptr %caseLabels.608
  %t.16992 = load i64, ptr %g.addr
  %r.16993 = call i64 @kx_struct_get(i64 %t.16992, i32 4)
  %ext.16995 = sext i32 0 to i64
  %r.16994 = call i64 @kx_list_get(i64 %r.16993, i64 %ext.16995)
  %r.16996 = call ptr @kx_int_str(i64 %r.16994)
  %r.16998 = call ptr @kx_str_cat(ptr @.str.531, ptr %r.16996)
  %ext.16999 = ptrtoint ptr %r.16998 to i64
  call void @kx_list_add(i64 %t.16991, i64 %ext.16999)
  br label %for.inc.16974
for.inc.16974:
  %t.17000 = load i32, ptr %ci.609
  %t.17001 = add i32 %t.17000, 1
  store i32 %t.17001, ptr %ci.609
  br label %for.cond.16972
for.end.16975:
  %hasDefault.610 = alloca i1
  store i1 false, ptr %hasDefault.610
  %ci.611 = alloca i32
  store i32 1, ptr %ci.611
  br label %for.cond.17002
for.cond.17002:
  %t.17006 = load i32, ptr %ci.611
  %t.17007 = load i64, ptr %s.addr
  %r.17008 = call i64 @kx_struct_get(i64 %t.17007, i32 4)
  %r.17009 = call i64 @kx_list_size(i64 %r.17008)
  %ext.17010 = sext i32 %t.17006 to i64
  %t.17011 = icmp slt i64 %ext.17010, %r.17009
  br i1 %t.17011, label %for.body.17003, label %for.end.17005
for.body.17003:
  %t.17012 = load i64, ptr %arena.addr
  %t.17013 = load i64, ptr %s.addr
  %t.17014 = load i32, ptr %ci.611
  %cast.17015 = sext i32 %t.17014 to i64
  %r.17016 = call i64 @Child(i64 %t.17012, i64 %t.17013, i64 %cast.17015)
  %caseNode.612 = alloca i64
  store i64 %r.17016, ptr %caseNode.612
  %t.17017 = sub i32 0, 1
  %blockChild.613 = alloca i32
  store i32 %t.17017, ptr %blockChild.613
  %k.614 = alloca i32
  store i32 0, ptr %k.614
  br label %for.cond.17018
for.cond.17018:
  %t.17022 = load i32, ptr %k.614
  %t.17023 = load i64, ptr %caseNode.612
  %r.17024 = call i64 @kx_list_size(i64 %t.17023)
  %ext.17025 = sext i32 %t.17022 to i64
  %t.17026 = icmp slt i64 %ext.17025, %r.17024
  br i1 %t.17026, label %for.body.17019, label %for.end.17021
for.body.17019:
  %t.17027 = load i64, ptr %arena.addr
  %t.17028 = load i64, ptr %caseNode.612
  %t.17029 = load i32, ptr %k.614
  %ext.17031 = sext i32 %t.17029 to i64
  %r.17030 = call i64 @kx_list_get(i64 %t.17028, i64 %ext.17031)
  %r.17032 = call i64 @kx_list_get(i64 %t.17027, i64 %r.17030)
  %ext.17034 = inttoptr i64 %r.17032 to ptr
  %r.17035 = call i1 @kx_str_eq(ptr %ext.17034, ptr @.str.158)
  br i1 %r.17035, label %if.then.17036, label %if.merge.17037
if.then.17036:
  %t.17038 = load i32, ptr %k.614
  store i32 %t.17038, ptr %blockChild.613
  br label %for.end.17021
dead.17039:
  br label %if.merge.17037
if.merge.17037:
  br label %for.inc.17020
for.inc.17020:
  %t.17040 = load i32, ptr %k.614
  %t.17041 = add i32 %t.17040, 1
  store i32 %t.17041, ptr %k.614
  br label %for.cond.17018
for.end.17021:
  %t.17042 = load i32, ptr %blockChild.613
  %t.17043 = icmp sge i32 %t.17042, 0
  br i1 %t.17043, label %if.then.17044, label %if.merge.17045
if.then.17044:
  %t.17046 = sub i32 0, 1
  %last.615 = alloca i32
  store i32 %t.17046, ptr %last.615
  %t.17047 = load i64, ptr %arena.addr
  %t.17048 = load i64, ptr %caseNode.612
  %t.17049 = load i32, ptr %blockChild.613
  %cast.17050 = sext i32 %t.17049 to i64
  %r.17051 = call i64 @Child(i64 %t.17047, i64 %t.17048, i64 %cast.17050)
  %blk.616 = alloca i64
  store i64 %r.17051, ptr %blk.616
  %t.17052 = load i64, ptr %blk.616
  %r.17053 = call i64 @kx_list_size(i64 %t.17052)
  %ext.17054 = sext i32 0 to i64
  %t.17055 = icmp sgt i64 %r.17053, %ext.17054
  br i1 %t.17055, label %if.then.17056, label %if.merge.17057
if.then.17056:
  %t.17058 = load i64, ptr %blk.616
  %r.17059 = call i64 @kx_list_size(i64 %t.17058)
  %ext.17060 = sext i32 1 to i64
  %t.17061 = sub i64 %r.17059, %ext.17060
  %trunc.17062 = trunc i64 %t.17061 to i32
  store i32 %trunc.17062, ptr %last.615
  %t.17063 = load i64, ptr %arena.addr
  %t.17064 = load i64, ptr %blk.616
  %t.17065 = load i32, ptr %last.615
  %ext.17067 = sext i32 %t.17065 to i64
  %r.17066 = call i64 @kx_list_get(i64 %t.17064, i64 %ext.17067)
  %r.17068 = call i64 @kx_list_get(i64 %t.17063, i64 %r.17066)
  %lastStmt.617 = alloca i64
  store i64 %r.17068, ptr %lastStmt.617
  %t.17069 = load i64, ptr %lastStmt.617
  %ext.17071 = inttoptr i64 %t.17069 to ptr
  %r.17072 = call i1 @kx_str_eq(ptr %ext.17071, ptr @.str.39)
  %t.17073 = load i64, ptr %lastStmt.617
  %ext.17075 = inttoptr i64 %t.17073 to ptr
  %r.17076 = call i1 @kx_str_eq(ptr %ext.17075, ptr @.str.37)
  %t.17077 = or i1 %r.17072, %r.17076
  br i1 %t.17077, label %if.then.17078, label %if.else.17080
if.then.17078:
  br label %if.merge.17079
if.else.17080:
  %t.17081 = sub i32 0, 1
  store i32 %t.17081, ptr %last.615
  br label %if.merge.17079
if.merge.17079:
  br label %if.merge.17057
if.merge.17057:
  br label %if.merge.17045
if.merge.17045:
  br label %for.inc.17004
for.inc.17004:
  %t.17082 = load i32, ptr %ci.611
  %t.17083 = add i32 %t.17082, 1
  store i32 %t.17083, ptr %ci.611
  br label %for.cond.17002
for.end.17005:
  %ci.618 = alloca i32
  store i32 1, ptr %ci.618
  br label %for.cond.17084
for.cond.17084:
  %t.17088 = load i32, ptr %ci.618
  %t.17089 = load i64, ptr %s.addr
  %r.17090 = call i64 @kx_struct_get(i64 %t.17089, i32 4)
  %r.17091 = call i64 @kx_list_size(i64 %r.17090)
  %ext.17092 = sext i32 %t.17088 to i64
  %t.17093 = icmp slt i64 %ext.17092, %r.17091
  br i1 %t.17093, label %for.body.17085, label %for.end.17087
for.body.17085:
  %t.17094 = load i64, ptr %arena.addr
  %t.17095 = load i64, ptr %s.addr
  %t.17096 = load i32, ptr %ci.618
  %cast.17097 = sext i32 %t.17096 to i64
  %r.17098 = call i64 @Child(i64 %t.17094, i64 %t.17095, i64 %cast.17097)
  %caseNode.619 = alloca i64
  store i64 %r.17098, ptr %caseNode.619
  %t.17099 = load i64, ptr %g.addr
  %t.17100 = load i64, ptr %caseLabels.608
  %t.17101 = load i32, ptr %ci.618
  %t.17102 = sub i32 %t.17101, 1
  %ext.17104 = sext i32 %t.17102 to i64
  %r.17103 = call i64 @kx_list_get(i64 %t.17100, i64 %ext.17104)
  %ptr.17105 = inttoptr i64 %r.17103 to ptr
  %r.17107 = call ptr @kx_str_cat(ptr @.str.492, ptr %ptr.17105)
  %r.17108 = call i64 @Emit(i64 %t.17099, ptr %r.17107)
  %t.17109 = load i64, ptr %g.addr
  %t.17110 = load i64, ptr %caseLabels.608
  %t.17111 = load i32, ptr %ci.618
  %t.17112 = sub i32 %t.17111, 1
  %ext.17114 = sext i32 %t.17112 to i64
  %r.17113 = call i64 @kx_list_get(i64 %t.17110, i64 %ext.17114)
  %ptr.17115 = inttoptr i64 %r.17113 to ptr
  %r.17117 = call ptr @kx_str_cat(ptr %ptr.17115, ptr @.str.89)
  %r.17118 = call i64 @Emit(i64 %t.17109, ptr %r.17117)
  %k.620 = alloca i32
  store i32 0, ptr %k.620
  br label %for.cond.17119
for.cond.17119:
  %t.17123 = load i32, ptr %k.620
  %t.17124 = load i64, ptr %caseNode.619
  %r.17125 = call i64 @kx_list_size(i64 %t.17124)
  %ext.17126 = sext i32 %t.17123 to i64
  %t.17127 = icmp slt i64 %ext.17126, %r.17125
  br i1 %t.17127, label %for.body.17120, label %for.end.17122
for.body.17120:
  %t.17128 = load i64, ptr %arena.addr
  %t.17129 = load i64, ptr %caseNode.619
  %t.17130 = load i32, ptr %k.620
  %cast.17131 = sext i32 %t.17130 to i64
  %r.17132 = call i64 @Child(i64 %t.17128, i64 %t.17129, i64 %cast.17131)
  %child.621 = alloca i64
  store i64 %r.17132, ptr %child.621
  %t.17133 = load i64, ptr %child.621
  %ext.17135 = inttoptr i64 %t.17133 to ptr
  %r.17136 = call i1 @kx_str_eq(ptr %ext.17135, ptr @.str.158)
  br i1 %r.17136, label %if.then.17137, label %if.else.17139
if.then.17137:
  %t.17140 = load i64, ptr %g.addr
  %t.17141 = load i64, ptr %child.621
  %t.17142 = load i64, ptr %arena.addr
  %r.17143 = call i64 @GenStmt(i64 %t.17140, i64 %t.17141, i64 %t.17142)
  br label %if.merge.17138
if.else.17139:
  %t.17144 = load i64, ptr %g.addr
  %t.17145 = load i64, ptr %child.621
  %t.17146 = load i64, ptr %arena.addr
  %r.17147 = call ptr @GenExpr(i64 %t.17144, i64 %t.17145, i64 %t.17146)
  %cv.622 = alloca ptr
  store ptr %r.17147, ptr %cv.622
  %t.17148 = load i64, ptr %g.addr
  %r.17149 = call i64 @kx_struct_get(i64 %t.17148, i32 4)
  %t.17150 = load i64, ptr %g.addr
  %r.17151 = call i64 @kx_struct_get(i64 %t.17150, i32 4)
  %ext.17153 = sext i32 0 to i64
  %r.17152 = call i64 @kx_list_get(i64 %r.17151, i64 %ext.17153)
  %ext.17154 = sext i32 1 to i64
  %t.17155 = add i64 %r.17152, %ext.17154
  %ext.17156 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.17149, i64 %ext.17156, i64 %t.17155)
  %t.17157 = load i64, ptr %g.addr
  %r.17158 = call i64 @kx_struct_get(i64 %t.17157, i32 4)
  %ext.17160 = sext i32 0 to i64
  %r.17159 = call i64 @kx_list_get(i64 %r.17158, i64 %ext.17160)
  %r.17161 = call ptr @kx_int_str(i64 %r.17159)
  %r.17163 = call ptr @kx_str_cat(ptr @.str.526, ptr %r.17161)
  %cmp.623 = alloca ptr
  store ptr %r.17163, ptr %cmp.623
  %t.17164 = load i64, ptr %g.addr
  %t.17165 = load ptr, ptr %cmp.623
  %r.17167 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.17165)
  %r.17169 = call ptr @kx_str_cat(ptr %r.17167, ptr @.str.409)
  %t.17170 = load ptr, ptr %cond.605
  %r.17171 = call i64 @XType(ptr %t.17170)
  %ext.17173 = call ptr @kx_int_str(i64 %r.17171)
  %r.17174 = call ptr @kx_str_cat(ptr %r.17169, ptr %ext.17173)
  %r.17176 = call ptr @kx_str_cat(ptr %r.17174, ptr @.str.8)
  %t.17177 = load ptr, ptr %cond.605
  %r.17178 = call i64 @XVal(ptr %t.17177)
  %ext.17180 = call ptr @kx_int_str(i64 %r.17178)
  %r.17181 = call ptr @kx_str_cat(ptr %r.17176, ptr %ext.17180)
  %r.17183 = call ptr @kx_str_cat(ptr %r.17181, ptr @.str.403)
  %t.17184 = load ptr, ptr %cv.622
  %r.17185 = call i64 @XVal(ptr %t.17184)
  %ext.17187 = call ptr @kx_int_str(i64 %r.17185)
  %r.17188 = call ptr @kx_str_cat(ptr %r.17183, ptr %ext.17187)
  %r.17189 = call i64 @Emit(i64 %t.17164, ptr %r.17188)
  %t.17190 = load i64, ptr %g.addr
  %r.17191 = call i64 @kx_struct_get(i64 %t.17190, i32 4)
  %t.17192 = load i64, ptr %g.addr
  %r.17193 = call i64 @kx_struct_get(i64 %t.17192, i32 4)
  %ext.17195 = sext i32 0 to i64
  %r.17194 = call i64 @kx_list_get(i64 %r.17193, i64 %ext.17195)
  %ext.17196 = sext i32 1 to i64
  %t.17197 = add i64 %r.17194, %ext.17196
  %ext.17198 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.17191, i64 %ext.17198, i64 %t.17197)
  %t.17199 = load i64, ptr %g.addr
  %r.17200 = call i64 @kx_struct_get(i64 %t.17199, i32 4)
  %ext.17202 = sext i32 0 to i64
  %r.17201 = call i64 @kx_list_get(i64 %r.17200, i64 %ext.17202)
  %r.17203 = call ptr @kx_int_str(i64 %r.17201)
  %r.17205 = call ptr @kx_str_cat(ptr @.str.532, ptr %r.17203)
  %trueLabel.624 = alloca ptr
  store ptr %r.17205, ptr %trueLabel.624
  %t.17206 = load i64, ptr %g.addr
  %t.17207 = load ptr, ptr %cmp.623
  %r.17209 = call ptr @kx_str_cat(ptr @.str.490, ptr %t.17207)
  %r.17211 = call ptr @kx_str_cat(ptr %r.17209, ptr @.str.491)
  %t.17212 = load ptr, ptr %trueLabel.624
  %r.17214 = call ptr @kx_str_cat(ptr %r.17211, ptr %t.17212)
  %r.17216 = call ptr @kx_str_cat(ptr %r.17214, ptr @.str.491)
  %t.17217 = load i64, ptr %caseLabels.608
  %t.17218 = load i32, ptr %ci.618
  %ext.17220 = sext i32 %t.17218 to i64
  %r.17219 = call i64 @kx_list_get(i64 %t.17217, i64 %ext.17220)
  %ptr.17221 = inttoptr i64 %r.17219 to ptr
  %r.17223 = call ptr @kx_str_cat(ptr %r.17216, ptr %ptr.17221)
  %r.17224 = call i64 @Emit(i64 %t.17206, ptr %r.17223)
  %t.17225 = load i64, ptr %g.addr
  %t.17226 = load ptr, ptr %trueLabel.624
  %r.17228 = call ptr @kx_str_cat(ptr %t.17226, ptr @.str.89)
  %r.17229 = call i64 @Emit(i64 %t.17225, ptr %r.17228)
  br label %if.merge.17138
if.merge.17138:
  br label %for.inc.17121
for.inc.17121:
  %t.17230 = load i32, ptr %k.620
  %t.17231 = add i32 %t.17230, 1
  store i32 %t.17231, ptr %k.620
  br label %for.cond.17119
for.end.17122:
  br label %for.inc.17086
for.inc.17086:
  %t.17232 = load i32, ptr %ci.618
  %t.17233 = add i32 %t.17232, 1
  store i32 %t.17233, ptr %ci.618
  br label %for.cond.17084
for.end.17087:
  %t.17234 = load i64, ptr %g.addr
  %t.17235 = load ptr, ptr %endLabel.606
  %r.17237 = call ptr @kx_str_cat(ptr %t.17235, ptr @.str.89)
  %r.17238 = call i64 @Emit(i64 %t.17234, ptr %r.17237)
  %ext.17239 = sext i32 0 to i64
  ret i64 %ext.17239
dead.17240:
  br label %if.merge.16946
if.merge.16946:
  %t.17241 = load i64, ptr %s.addr
  %r.17242 = call i64 @kx_struct_get(i64 %t.17241, i32 0)
  %field.17243 = inttoptr i64 %r.17242 to ptr
  %r.17245 = call i1 @kx_str_eq(ptr %field.17243, ptr @.str.40)
  br i1 %r.17245, label %if.then.17246, label %if.merge.17247
if.then.17246:
  %t.17248 = load i64, ptr %g.addr
  %r.17249 = call i64 @kx_struct_get(i64 %t.17248, i32 4)
  %t.17250 = load i64, ptr %g.addr
  %r.17251 = call i64 @kx_struct_get(i64 %t.17250, i32 4)
  %ext.17253 = sext i32 0 to i64
  %r.17252 = call i64 @kx_list_get(i64 %r.17251, i64 %ext.17253)
  %ext.17254 = sext i32 1 to i64
  %t.17255 = add i64 %r.17252, %ext.17254
  %ext.17256 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.17249, i64 %ext.17256, i64 %t.17255)
  %t.17257 = load i64, ptr %g.addr
  %r.17258 = call i64 @kx_struct_get(i64 %t.17257, i32 4)
  %ext.17260 = sext i32 0 to i64
  %r.17259 = call i64 @kx_list_get(i64 %r.17258, i64 %ext.17260)
  %r.17261 = call ptr @kx_int_str(i64 %r.17259)
  %r.17263 = call ptr @kx_str_cat(ptr @.str.533, ptr %r.17261)
  %entity.625 = alloca ptr
  store ptr %r.17263, ptr %entity.625
  %t.17264 = load i64, ptr %g.addr
  %t.17265 = load ptr, ptr %entity.625
  %r.17267 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.17265)
  %r.17269 = call ptr @kx_str_cat(ptr %r.17267, ptr @.str.534)
  %r.17270 = call i64 @Emit(i64 %t.17264, ptr %r.17269)
  %t.17271 = load i64, ptr %g.addr
  %r.17272 = call i64 @kx_struct_get(i64 %t.17271, i32 7)
  %t.17273 = load ptr, ptr %entity.625
  %c.17274 = ptrtoint ptr @.str.535 to i64
  %c.17275 = ptrtoint ptr %t.17273 to i64
  call void @kx_map_set(i64 %r.17272, i64 %c.17274, i64 %c.17275)
  %t.17276 = load i64, ptr %g.addr
  %r.17277 = call i64 @kx_struct_get(i64 %t.17276, i32 6)
  %c.17278 = ptrtoint ptr @.str.535 to i64
  %c.17279 = ptrtoint ptr @.str.269 to i64
  call void @kx_map_set(i64 %r.17277, i64 %c.17278, i64 %c.17279)
  %ext.17280 = sext i32 0 to i64
  ret i64 %ext.17280
dead.17281:
  br label %if.merge.17247
if.merge.17247:
  %t.17282 = load i64, ptr %s.addr
  %r.17283 = call i64 @kx_struct_get(i64 %t.17282, i32 0)
  %field.17284 = inttoptr i64 %r.17283 to ptr
  %r.17286 = call i1 @kx_str_eq(ptr %field.17284, ptr @.str.42)
  br i1 %r.17286, label %if.then.17287, label %if.merge.17288
if.then.17287:
  %t.17289 = load i64, ptr %s.addr
  %r.17290 = call i64 @kx_struct_get(i64 %t.17289, i32 4)
  %r.17291 = call i64 @kx_list_size(i64 %r.17290)
  %ext.17292 = sext i32 2 to i64
  %t.17293 = icmp sge i64 %r.17291, %ext.17292
  br i1 %t.17293, label %if.then.17294, label %if.merge.17295
if.then.17294:
  %t.17296 = load i64, ptr %g.addr
  %t.17297 = load i64, ptr %arena.addr
  %t.17298 = load i64, ptr %s.addr
  %cast.17299 = sext i32 0 to i64
  %r.17300 = call i64 @Child(i64 %t.17297, i64 %t.17298, i64 %cast.17299)
  %t.17301 = load i64, ptr %arena.addr
  %r.17302 = call ptr @GenExpr(i64 %t.17296, i64 %r.17300, i64 %t.17301)
  %entityExpr.626 = alloca ptr
  store ptr %r.17302, ptr %entityExpr.626
  %t.17303 = load i64, ptr %arena.addr
  %t.17304 = load i64, ptr %s.addr
  %cast.17305 = sext i32 1 to i64
  %r.17306 = call i64 @Child(i64 %t.17303, i64 %t.17304, i64 %cast.17305)
  %r.17307 = call i64 @kx_struct_get(i64 %r.17306, i32 1)
  %field.17308 = inttoptr i64 %r.17307 to ptr
  %compName.627 = alloca ptr
  store ptr %field.17308, ptr %compName.627
  %t.17309 = load i64, ptr %g.addr
  %t.17310 = load ptr, ptr %compName.627
  %r.17311 = call i64 @GetCompIdx(i64 %t.17309, ptr %t.17310)
  %compIdx.628 = alloca i64
  store i64 %r.17311, ptr %compIdx.628
  %t.17312 = load i64, ptr %compIdx.628
  %ext.17313 = sext i32 0 to i64
  %t.17314 = icmp sge i64 %t.17312, %ext.17313
  br i1 %t.17314, label %if.then.17315, label %if.merge.17316
if.then.17315:
  %t.17317 = load i64, ptr %g.addr
  %t.17318 = load ptr, ptr %entityExpr.626
  %r.17319 = call i64 @XVal(ptr %t.17318)
  %ext.17321 = call ptr @kx_int_str(i64 %r.17319)
  %r.17322 = call ptr @kx_str_cat(ptr @.str.536, ptr %ext.17321)
  %r.17324 = call ptr @kx_str_cat(ptr %r.17322, ptr @.str.391)
  %t.17325 = load i64, ptr %compIdx.628
  %r.17326 = call ptr @kx_int_str(i64 %t.17325)
  %r.17328 = call ptr @kx_str_cat(ptr %r.17324, ptr %r.17326)
  %r.17330 = call ptr @kx_str_cat(ptr %r.17328, ptr @.str.100)
  %r.17331 = call i64 @Emit(i64 %t.17317, ptr %r.17330)
  br label %if.merge.17316
if.merge.17316:
  br label %if.merge.17295
if.merge.17295:
  %ext.17332 = sext i32 0 to i64
  ret i64 %ext.17332
dead.17333:
  br label %if.merge.17288
if.merge.17288:
  %t.17334 = load i64, ptr %s.addr
  %r.17335 = call i64 @kx_struct_get(i64 %t.17334, i32 0)
  %field.17336 = inttoptr i64 %r.17335 to ptr
  %r.17338 = call i1 @kx_str_eq(ptr %field.17336, ptr @.str.43)
  br i1 %r.17338, label %if.then.17339, label %if.merge.17340
if.then.17339:
  %t.17341 = load i64, ptr %s.addr
  %r.17342 = call i64 @kx_struct_get(i64 %t.17341, i32 4)
  %r.17343 = call i64 @kx_list_size(i64 %r.17342)
  %ext.17344 = sext i32 2 to i64
  %t.17345 = icmp sge i64 %r.17343, %ext.17344
  br i1 %t.17345, label %if.then.17346, label %if.merge.17347
if.then.17346:
  %t.17348 = load i64, ptr %g.addr
  %t.17349 = load i64, ptr %arena.addr
  %t.17350 = load i64, ptr %s.addr
  %cast.17351 = sext i32 0 to i64
  %r.17352 = call i64 @Child(i64 %t.17349, i64 %t.17350, i64 %cast.17351)
  %t.17353 = load i64, ptr %arena.addr
  %r.17354 = call ptr @GenExpr(i64 %t.17348, i64 %r.17352, i64 %t.17353)
  %entityExpr.629 = alloca ptr
  store ptr %r.17354, ptr %entityExpr.629
  %t.17355 = load i64, ptr %arena.addr
  %t.17356 = load i64, ptr %s.addr
  %cast.17357 = sext i32 1 to i64
  %r.17358 = call i64 @Child(i64 %t.17355, i64 %t.17356, i64 %cast.17357)
  %r.17359 = call i64 @kx_struct_get(i64 %r.17358, i32 1)
  %field.17360 = inttoptr i64 %r.17359 to ptr
  %compName.630 = alloca ptr
  store ptr %field.17360, ptr %compName.630
  %t.17361 = load i64, ptr %g.addr
  %t.17362 = load ptr, ptr %compName.630
  %r.17363 = call i64 @GetCompIdx(i64 %t.17361, ptr %t.17362)
  %compIdx.631 = alloca i64
  store i64 %r.17363, ptr %compIdx.631
  %t.17364 = load i64, ptr %compIdx.631
  %ext.17365 = sext i32 0 to i64
  %t.17366 = icmp sge i64 %t.17364, %ext.17365
  br i1 %t.17366, label %if.then.17367, label %if.merge.17368
if.then.17367:
  %t.17369 = load i64, ptr %g.addr
  %t.17370 = load ptr, ptr %entityExpr.629
  %r.17371 = call i64 @XVal(ptr %t.17370)
  %ext.17373 = call ptr @kx_int_str(i64 %r.17371)
  %r.17374 = call ptr @kx_str_cat(ptr @.str.537, ptr %ext.17373)
  %r.17376 = call ptr @kx_str_cat(ptr %r.17374, ptr @.str.391)
  %t.17377 = load i64, ptr %compIdx.631
  %r.17378 = call ptr @kx_int_str(i64 %t.17377)
  %r.17380 = call ptr @kx_str_cat(ptr %r.17376, ptr %r.17378)
  %r.17382 = call ptr @kx_str_cat(ptr %r.17380, ptr @.str.100)
  %r.17383 = call i64 @Emit(i64 %t.17369, ptr %r.17382)
  br label %if.merge.17368
if.merge.17368:
  br label %if.merge.17347
if.merge.17347:
  %ext.17384 = sext i32 0 to i64
  ret i64 %ext.17384
dead.17385:
  br label %if.merge.17340
if.merge.17340:
  %t.17386 = load i64, ptr %s.addr
  %r.17387 = call i64 @kx_struct_get(i64 %t.17386, i32 0)
  %field.17388 = inttoptr i64 %r.17387 to ptr
  %r.17390 = call i1 @kx_str_eq(ptr %field.17388, ptr @.str.41)
  br i1 %r.17390, label %if.then.17391, label %if.merge.17392
if.then.17391:
  %t.17393 = load i64, ptr %s.addr
  %r.17394 = call i64 @kx_struct_get(i64 %t.17393, i32 4)
  %r.17395 = call i64 @kx_list_size(i64 %r.17394)
  %ext.17396 = sext i32 1 to i64
  %t.17397 = icmp sge i64 %r.17395, %ext.17396
  br i1 %t.17397, label %if.then.17398, label %if.merge.17399
if.then.17398:
  %t.17400 = load i64, ptr %g.addr
  %t.17401 = load i64, ptr %arena.addr
  %t.17402 = load i64, ptr %s.addr
  %cast.17403 = sext i32 0 to i64
  %r.17404 = call i64 @Child(i64 %t.17401, i64 %t.17402, i64 %cast.17403)
  %t.17405 = load i64, ptr %arena.addr
  %r.17406 = call ptr @GenExpr(i64 %t.17400, i64 %r.17404, i64 %t.17405)
  %entityExpr.632 = alloca ptr
  store ptr %r.17406, ptr %entityExpr.632
  %t.17407 = load i64, ptr %g.addr
  %t.17408 = load ptr, ptr %entityExpr.632
  %r.17409 = call i64 @XVal(ptr %t.17408)
  %ext.17411 = call ptr @kx_int_str(i64 %r.17409)
  %r.17412 = call ptr @kx_str_cat(ptr @.str.538, ptr %ext.17411)
  %r.17414 = call ptr @kx_str_cat(ptr %r.17412, ptr @.str.100)
  %r.17415 = call i64 @Emit(i64 %t.17407, ptr %r.17414)
  br label %if.merge.17399
if.merge.17399:
  %ext.17416 = sext i32 0 to i64
  ret i64 %ext.17416
dead.17417:
  br label %if.merge.17392
if.merge.17392:
  %t.17418 = load i64, ptr %s.addr
  %r.17419 = call i64 @kx_struct_get(i64 %t.17418, i32 0)
  %field.17420 = inttoptr i64 %r.17419 to ptr
  %r.17422 = call i1 @kx_str_eq(ptr %field.17420, ptr @.str.37)
  br i1 %r.17422, label %if.then.17423, label %if.merge.17424
if.then.17423:
  %t.17425 = load i64, ptr %g.addr
  %r.17426 = call i64 @kx_struct_get(i64 %t.17425, i32 14)
  %r.17427 = call i64 @kx_list_size(i64 %r.17426)
  %ext.17428 = sext i32 0 to i64
  %t.17429 = icmp sgt i64 %r.17427, %ext.17428
  br i1 %t.17429, label %if.then.17430, label %if.merge.17431
if.then.17430:
  %t.17432 = load i64, ptr %g.addr
  %t.17433 = load i64, ptr %g.addr
  %r.17434 = call i64 @kx_struct_get(i64 %t.17433, i32 14)
  %t.17435 = load i64, ptr %g.addr
  %r.17436 = call i64 @kx_struct_get(i64 %t.17435, i32 14)
  %r.17437 = call i64 @kx_list_size(i64 %r.17436)
  %ext.17438 = sext i32 1 to i64
  %t.17439 = sub i64 %r.17437, %ext.17438
  %r.17440 = call i64 @kx_list_get(i64 %r.17434, i64 %t.17439)
  %ext.17442 = call ptr @kx_int_str(i64 %r.17440)
  %r.17443 = call ptr @kx_str_cat(ptr @.str.492, ptr %ext.17442)
  %r.17444 = call i64 @Emit(i64 %t.17432, ptr %r.17443)
  br label %if.merge.17431
if.merge.17431:
  %ext.17445 = sext i32 0 to i64
  ret i64 %ext.17445
dead.17446:
  br label %if.merge.17424
if.merge.17424:
  %t.17447 = load i64, ptr %s.addr
  %r.17448 = call i64 @kx_struct_get(i64 %t.17447, i32 0)
  %field.17449 = inttoptr i64 %r.17448 to ptr
  %r.17451 = call i1 @kx_str_eq(ptr %field.17449, ptr @.str.38)
  br i1 %r.17451, label %if.then.17452, label %if.merge.17453
if.then.17452:
  %t.17454 = load i64, ptr %g.addr
  %r.17455 = call i64 @kx_struct_get(i64 %t.17454, i32 15)
  %r.17456 = call i64 @kx_list_size(i64 %r.17455)
  %ext.17457 = sext i32 0 to i64
  %t.17458 = icmp sgt i64 %r.17456, %ext.17457
  br i1 %t.17458, label %if.then.17459, label %if.merge.17460
if.then.17459:
  %t.17461 = load i64, ptr %g.addr
  %t.17462 = load i64, ptr %g.addr
  %r.17463 = call i64 @kx_struct_get(i64 %t.17462, i32 15)
  %t.17464 = load i64, ptr %g.addr
  %r.17465 = call i64 @kx_struct_get(i64 %t.17464, i32 15)
  %r.17466 = call i64 @kx_list_size(i64 %r.17465)
  %ext.17467 = sext i32 1 to i64
  %t.17468 = sub i64 %r.17466, %ext.17467
  %r.17469 = call i64 @kx_list_get(i64 %r.17463, i64 %t.17468)
  %ext.17471 = call ptr @kx_int_str(i64 %r.17469)
  %r.17472 = call ptr @kx_str_cat(ptr @.str.492, ptr %ext.17471)
  %r.17473 = call i64 @Emit(i64 %t.17461, ptr %r.17472)
  br label %if.merge.17460
if.merge.17460:
  %ext.17474 = sext i32 0 to i64
  ret i64 %ext.17474
dead.17475:
  br label %if.merge.17453
if.merge.17453:
  %ext.17476 = sext i32 0 to i64
  ret i64 %ext.17476
dead.17477:
  ret i64 0
}

define i64 @GetCompIdx(i64 %g, ptr %name) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %name.addr = alloca ptr
  store ptr %name, ptr %name.addr
  %t.17478 = sub i32 0, 1
  %ext.17479 = sext i32 %t.17478 to i64
  ret i64 %ext.17479
dead.17480:
  ret i64 0
}

define i64 @GenFunc(i64 %g, i64 %decl, i64 %arena) {
entry:
  %g.addr = alloca i64
  store i64 %g, ptr %g.addr
  %decl.addr = alloca i64
  store i64 %decl, ptr %decl.addr
  %arena.addr = alloca i64
  store i64 %arena, ptr %arena.addr
  %t.17481 = load i64, ptr %arena.addr
  %t.17482 = load i64, ptr %decl.addr
  %cast.17483 = sext i32 0 to i64
  %r.17484 = call i64 @Child(i64 %t.17481, i64 %t.17482, i64 %cast.17483)
  %r.17485 = call i64 @kx_struct_get(i64 %r.17484, i32 1)
  %field.17486 = inttoptr i64 %r.17485 to ptr
  %nm.633 = alloca ptr
  store ptr %field.17486, ptr %nm.633
  %t.17487 = load i64, ptr %arena.addr
  %t.17488 = load i64, ptr %decl.addr
  %cast.17489 = sext i32 1 to i64
  %r.17490 = call i64 @Child(i64 %t.17487, i64 %t.17488, i64 %cast.17489)
  %r.17491 = call i64 @kx_struct_get(i64 %r.17490, i32 1)
  %field.17492 = inttoptr i64 %r.17491 to ptr
  %ret.634 = alloca ptr
  store ptr %field.17492, ptr %ret.634
  %r.17493 = call i64 @kx_list_new(i32 0)
  %params.635 = alloca i64
  store i64 %r.17493, ptr %params.635
  %i.636 = alloca i32
  store i32 2, ptr %i.636
  br label %for.cond.17494
for.cond.17494:
  %t.17498 = load i32, ptr %i.636
  %t.17499 = load i64, ptr %decl.addr
  %r.17500 = call i64 @kx_struct_get(i64 %t.17499, i32 4)
  %r.17501 = call i64 @kx_list_size(i64 %r.17500)
  %ext.17502 = sext i32 %t.17498 to i64
  %t.17503 = icmp slt i64 %ext.17502, %r.17501
  br i1 %t.17503, label %for.body.17495, label %for.end.17497
for.body.17495:
  %t.17504 = load i64, ptr %arena.addr
  %t.17505 = load i64, ptr %decl.addr
  %t.17506 = load i32, ptr %i.636
  %cast.17507 = sext i32 %t.17506 to i64
  %r.17508 = call i64 @Child(i64 %t.17504, i64 %t.17505, i64 %cast.17507)
  %c.637 = alloca i64
  store i64 %r.17508, ptr %c.637
  %t.17509 = load i64, ptr %c.637
  %ext.17511 = inttoptr i64 %t.17509 to ptr
  %r.17512 = call i1 @kx_str_eq(ptr %ext.17511, ptr @.str.211)
  br i1 %r.17512, label %if.then.17513, label %if.merge.17514
if.then.17513:
  %t.17515 = load i64, ptr %params.635
  %t.17516 = load i64, ptr %c.637
  call void @kx_list_add(i64 %t.17515, i64 %t.17516)
  br label %if.merge.17514
if.merge.17514:
  br label %for.inc.17496
for.inc.17496:
  %t.17517 = load i32, ptr %i.636
  %t.17518 = add i32 %t.17517, 1
  store i32 %t.17518, ptr %i.636
  br label %for.cond.17494
for.end.17497:
  %t.17519 = load i64, ptr %g.addr
  %r.17520 = call i64 @kx_struct_get(i64 %t.17519, i32 12)
  %t.17521 = load ptr, ptr %nm.633
  %c.17522 = ptrtoint ptr %t.17521 to i64
  %r.17523 = call i1 @kx_map_has(i64 %r.17520, i64 %c.17522)
  br i1 %r.17523, label %tern.then.17524, label %tern.else.17525
tern.then.17524:
  %t.17527 = load i64, ptr %g.addr
  %r.17528 = call i64 @kx_struct_get(i64 %t.17527, i32 12)
  %t.17529 = load ptr, ptr %nm.633
  %c.17531 = ptrtoint ptr %t.17529 to i64
  %r.17530 = call i64 @kx_map_get(i64 %r.17528, i64 %c.17531)
  br label %tern.merge.17526
tern.else.17525:
  %t.17532 = load ptr, ptr %ret.634
  %r.17533 = call ptr @KxType(ptr %t.17532)
  %r.17535 = call ptr @kx_str_cat(ptr %r.17533, ptr @.str.284)
  %ext.17536 = ptrtoint ptr %r.17535 to i64
  br label %tern.merge.17526
tern.merge.17526:
  %phi.17537 = phi i64 [%r.17530, %tern.then.17524], [%ext.17536, %tern.else.17525]
  %sig.638 = alloca i64
  store i64 %phi.17537, ptr %sig.638
  %t.17538 = load i64, ptr %sig.638
  %cast.17539 = inttoptr i64 %t.17538 to ptr
  %r.17540 = call i64 @SigParams(ptr %cast.17539)
  %sigParams.639 = alloca i64
  store i64 %r.17540, ptr %sigParams.639
  %t.17541 = load i64, ptr %sig.638
  %cast.17542 = inttoptr i64 %t.17541 to ptr
  %r.17543 = call i64 @SigRet(ptr %cast.17542)
  %cast.17544 = inttoptr i64 %r.17543 to ptr
  %r.17545 = call ptr @KxType(ptr %cast.17544)
  %irRet.640 = alloca ptr
  store ptr %r.17545, ptr %irRet.640
  %t.17546 = load ptr, ptr %nm.633
  %r.17548 = call i1 @kx_str_eq(ptr %t.17546, ptr @.str.539)
  br i1 %r.17548, label %if.then.17549, label %if.merge.17550
if.then.17549:
  store ptr @.str.279, ptr %irRet.640
  br label %if.merge.17550
if.merge.17550:
  %t.17551 = load ptr, ptr %irRet.640
  %t.17552 = load ptr, ptr %nm.633
  %irP.641 = alloca ptr
  store ptr @.str.12, ptr %irP.641
  %t.17553 = load ptr, ptr %nm.633
  %r.17555 = call i1 @kx_str_eq(ptr %t.17553, ptr @.str.539)
  br i1 %r.17555, label %if.then.17556, label %if.else.17558
if.then.17556:
  store ptr @.str.540, ptr %irP.641
  br label %if.merge.17557
if.else.17558:
  %i.642 = alloca i32
  store i32 0, ptr %i.642
  br label %for.cond.17559
for.cond.17559:
  %t.17563 = load i32, ptr %i.642
  %t.17564 = load i64, ptr %params.635
  %r.17565 = call i64 @kx_list_size(i64 %t.17564)
  %ext.17566 = sext i32 %t.17563 to i64
  %t.17567 = icmp slt i64 %ext.17566, %r.17565
  br i1 %t.17567, label %for.body.17560, label %for.end.17562
for.body.17560:
  %t.17568 = load i32, ptr %i.642
  %t.17569 = icmp sgt i32 %t.17568, 0
  br i1 %t.17569, label %if.then.17570, label %if.merge.17571
if.then.17570:
  %t.17572 = load ptr, ptr %irP.641
  %r.17574 = call ptr @kx_str_cat(ptr %t.17572, ptr @.str.403)
  store ptr %r.17574, ptr %irP.641
  br label %if.merge.17571
if.merge.17571:
  %t.17575 = load ptr, ptr %irP.641
  %t.17576 = load i64, ptr %sigParams.639
  %t.17577 = load i32, ptr %i.642
  %ext.17579 = sext i32 %t.17577 to i64
  %r.17578 = call i64 @kx_list_get(i64 %t.17576, i64 %ext.17579)
  %cast.17580 = inttoptr i64 %r.17578 to ptr
  %r.17581 = call ptr @KxType(ptr %cast.17580)
  %r.17583 = call ptr @kx_str_cat(ptr %t.17575, ptr %r.17581)
  %r.17585 = call ptr @kx_str_cat(ptr %r.17583, ptr @.str.541)
  %t.17586 = load i64, ptr %params.635
  %t.17587 = load i32, ptr %i.642
  %ext.17589 = sext i32 %t.17587 to i64
  %r.17588 = call i64 @kx_list_get(i64 %t.17586, i64 %ext.17589)
  %ptr.17590 = inttoptr i64 %r.17588 to ptr
  %r.17592 = call ptr @kx_str_cat(ptr %r.17585, ptr %ptr.17590)
  store ptr %r.17592, ptr %irP.641
  br label %for.inc.17561
for.inc.17561:
  %t.17593 = load i32, ptr %i.642
  %t.17594 = add i32 %t.17593, 1
  store i32 %t.17594, ptr %i.642
  br label %for.cond.17559
for.end.17562:
  br label %if.merge.17557
if.merge.17557:
  %t.17595 = load i64, ptr %g.addr
  %t.17596 = load ptr, ptr %irRet.640
  %r.17598 = call ptr @kx_str_cat(ptr @.str.542, ptr %t.17596)
  %r.17600 = call ptr @kx_str_cat(ptr %r.17598, ptr @.str.486)
  %t.17601 = load ptr, ptr %nm.633
  %r.17603 = call ptr @kx_str_cat(ptr %r.17600, ptr %t.17601)
  %r.17605 = call ptr @kx_str_cat(ptr %r.17603, ptr @.str.99)
  %t.17606 = load ptr, ptr %irP.641
  %r.17608 = call ptr @kx_str_cat(ptr %r.17605, ptr %t.17606)
  %r.17610 = call ptr @kx_str_cat(ptr %r.17608, ptr @.str.543)
  %r.17611 = call i64 @Emit(i64 %t.17595, ptr %r.17610)
  %t.17612 = load i64, ptr %g.addr
  %r.17613 = call i64 @Emit(i64 %t.17612, ptr @.str.544)
  %r.17614 = call i64 @kx_map_new(i32 0, i32 0)
  %r.17615 = call i64 @kx_map_new(i32 0, i32 0)
  %r.17616 = call i64 @kx_list_new(i32 0)
  %r.17617 = call i64 @kx_list_new(i32 0)
  %t.17618 = load i64, ptr %g.addr
  %r.17619 = call i64 @kx_struct_get(i64 %t.17618, i32 13)
  %ext.17620 = sext i32 0 to i64
  %ext.17621 = sext i32 0 to i64
  call void @kx_list_set(i64 %r.17619, i64 %ext.17620, i64 %ext.17621)
  %t.17622 = load ptr, ptr %nm.633
  %r.17624 = call i1 @kx_str_eq(ptr %t.17622, ptr @.str.539)
  br i1 %r.17624, label %if.then.17625, label %if.merge.17626
if.then.17625:
  %t.17627 = load i64, ptr %g.addr
  %r.17628 = call i64 @Emit(i64 %t.17627, ptr @.str.545)
  br label %if.merge.17626
if.merge.17626:
  %i.643 = alloca i32
  store i32 0, ptr %i.643
  br label %for.cond.17629
for.cond.17629:
  %t.17633 = load i32, ptr %i.643
  %t.17634 = load i64, ptr %params.635
  %r.17635 = call i64 @kx_list_size(i64 %t.17634)
  %ext.17636 = sext i32 %t.17633 to i64
  %t.17637 = icmp slt i64 %ext.17636, %r.17635
  br i1 %t.17637, label %for.body.17630, label %for.end.17632
for.body.17630:
  %t.17638 = load i64, ptr %params.635
  %t.17639 = load i32, ptr %i.643
  %ext.17641 = sext i32 %t.17639 to i64
  %r.17640 = call i64 @kx_list_get(i64 %t.17638, i64 %ext.17641)
  %ptr.17642 = inttoptr i64 %r.17640 to ptr
  %p.644 = alloca ptr
  store ptr %ptr.17642, ptr %p.644
  %t.17643 = load i64, ptr %sigParams.639
  %t.17644 = load i32, ptr %i.643
  %ext.17646 = sext i32 %t.17644 to i64
  %r.17645 = call i64 @kx_list_get(i64 %t.17643, i64 %ext.17646)
  %cast.17647 = inttoptr i64 %r.17645 to ptr
  %r.17648 = call ptr @KxType(ptr %cast.17647)
  %pType.645 = alloca ptr
  store ptr %r.17648, ptr %pType.645
  %t.17649 = load ptr, ptr %p.644
  %r.17651 = call ptr @kx_str_cat(ptr @.str.123, ptr %t.17649)
  %r.17653 = call ptr @kx_str_cat(ptr %r.17651, ptr @.str.546)
  %allocaNm.646 = alloca ptr
  store ptr %r.17653, ptr %allocaNm.646
  %t.17654 = load i64, ptr %g.addr
  %t.17655 = load ptr, ptr %allocaNm.646
  %r.17657 = call ptr @kx_str_cat(ptr @.str.272, ptr %t.17655)
  %r.17659 = call ptr @kx_str_cat(ptr %r.17657, ptr @.str.505)
  %t.17660 = load ptr, ptr %pType.645
  %r.17662 = call ptr @kx_str_cat(ptr %r.17659, ptr %t.17660)
  %r.17663 = call i64 @Emit(i64 %t.17654, ptr %r.17662)
  %t.17664 = load i64, ptr %g.addr
  %t.17665 = load ptr, ptr %pType.645
  %r.17667 = call ptr @kx_str_cat(ptr @.str.502, ptr %t.17665)
  %r.17669 = call ptr @kx_str_cat(ptr %r.17667, ptr @.str.541)
  %t.17670 = load ptr, ptr %p.644
  %r.17672 = call ptr @kx_str_cat(ptr %r.17669, ptr %t.17670)
  %r.17674 = call ptr @kx_str_cat(ptr %r.17672, ptr @.str.396)
  %t.17675 = load ptr, ptr %allocaNm.646
  %r.17677 = call ptr @kx_str_cat(ptr %r.17674, ptr %t.17675)
  %r.17678 = call i64 @Emit(i64 %t.17664, ptr %r.17677)
  %t.17679 = load i64, ptr %g.addr
  %r.17680 = call i64 @kx_struct_get(i64 %t.17679, i32 6)
  %t.17681 = load ptr, ptr %p.644
  %t.17682 = load i64, ptr %sigParams.639
  %t.17683 = load i32, ptr %i.643
  %ext.17685 = sext i32 %t.17683 to i64
  %r.17684 = call i64 @kx_list_get(i64 %t.17682, i64 %ext.17685)
  %c.17686 = ptrtoint ptr %t.17681 to i64
  call void @kx_map_set(i64 %r.17680, i64 %c.17686, i64 %r.17684)
  %t.17687 = load i64, ptr %g.addr
  %r.17688 = call i64 @kx_struct_get(i64 %t.17687, i32 7)
  %t.17689 = load ptr, ptr %p.644
  %t.17690 = load ptr, ptr %allocaNm.646
  %c.17691 = ptrtoint ptr %t.17689 to i64
  %c.17692 = ptrtoint ptr %t.17690 to i64
  call void @kx_map_set(i64 %r.17688, i64 %c.17691, i64 %c.17692)
  br label %for.inc.17631
for.inc.17631:
  %t.17693 = load i32, ptr %i.643
  %t.17694 = add i32 %t.17693, 1
  store i32 %t.17694, ptr %i.643
  br label %for.cond.17629
for.end.17632:
  %t.17695 = load i64, ptr %g.addr
  %t.17696 = load i64, ptr %arena.addr
  %t.17697 = load i64, ptr %decl.addr
  %t.17698 = load i64, ptr %decl.addr
  %r.17699 = call i64 @kx_struct_get(i64 %t.17698, i32 4)
  %r.17700 = call i64 @kx_list_size(i64 %r.17699)
  %ext.17701 = sext i32 1 to i64
  %t.17702 = sub i64 %r.17700, %ext.17701
  %r.17703 = call i64 @Child(i64 %t.17696, i64 %t.17697, i64 %t.17702)
  %t.17704 = load i64, ptr %arena.addr
  %r.17705 = call i64 @GenStmt(i64 %t.17695, i64 %r.17703, i64 %t.17704)
  %t.17706 = load ptr, ptr %ret.634
  %r.17708 = call i1 @kx_str_eq(ptr %t.17706, ptr @.str.23)
  br i1 %r.17708, label %if.then.17709, label %if.else.17711
if.then.17709:
  %t.17712 = load i64, ptr %g.addr
  %r.17713 = call i64 @Emit(i64 %t.17712, ptr @.str.506)
  br label %if.merge.17710
if.else.17711:
  %t.17714 = load ptr, ptr %nm.633
  %r.17716 = call i1 @kx_str_eq(ptr %t.17714, ptr @.str.539)
  br i1 %r.17716, label %if.then.17717, label %if.else.17719
if.then.17717:
  %t.17720 = load i64, ptr %g.addr
  %r.17721 = call i64 @Emit(i64 %t.17720, ptr @.str.547)
  br label %if.merge.17718
if.else.17719:
  %t.17722 = load ptr, ptr %irRet.640
  %r.17724 = call i1 @kx_str_eq(ptr %t.17722, ptr @.str.271)
  br i1 %r.17724, label %if.then.17725, label %if.else.17727
if.then.17725:
  %t.17728 = load i64, ptr %g.addr
  %r.17729 = call i64 @Emit(i64 %t.17728, ptr @.str.548)
  br label %if.merge.17726
if.else.17727:
  %t.17730 = load ptr, ptr %irRet.640
  %r.17732 = call i1 @kx_str_eq(ptr %t.17730, ptr @.str.280)
  br i1 %r.17732, label %if.then.17733, label %if.else.17735
if.then.17733:
  %t.17736 = load i64, ptr %g.addr
  %r.17737 = call i64 @Emit(i64 %t.17736, ptr @.str.549)
  br label %if.merge.17734
if.else.17735:
  %t.17738 = load i64, ptr %g.addr
  %t.17739 = load ptr, ptr %irRet.640
  %r.17741 = call ptr @kx_str_cat(ptr @.str.320, ptr %t.17739)
  %r.17743 = call ptr @kx_str_cat(ptr %r.17741, ptr @.str.550)
  %r.17744 = call i64 @Emit(i64 %t.17738, ptr %r.17743)
  br label %if.merge.17734
if.merge.17734:
  br label %if.merge.17726
if.merge.17726:
  br label %if.merge.17718
if.merge.17718:
  br label %if.merge.17710
if.merge.17710:
  %t.17745 = load i64, ptr %g.addr
  %r.17746 = call i64 @Emit(i64 %t.17745, ptr @.str.64)
  %t.17747 = load i64, ptr %g.addr
  %r.17748 = call i64 @Emit(i64 %t.17747, ptr @.str.12)
  %ext.17749 = sext i32 0 to i64
  ret i64 %ext.17749
dead.17750:
  ret i64 0
}

define i64 @FindProjectRoot() {
entry:
  %r.17751 = call i64 @kx_system(ptr @.str.551)
  %dir.647 = alloca i64
  store i64 %r.17751, ptr %dir.647
  %t.17752 = load i64, ptr %dir.647
  ret i64 %t.17752
dead.17753:
  ret i64 0
}

define i64 @ParseKxConf(ptr %path) {
entry:
  %path.addr = alloca ptr
  store ptr %path, ptr %path.addr
  %t.17754 = load ptr, ptr %path.addr
  %r.17755 = call i64 @kx_read_file(ptr %t.17754)
  %content.648 = alloca i64
  store i64 %r.17755, ptr %content.648
  %t.17756 = load i64, ptr %content.648
  %ext.17758 = inttoptr i64 %t.17756 to ptr
  %r.17759 = call i1 @kx_str_eq(ptr %ext.17758, ptr @.str.12)
  br i1 %r.17759, label %if.then.17760, label %if.merge.17761
if.then.17760:
  %r.17762 = call i64 @kx_map_new(i32 0, i32 0)
  ret i64 %r.17762
dead.17763:
  br label %if.merge.17761
if.merge.17761:
  %r.17764 = call i64 @kx_map_new(i32 0, i32 0)
  %conf.649 = alloca i64
  store i64 %r.17764, ptr %conf.649
  %t.17765 = load i64, ptr %content.648
  %cast.17766 = inttoptr i64 %t.17765 to ptr
  %r.17767 = call i64 @SplitAll(ptr %cast.17766, ptr @.str.10)
  %lines.650 = alloca i64
  store i64 %r.17767, ptr %lines.650
  %section.651 = alloca ptr
  store ptr @.str.12, ptr %section.651
  %i.652 = alloca i32
  store i32 0, ptr %i.652
  br label %for.cond.17768
for.cond.17768:
  %t.17772 = load i32, ptr %i.652
  %t.17773 = load i64, ptr %lines.650
  %r.17774 = call i64 @kx_list_size(i64 %t.17773)
  %ext.17775 = sext i32 %t.17772 to i64
  %t.17776 = icmp slt i64 %ext.17775, %r.17774
  br i1 %t.17776, label %for.body.17769, label %for.end.17771
for.body.17769:
  %t.17777 = load i64, ptr %lines.650
  %t.17778 = load i32, ptr %i.652
  %ext.17780 = sext i32 %t.17778 to i64
  %r.17779 = call i64 @kx_list_get(i64 %t.17777, i64 %ext.17780)
  %line.653 = alloca i64
  store i64 0, ptr %line.653
  %t.17781 = load i64, ptr %line.653
  %ext.17783 = inttoptr i64 %t.17781 to ptr
  %r.17784 = call i1 @kx_str_eq(ptr %ext.17783, ptr @.str.12)
  %t.17785 = load i64, ptr %line.653
  %ext.17786 = inttoptr i64 %t.17785 to ptr
  %r.17787 = call i1 @kx_str_starts_with(ptr %ext.17786, ptr @.str.552)
  %t.17788 = or i1 %r.17784, %r.17787
  br i1 %t.17788, label %if.then.17789, label %if.merge.17790
if.then.17789:
  br label %for.inc.17770
dead.17791:
  br label %if.merge.17790
if.merge.17790:
  %t.17792 = load i64, ptr %line.653
  %ext.17793 = inttoptr i64 %t.17792 to ptr
  %r.17794 = call i1 @kx_str_starts_with(ptr %ext.17793, ptr @.str.146)
  br i1 %r.17794, label %if.then.17795, label %if.merge.17796
if.then.17795:
  %t.17797 = load i64, ptr %line.653
  %end.654 = alloca i64
  store i64 0, ptr %end.654
  %t.17798 = load i64, ptr %end.654
  %ext.17799 = sext i32 0 to i64
  %t.17800 = icmp sgt i64 %t.17798, %ext.17799
  br i1 %t.17800, label %if.then.17801, label %if.merge.17802
if.then.17801:
  %t.17803 = load i64, ptr %line.653
  %ext.17804 = inttoptr i64 %t.17803 to ptr
  %ext.17805 = sext i32 1 to i64
  %t.17806 = load i64, ptr %end.654
  %ext.17807 = sext i32 1 to i64
  %t.17808 = sub i64 %t.17806, %ext.17807
  %r.17809 = call ptr @kx_str_substr(ptr %ext.17804, i64 %ext.17805, i64 %t.17808)
  store ptr %r.17809, ptr %section.651
  br label %if.merge.17802
if.merge.17802:
  br label %for.inc.17770
dead.17810:
  br label %if.merge.17796
if.merge.17796:
  %t.17811 = load i64, ptr %line.653
  %eq.655 = alloca i64
  store i64 0, ptr %eq.655
  %t.17812 = load i64, ptr %eq.655
  %ext.17813 = sext i32 0 to i64
  %t.17814 = icmp sgt i64 %t.17812, %ext.17813
  br i1 %t.17814, label %if.then.17815, label %if.merge.17816
if.then.17815:
  %t.17817 = load i64, ptr %line.653
  %ext.17818 = inttoptr i64 %t.17817 to ptr
  %ext.17819 = sext i32 0 to i64
  %t.17820 = load i64, ptr %eq.655
  %r.17821 = call ptr @kx_str_substr(ptr %ext.17818, i64 %ext.17819, i64 %t.17820)
  %key.656 = alloca i64
  store i64 0, ptr %key.656
  %t.17822 = load i64, ptr %line.653
  %t.17823 = load i64, ptr %eq.655
  %ext.17824 = sext i32 1 to i64
  %t.17825 = add i64 %t.17823, %ext.17824
  %ext.17826 = inttoptr i64 %t.17822 to ptr
  %t.17827 = load i64, ptr %line.653
  %t.17828 = load i64, ptr %eq.655
  %t.17829 = sub i64 %t.17827, %t.17828
  %ext.17830 = sext i32 1 to i64
  %t.17831 = sub i64 %t.17829, %ext.17830
  %r.17832 = call ptr @kx_str_substr(ptr %ext.17826, i64 %t.17825, i64 %t.17831)
  %val.657 = alloca i64
  store i64 0, ptr %val.657
  %t.17833 = load i64, ptr %val.657
  %ext.17834 = sext i32 2 to i64
  %t.17835 = icmp sge i64 %t.17833, %ext.17834
  %t.17836 = load i64, ptr %val.657
  %ext.17837 = inttoptr i64 %t.17836 to ptr
  %r.17838 = call i1 @kx_str_starts_with(ptr %ext.17837, ptr @.str.62)
  %t.17839 = and i1 %t.17835, %r.17838
  %t.17840 = load i64, ptr %val.657
  %ext.17841 = inttoptr i64 %t.17840 to ptr
  %r.17842 = call i1 @kx_str_ends_with(ptr %ext.17841, ptr @.str.62)
  %t.17843 = and i1 %t.17839, %r.17842
  br i1 %t.17843, label %if.then.17844, label %if.merge.17845
if.then.17844:
  %t.17846 = load i64, ptr %val.657
  %ext.17847 = inttoptr i64 %t.17846 to ptr
  %ext.17848 = sext i32 1 to i64
  %t.17849 = load i64, ptr %val.657
  %ext.17850 = sext i32 2 to i64
  %t.17851 = sub i64 %t.17849, %ext.17850
  %r.17852 = call ptr @kx_str_substr(ptr %ext.17847, i64 %ext.17848, i64 %t.17851)
  %ptrtoint.17853 = ptrtoint ptr %r.17852 to i64
  store i64 %ptrtoint.17853, ptr %val.657
  br label %if.merge.17845
if.merge.17845:
  %t.17854 = load i64, ptr %conf.649
  %t.17855 = load ptr, ptr %section.651
  %r.17857 = call ptr @kx_str_cat(ptr %t.17855, ptr @.str.60)
  %t.17858 = load i64, ptr %key.656
  %ext.17860 = call ptr @kx_int_str(i64 %t.17858)
  %r.17861 = call ptr @kx_str_cat(ptr %r.17857, ptr %ext.17860)
  %t.17862 = load i64, ptr %val.657
  %c.17863 = ptrtoint ptr %r.17861 to i64
  call void @kx_map_set(i64 %t.17854, i64 %c.17863, i64 %t.17862)
  br label %if.merge.17816
if.merge.17816:
  br label %for.inc.17770
for.inc.17770:
  %t.17864 = load i32, ptr %i.652
  %t.17865 = add i32 %t.17864, 1
  store i32 %t.17865, ptr %i.652
  br label %for.cond.17768
for.end.17771:
  %t.17866 = load i64, ptr %conf.649
  ret i64 %t.17866
dead.17867:
  ret i64 0
}

define i64 @CmdInit(i64 %name) {
entry:
  %name.addr = alloca i64
  store i64 %name, ptr %name.addr
  %t.17868 = load i64, ptr %name.addr
  %dir.658 = alloca i64
  store i64 %t.17868, ptr %dir.658
  %r.17869 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.553)
  %t.17870 = load i64, ptr %dir.658
  %r.17871 = call ptr @kx_int_str(i64 %t.17870)
  %r.17872 = call ptr @kx_str_cat(ptr %r.17869, ptr %r.17871)
  %r.17873 = call ptr @kx_str_cat(ptr %r.17872, ptr @.str.12)
  %r.17874 = call i64 @kx_system(ptr %r.17873)
  %r.17875 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.554)
  %t.17876 = load i64, ptr %name.addr
  %r.17877 = call ptr @kx_int_str(i64 %t.17876)
  %r.17878 = call ptr @kx_str_cat(ptr %r.17875, ptr %r.17877)
  %r.17879 = call ptr @kx_str_cat(ptr %r.17878, ptr @.str.555)
  %conf.659 = alloca ptr
  store ptr %r.17879, ptr %conf.659
  %r.17880 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.17881 = load i64, ptr %dir.658
  %r.17882 = call ptr @kx_int_str(i64 %t.17881)
  %r.17883 = call ptr @kx_str_cat(ptr %r.17880, ptr %r.17882)
  %r.17884 = call ptr @kx_str_cat(ptr %r.17883, ptr @.str.556)
  %t.17885 = load ptr, ptr %conf.659
  %r.17886 = call i64 @kx_write_file(ptr %r.17884, ptr %t.17885)
  %r.17887 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.17888 = load i64, ptr %dir.658
  %r.17889 = call ptr @kx_int_str(i64 %t.17888)
  %r.17890 = call ptr @kx_str_cat(ptr %r.17887, ptr %r.17889)
  %r.17891 = call ptr @kx_str_cat(ptr %r.17890, ptr @.str.557)
  %t.17892 = load i64, ptr %name.addr
  %ext.17894 = call ptr @kx_int_str(i64 %t.17892)
  %r.17895 = call ptr @kx_str_cat(ptr @.str.558, ptr %ext.17894)
  %r.17897 = call ptr @kx_str_cat(ptr %r.17895, ptr @.str.559)
  %r.17898 = call i64 @kx_write_file(ptr %r.17891, ptr %r.17897)
  %r.17899 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.560)
  %t.17900 = load i64, ptr %name.addr
  %r.17901 = call ptr @kx_int_str(i64 %t.17900)
  %r.17902 = call ptr @kx_str_cat(ptr %r.17899, ptr %r.17901)
  %r.17903 = call ptr @kx_str_cat(ptr %r.17902, ptr @.str.12)
  %r.17904 = call i64 @kx_println(ptr %r.17903)
  %ext.17905 = sext i32 0 to i64
  ret i64 %ext.17905
dead.17906:
  ret i64 0
}

define i64 @CmdBuild(ptr %dir) {
entry:
  %dir.addr = alloca ptr
  store ptr %dir, ptr %dir.addr
  %t.17907 = load ptr, ptr %dir.addr
  %r.17909 = call ptr @kx_str_cat(ptr @.str.12, ptr %t.17907)
  %r.17911 = call ptr @kx_str_cat(ptr %r.17909, ptr @.str.561)
  %r.17912 = call i64 @ParseKxConf(ptr %r.17911)
  %conf.660 = alloca i64
  store i64 %r.17912, ptr %conf.660
  %entry.661 = alloca ptr
  store ptr @.str.12, ptr %entry.661
  %t.17913 = load i64, ptr %conf.660
  %c.17914 = ptrtoint ptr @.str.562 to i64
  %r.17915 = call i1 @kx_map_has(i64 %t.17913, i64 %c.17914)
  br i1 %r.17915, label %if.then.17916, label %if.merge.17917
if.then.17916:
  %t.17918 = load i64, ptr %conf.660
  %c.17920 = ptrtoint ptr @.str.562 to i64
  %r.17919 = call i64 @kx_map_get(i64 %t.17918, i64 %c.17920)
  %ext.17922 = call ptr @kx_int_str(i64 %r.17919)
  %r.17923 = call ptr @kx_str_cat(ptr %ext.17922, ptr @.str.12)
  store ptr %r.17923, ptr %entry.661
  br label %if.merge.17917
if.merge.17917:
  %t.17924 = load ptr, ptr %entry.661
  %r.17926 = call i1 @kx_str_eq(ptr %t.17924, ptr @.str.12)
  br i1 %r.17926, label %if.then.17927, label %if.merge.17928
if.then.17927:
  store ptr @.str.563, ptr %entry.661
  br label %if.merge.17928
if.merge.17928:
  %t.17929 = load ptr, ptr %dir.addr
  %r.17931 = call ptr @kx_str_cat(ptr @.str.12, ptr %t.17929)
  %r.17933 = call ptr @kx_str_cat(ptr %r.17931, ptr @.str.13)
  %t.17934 = load ptr, ptr %entry.661
  %r.17936 = call ptr @kx_str_cat(ptr %r.17933, ptr %t.17934)
  %r.17937 = call i64 @kx_read_file(ptr %r.17936)
  %src.662 = alloca i64
  store i64 %r.17937, ptr %src.662
  %t.17938 = load i64, ptr %src.662
  %ext.17940 = inttoptr i64 %t.17938 to ptr
  %r.17941 = call i1 @kx_str_eq(ptr %ext.17940, ptr @.str.12)
  br i1 %r.17941, label %if.then.17942, label %if.merge.17943
if.then.17942:
  %t.17944 = load ptr, ptr %dir.addr
  %r.17945 = call i64 @kx_read_file(ptr %t.17944)
  store i64 %r.17945, ptr %src.662
  %t.17946 = load i64, ptr %src.662
  %ext.17948 = inttoptr i64 %t.17946 to ptr
  %r.17949 = call i1 @kx_str_eq(ptr %ext.17948, ptr @.str.12)
  br i1 %r.17949, label %if.then.17950, label %if.merge.17951
if.then.17950:
  %r.17952 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.564)
  %t.17953 = load ptr, ptr %dir.addr
  %r.17954 = call ptr @kx_str_cat(ptr %r.17952, ptr %t.17953)
  %r.17955 = call ptr @kx_str_cat(ptr %r.17954, ptr @.str.13)
  %t.17956 = load ptr, ptr %entry.661
  %r.17957 = call ptr @kx_str_cat(ptr %r.17955, ptr %t.17956)
  %r.17958 = call ptr @kx_str_cat(ptr %r.17957, ptr @.str.12)
  %r.17959 = call i64 @kx_println(ptr %r.17958)
  %ext.17960 = sext i32 1 to i64
  ret i64 %ext.17960
dead.17961:
  br label %if.merge.17951
if.merge.17951:
  %t.17962 = load ptr, ptr %dir.addr
  store ptr %t.17962, ptr %entry.661
  br label %if.merge.17943
if.merge.17943:
  %t.17963 = load i64, ptr %src.662
  %cast.17964 = inttoptr i64 %t.17963 to ptr
  %r.17965 = call i64 @LexAll(ptr %cast.17964)
  %tokens.663 = alloca i64
  store i64 %r.17965, ptr %tokens.663
  %r.17966 = call i64 @kx_list_new(i32 0)
  %pos.664 = alloca i64
  store i64 %r.17966, ptr %pos.664
  %t.17967 = load i64, ptr %pos.664
  %ext.17968 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.17967, i64 %ext.17968)
  %r.17969 = call i64 @kx_list_new(i32 0)
  %arena.665 = alloca i64
  store i64 %r.17969, ptr %arena.665
  %r.17970 = call i64 @kx_list_new(i32 0)
  %errors.666 = alloca i64
  store i64 %r.17970, ptr %errors.666
  %t.17971 = load i64, ptr %tokens.663
  %t.17972 = load i64, ptr %pos.664
  %t.17973 = load i64, ptr %arena.665
  %t.17974 = load i64, ptr %errors.666
  %t.17975 = load ptr, ptr %entry.661
  %r.17976 = call i64 @ParseProgram(i64 %t.17971, i64 %t.17972, i64 %t.17973, i64 %t.17974, ptr %t.17975)
  %rootIdx.667 = alloca i64
  store i64 %r.17976, ptr %rootIdx.667
  %t.17977 = load i64, ptr %errors.666
  %r.17978 = call i64 @kx_list_size(i64 %t.17977)
  %ext.17979 = sext i32 0 to i64
  %t.17980 = icmp sgt i64 %r.17978, %ext.17979
  br i1 %t.17980, label %if.then.17981, label %if.merge.17982
if.then.17981:
  %_ei.668 = alloca i32
  store i32 0, ptr %_ei.668
  br label %for.cond.17983
for.cond.17983:
  %t.17987 = load i32, ptr %_ei.668
  %t.17988 = load i64, ptr %errors.666
  %r.17989 = call i64 @kx_list_size(i64 %t.17988)
  %ext.17990 = sext i32 %t.17987 to i64
  %t.17991 = icmp slt i64 %ext.17990, %r.17989
  br i1 %t.17991, label %for.body.17984, label %for.end.17986
for.body.17984:
  %t.17992 = load i64, ptr %errors.666
  %t.17993 = load i32, ptr %_ei.668
  %ext.17995 = sext i32 %t.17993 to i64
  %r.17994 = call i64 @kx_list_get(i64 %t.17992, i64 %ext.17995)
  %ptr.17996 = inttoptr i64 %r.17994 to ptr
  %r.17997 = call i64 @kx_println(ptr %ptr.17996)
  br label %for.inc.17985
for.inc.17985:
  %t.17998 = load i32, ptr %_ei.668
  %t.17999 = add i32 %t.17998, 1
  store i32 %t.17999, ptr %_ei.668
  br label %for.cond.17983
for.end.17986:
  %ext.18000 = sext i32 1 to i64
  ret i64 %ext.18000
dead.18001:
  br label %if.merge.17982
if.merge.17982:
  %t.18002 = load i64, ptr %arena.665
  %t.18003 = load i64, ptr %rootIdx.667
  %r.18004 = call i64 @kx_list_get(i64 %t.18002, i64 %t.18003)
  %root.669 = alloca i64
  store i64 %r.18004, ptr %root.669
  %r.18005 = call i64 @NewIR()
  %g.670 = alloca i64
  store i64 %r.18005, ptr %g.670
  %t.18006 = load i64, ptr %g.670
  %r.18007 = call i64 @Emit(i64 %t.18006, ptr @.str.565)
  %t.18008 = load i64, ptr %g.670
  %r.18009 = call i64 @Emit(i64 %t.18008, ptr @.str.12)
  %t.18010 = load i64, ptr %g.670
  %r.18011 = call i64 @EmitDecls(i64 %t.18010)
  %t.18012 = load i64, ptr %g.670
  %t.18013 = load i64, ptr %root.669
  %t.18014 = load i64, ptr %arena.665
  %r.18015 = call i64 @InferSignatures(i64 %t.18012, i64 %t.18013, i64 %t.18014)
  %i.671 = alloca i32
  store i32 0, ptr %i.671
  br label %for.cond.18016
for.cond.18016:
  %t.18020 = load i32, ptr %i.671
  %t.18021 = load i64, ptr %root.669
  %r.18022 = call i64 @kx_list_size(i64 %t.18021)
  %ext.18023 = sext i32 %t.18020 to i64
  %t.18024 = icmp slt i64 %ext.18023, %r.18022
  br i1 %t.18024, label %for.body.18017, label %for.end.18019
for.body.18017:
  %t.18025 = load i64, ptr %arena.665
  %t.18026 = load i64, ptr %root.669
  %t.18027 = load i32, ptr %i.671
  %cast.18028 = sext i32 %t.18027 to i64
  %r.18029 = call i64 @Child(i64 %t.18025, i64 %t.18026, i64 %cast.18028)
  %d.672 = alloca i64
  store i64 %r.18029, ptr %d.672
  %t.18030 = load i64, ptr %d.672
  %ext.18032 = inttoptr i64 %t.18030 to ptr
  %r.18033 = call i1 @kx_str_eq(ptr %ext.18032, ptr @.str.19)
  br i1 %r.18033, label %if.then.18034, label %if.merge.18035
if.then.18034:
  %t.18036 = load i64, ptr %arena.665
  %t.18037 = load i64, ptr %d.672
  %cast.18038 = sext i32 0 to i64
  %r.18039 = call i64 @Child(i64 %t.18036, i64 %t.18037, i64 %cast.18038)
  %r.18040 = call i64 @kx_struct_get(i64 %r.18039, i32 1)
  %field.18041 = inttoptr i64 %r.18040 to ptr
  %sname.673 = alloca ptr
  store ptr %field.18041, ptr %sname.673
  %fieldStr.674 = alloca ptr
  store ptr @.str.12, ptr %fieldStr.674
  %fi.675 = alloca i32
  store i32 1, ptr %fi.675
  br label %for.cond.18042
for.cond.18042:
  %t.18046 = load i32, ptr %fi.675
  %t.18047 = load i64, ptr %d.672
  %r.18048 = call i64 @kx_list_size(i64 %t.18047)
  %ext.18049 = sext i32 %t.18046 to i64
  %t.18050 = icmp slt i64 %ext.18049, %r.18048
  br i1 %t.18050, label %for.body.18043, label %for.end.18045
for.body.18043:
  %t.18051 = load i64, ptr %arena.665
  %t.18052 = load i64, ptr %d.672
  %t.18053 = load i32, ptr %fi.675
  %cast.18054 = sext i32 %t.18053 to i64
  %r.18055 = call i64 @Child(i64 %t.18051, i64 %t.18052, i64 %cast.18054)
  %f.676 = alloca i64
  store i64 %r.18055, ptr %f.676
  %t.18056 = load i64, ptr %f.676
  %ext.18058 = inttoptr i64 %t.18056 to ptr
  %r.18059 = call i1 @kx_str_eq(ptr %ext.18058, ptr @.str.96)
  br i1 %r.18059, label %if.then.18060, label %if.merge.18061
if.then.18060:
  %t.18062 = load ptr, ptr %fieldStr.674
  %r.18064 = call i1 @kx_str_eq(ptr %t.18062, ptr @.str.12)
  br i1 %r.18064, label %if.then.18065, label %if.merge.18066
if.then.18065:
  %t.18067 = load ptr, ptr %fieldStr.674
  %r.18069 = call ptr @kx_str_cat(ptr %t.18067, ptr @.str.97)
  store ptr %r.18069, ptr %fieldStr.674
  br label %if.merge.18066
if.merge.18066:
  %t.18070 = load ptr, ptr %fieldStr.674
  %t.18071 = load i64, ptr %f.676
  %ext.18073 = call ptr @kx_int_str(i64 %t.18071)
  %r.18074 = call ptr @kx_str_cat(ptr %t.18070, ptr %ext.18073)
  store ptr %r.18074, ptr %fieldStr.674
  br label %if.merge.18061
if.merge.18061:
  br label %for.inc.18044
for.inc.18044:
  %t.18075 = load i32, ptr %fi.675
  %t.18076 = add i32 %t.18075, 1
  store i32 %t.18076, ptr %fi.675
  br label %for.cond.18042
for.end.18045:
  %t.18077 = load i64, ptr %g.670
  %t.18078 = load ptr, ptr %sname.673
  %t.18079 = load ptr, ptr %fieldStr.674
  %c.18080 = ptrtoint ptr %t.18078 to i64
  %c.18081 = ptrtoint ptr %t.18079 to i64
  call void @kx_map_set(i64 %t.18077, i64 %c.18080, i64 %c.18081)
  br label %if.merge.18035
if.merge.18035:
  %t.18082 = load i64, ptr %d.672
  %ext.18084 = inttoptr i64 %t.18082 to ptr
  %r.18085 = call i1 @kx_str_eq(ptr %ext.18084, ptr @.str.208)
  br i1 %r.18085, label %if.then.18086, label %if.merge.18087
if.then.18086:
  %t.18088 = load i64, ptr %g.670
  %t.18089 = load i64, ptr %d.672
  %t.18090 = load i64, ptr %arena.665
  %r.18091 = call i64 @GenFunc(i64 %t.18088, i64 %t.18089, i64 %t.18090)
  br label %if.merge.18087
if.merge.18087:
  %t.18092 = load i64, ptr %d.672
  %ext.18094 = inttoptr i64 %t.18092 to ptr
  %r.18095 = call i1 @kx_str_eq(ptr %ext.18094, ptr @.str.58)
  br i1 %r.18095, label %if.then.18096, label %if.merge.18097
if.then.18096:
  br label %if.merge.18097
if.merge.18097:
  br label %for.inc.18018
for.inc.18018:
  %t.18098 = load i32, ptr %i.671
  %t.18099 = add i32 %t.18098, 1
  store i32 %t.18099, ptr %i.671
  br label %for.cond.18016
for.end.18019:
  %out.677 = alloca ptr
  store ptr @.str.12, ptr %out.677
  %i.678 = alloca i32
  store i32 0, ptr %i.678
  br label %for.cond.18100
for.cond.18100:
  %t.18104 = load i32, ptr %i.678
  %t.18105 = load i64, ptr %g.670
  %r.18106 = call i64 @kx_list_size(i64 %t.18105)
  %ext.18107 = sext i32 %t.18104 to i64
  %t.18108 = icmp slt i64 %ext.18107, %r.18106
  br i1 %t.18108, label %for.body.18101, label %for.end.18103
for.body.18101:
  %t.18109 = load ptr, ptr %out.677
  %t.18110 = load i64, ptr %g.670
  %t.18111 = load i32, ptr %i.678
  %ext.18113 = sext i32 %t.18111 to i64
  %r.18112 = call i64 @kx_list_get(i64 %t.18110, i64 %ext.18113)
  %ext.18115 = call ptr @kx_int_str(i64 %r.18112)
  %r.18116 = call ptr @kx_str_cat(ptr %t.18109, ptr %ext.18115)
  %r.18118 = call ptr @kx_str_cat(ptr %r.18116, ptr @.str.10)
  store ptr %r.18118, ptr %out.677
  br label %for.inc.18102
for.inc.18102:
  %t.18119 = load i32, ptr %i.678
  %t.18120 = add i32 %t.18119, 1
  store i32 %t.18120, ptr %i.678
  br label %for.cond.18100
for.end.18103:
  %pi.679 = alloca i32
  store i32 0, ptr %pi.679
  br label %for.cond.18121
for.cond.18121:
  %t.18125 = load i32, ptr %pi.679
  %t.18126 = load i64, ptr %g.670
  %r.18127 = call i64 @kx_list_size(i64 %t.18126)
  %ext.18128 = sext i32 %t.18125 to i64
  %t.18129 = icmp slt i64 %ext.18128, %r.18127
  br i1 %t.18129, label %for.body.18122, label %for.end.18124
for.body.18122:
  %t.18130 = load ptr, ptr %out.677
  %t.18131 = load i64, ptr %g.670
  %t.18132 = load i32, ptr %pi.679
  %ext.18134 = sext i32 %t.18132 to i64
  %r.18133 = call i64 @kx_list_get(i64 %t.18131, i64 %ext.18134)
  %ext.18136 = call ptr @kx_int_str(i64 %r.18133)
  %r.18137 = call ptr @kx_str_cat(ptr %t.18130, ptr %ext.18136)
  %r.18139 = call ptr @kx_str_cat(ptr %r.18137, ptr @.str.10)
  store ptr %r.18139, ptr %out.677
  br label %for.inc.18123
for.inc.18123:
  %t.18140 = load i32, ptr %pi.679
  %t.18141 = add i32 %t.18140, 1
  store i32 %t.18141, ptr %pi.679
  br label %for.cond.18121
for.end.18124:
  %_pname.680 = alloca ptr
  store ptr @.str.566, ptr %_pname.680
  %t.18142 = load i64, ptr %conf.660
  %c.18143 = ptrtoint ptr @.str.567 to i64
  %r.18144 = call i1 @kx_map_has(i64 %t.18142, i64 %c.18143)
  br i1 %r.18144, label %if.then.18145, label %if.merge.18146
if.then.18145:
  %t.18147 = load i64, ptr %conf.660
  %c.18149 = ptrtoint ptr @.str.567 to i64
  %r.18148 = call i64 @kx_map_get(i64 %t.18147, i64 %c.18149)
  %inttoptr.18150 = inttoptr i64 %r.18148 to ptr
  store ptr %inttoptr.18150, ptr %_pname.680
  br label %if.merge.18146
if.merge.18146:
  %t.18151 = load ptr, ptr %dir.addr
  %_base.681 = alloca ptr
  store ptr %t.18151, ptr %_base.681
  %t.18152 = load ptr, ptr %dir.addr
  %r.18153 = call i64 @kx_str_len(ptr %t.18152)
  %ext.18154 = sext i32 1 to i64
  %t.18155 = sub i64 %r.18153, %ext.18154
  %_sl.682 = alloca i64
  store i64 %t.18155, ptr %_sl.682
  br label %w.cond.18156
w.cond.18156:
  %t.18159 = load i64, ptr %_sl.682
  %ext.18160 = sext i32 0 to i64
  %t.18161 = icmp sge i64 %t.18159, %ext.18160
  %t.18162 = load ptr, ptr %dir.addr
  %t.18163 = load i64, ptr %_sl.682
  %ext.18164 = sext i32 1 to i64
  %r.18165 = call ptr @kx_str_substr(ptr %t.18162, i64 %t.18163, i64 %ext.18164)
  %r.18167 = call i1 @kx_str_eq(ptr %r.18165, ptr @.str.13)
  %t.18168 = and i1 %t.18161, %r.18167
  br i1 %t.18168, label %w.body.18157, label %w.end.18158
w.body.18157:
  %t.18169 = load i64, ptr %_sl.682
  %ext.18170 = sext i32 1 to i64
  %t.18171 = sub i64 %t.18169, %ext.18170
  store i64 %t.18171, ptr %_sl.682
  br label %w.cond.18156
w.end.18158:
  %t.18172 = load ptr, ptr %dir.addr
  %t.18173 = load i64, ptr %_sl.682
  %ext.18174 = sext i32 1 to i64
  %t.18175 = add i64 %t.18173, %ext.18174
  %t.18176 = load ptr, ptr %dir.addr
  %r.18177 = call i64 @kx_str_len(ptr %t.18176)
  %t.18178 = load i64, ptr %_sl.682
  %t.18179 = sub i64 %r.18177, %t.18178
  %ext.18180 = sext i32 1 to i64
  %t.18181 = sub i64 %t.18179, %ext.18180
  %r.18182 = call ptr @kx_str_substr(ptr %t.18172, i64 %t.18175, i64 %t.18181)
  %_dirName.683 = alloca ptr
  store ptr %r.18182, ptr %_dirName.683
  %_ext.684 = alloca ptr
  store ptr @.str.12, ptr %_ext.684
  %t.18183 = load ptr, ptr %_dirName.683
  %r.18184 = call i64 @kx_str_len(ptr %t.18183)
  %ext.18185 = sext i32 3 to i64
  %t.18186 = icmp sgt i64 %r.18184, %ext.18185
  %t.18187 = load ptr, ptr %_dirName.683
  %t.18188 = load ptr, ptr %_dirName.683
  %r.18189 = call i64 @kx_str_len(ptr %t.18188)
  %ext.18190 = sext i32 3 to i64
  %t.18191 = sub i64 %r.18189, %ext.18190
  %ext.18192 = sext i32 3 to i64
  %r.18193 = call ptr @kx_str_substr(ptr %t.18187, i64 %t.18191, i64 %ext.18192)
  %r.18195 = call i1 @kx_str_eq(ptr %r.18193, ptr @.str.568)
  %t.18196 = and i1 %t.18186, %r.18195
  br i1 %t.18196, label %if.then.18197, label %if.merge.18198
if.then.18197:
  store ptr @.str.568, ptr %_ext.684
  %t.18199 = load ptr, ptr %dir.addr
  %ext.18200 = sext i32 0 to i64
  %t.18201 = load ptr, ptr %dir.addr
  %r.18202 = call i64 @kx_str_len(ptr %t.18201)
  %ext.18203 = sext i32 3 to i64
  %t.18204 = sub i64 %r.18202, %ext.18203
  %r.18205 = call ptr @kx_str_substr(ptr %t.18199, i64 %ext.18200, i64 %t.18204)
  store ptr %r.18205, ptr %_base.681
  br label %if.merge.18198
if.merge.18198:
  %t.18206 = load ptr, ptr %_base.681
  %r.18208 = call ptr @kx_str_cat(ptr %t.18206, ptr @.str.569)
  %buildDir.685 = alloca ptr
  store ptr %r.18208, ptr %buildDir.685
  %r.18209 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.553)
  %t.18210 = load ptr, ptr %buildDir.685
  %r.18211 = call ptr @kx_str_cat(ptr %r.18209, ptr %t.18210)
  %r.18212 = call ptr @kx_str_cat(ptr %r.18211, ptr @.str.12)
  %r.18213 = call i64 @kx_system(ptr %r.18212)
  %r.18214 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18215 = load ptr, ptr %buildDir.685
  %r.18216 = call ptr @kx_str_cat(ptr %r.18214, ptr %t.18215)
  %r.18217 = call ptr @kx_str_cat(ptr %r.18216, ptr @.str.570)
  %llPath.686 = alloca ptr
  store ptr %r.18217, ptr %llPath.686
  %r.18218 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18219 = load ptr, ptr %buildDir.685
  %r.18220 = call ptr @kx_str_cat(ptr %r.18218, ptr %t.18219)
  %r.18221 = call ptr @kx_str_cat(ptr %r.18220, ptr @.str.571)
  %objPath.687 = alloca ptr
  store ptr %r.18221, ptr %objPath.687
  %r.18222 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18223 = load ptr, ptr %buildDir.685
  %r.18224 = call ptr @kx_str_cat(ptr %r.18222, ptr %t.18223)
  %r.18225 = call ptr @kx_str_cat(ptr %r.18224, ptr @.str.13)
  %t.18226 = load ptr, ptr %_pname.680
  %r.18227 = call ptr @kx_str_cat(ptr %r.18225, ptr %t.18226)
  %r.18228 = call ptr @kx_str_cat(ptr %r.18227, ptr @.str.12)
  %binPath.688 = alloca ptr
  store ptr %r.18228, ptr %binPath.688
  %t.18229 = load ptr, ptr %llPath.686
  %t.18230 = load ptr, ptr %out.677
  %r.18231 = call i64 @kx_write_file(ptr %t.18229, ptr %t.18230)
  %r.18232 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.572)
  %t.18233 = load ptr, ptr %entry.661
  %r.18234 = call ptr @kx_str_cat(ptr %r.18232, ptr %t.18233)
  %r.18235 = call ptr @kx_str_cat(ptr %r.18234, ptr @.str.573)
  %t.18236 = load ptr, ptr %llPath.686
  %r.18237 = call ptr @kx_str_cat(ptr %r.18235, ptr %t.18236)
  %r.18238 = call ptr @kx_str_cat(ptr %r.18237, ptr @.str.12)
  %r.18239 = call i64 @kx_println(ptr %r.18238)
  %r.18240 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.574)
  %t.18241 = load ptr, ptr %llPath.686
  %r.18242 = call ptr @kx_str_cat(ptr %r.18240, ptr %t.18241)
  %r.18243 = call ptr @kx_str_cat(ptr %r.18242, ptr @.str.575)
  %t.18244 = load ptr, ptr %objPath.687
  %r.18245 = call ptr @kx_str_cat(ptr %r.18243, ptr %t.18244)
  %r.18246 = call ptr @kx_str_cat(ptr %r.18245, ptr @.str.576)
  %t.18247 = load ptr, ptr %objPath.687
  %r.18248 = call ptr @kx_str_cat(ptr %r.18246, ptr %t.18247)
  %r.18249 = call ptr @kx_str_cat(ptr %r.18248, ptr @.str.577)
  %t.18250 = load ptr, ptr %binPath.688
  %r.18251 = call ptr @kx_str_cat(ptr %r.18249, ptr %t.18250)
  %r.18252 = call ptr @kx_str_cat(ptr %r.18251, ptr @.str.578)
  %linkCmd.689 = alloca ptr
  store ptr %r.18252, ptr %linkCmd.689
  %t.18253 = load ptr, ptr %linkCmd.689
  %r.18254 = call i64 @kx_system(ptr %t.18253)
  %rc.690 = alloca i64
  store i64 %r.18254, ptr %rc.690
  %t.18255 = load i64, ptr %rc.690
  %ext.18256 = sext i32 0 to i64
  %t.18257 = icmp ne i64 %t.18255, %ext.18256
  br i1 %t.18257, label %if.then.18258, label %if.merge.18259
if.then.18258:
  %r.18260 = call i64 @kx_println(ptr @.str.579)
  %ext.18261 = sext i32 1 to i64
  ret i64 %ext.18261
dead.18262:
  br label %if.merge.18259
if.merge.18259:
  %r.18263 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.580)
  %t.18264 = load ptr, ptr %binPath.688
  %r.18265 = call ptr @kx_str_cat(ptr %r.18263, ptr %t.18264)
  %r.18266 = call ptr @kx_str_cat(ptr %r.18265, ptr @.str.12)
  %r.18267 = call i64 @kx_println(ptr %r.18266)
  %ext.18268 = sext i32 0 to i64
  ret i64 %ext.18268
dead.18269:
  ret i64 0
}

define i64 @CmdRun(ptr %dir) {
entry:
  %dir.addr = alloca ptr
  store ptr %dir, ptr %dir.addr
  %r.18270 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18271 = load ptr, ptr %dir.addr
  %r.18272 = call ptr @kx_str_cat(ptr %r.18270, ptr %t.18271)
  %r.18273 = call ptr @kx_str_cat(ptr %r.18272, ptr @.str.556)
  %r.18274 = call i64 @ParseKxConf(ptr %r.18273)
  %conf.691 = alloca i64
  store i64 %r.18274, ptr %conf.691
  %name.692 = alloca ptr
  store ptr @.str.12, ptr %name.692
  %t.18275 = load i64, ptr %conf.691
  %c.18276 = ptrtoint ptr @.str.567 to i64
  %r.18277 = call i1 @kx_map_has(i64 %t.18275, i64 %c.18276)
  br i1 %r.18277, label %if.then.18278, label %if.merge.18279
if.then.18278:
  %t.18280 = load i64, ptr %conf.691
  %c.18282 = ptrtoint ptr @.str.567 to i64
  %r.18281 = call i64 @kx_map_get(i64 %t.18280, i64 %c.18282)
  %inttoptr.18283 = inttoptr i64 %r.18281 to ptr
  store ptr %inttoptr.18283, ptr %name.692
  br label %if.merge.18279
if.merge.18279:
  %t.18284 = load ptr, ptr %name.692
  %r.18286 = call i1 @kx_str_eq(ptr %t.18284, ptr @.str.12)
  br i1 %r.18286, label %if.then.18287, label %if.merge.18288
if.then.18287:
  store ptr @.str.566, ptr %name.692
  br label %if.merge.18288
if.merge.18288:
  %t.18289 = load ptr, ptr %dir.addr
  %r.18290 = call i64 @CmdBuild(ptr %t.18289)
  %rc.693 = alloca i64
  store i64 %r.18290, ptr %rc.693
  %t.18291 = load i64, ptr %rc.693
  %ext.18292 = sext i32 0 to i64
  %t.18293 = icmp ne i64 %t.18291, %ext.18292
  br i1 %t.18293, label %if.then.18294, label %if.merge.18295
if.then.18294:
  %t.18296 = load i64, ptr %rc.693
  ret i64 %t.18296
dead.18297:
  br label %if.merge.18295
if.merge.18295:
  %r.18298 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18299 = load ptr, ptr %dir.addr
  %r.18300 = call ptr @kx_str_cat(ptr %r.18298, ptr %t.18299)
  %r.18301 = call ptr @kx_str_cat(ptr %r.18300, ptr @.str.581)
  %t.18302 = load ptr, ptr %name.692
  %r.18303 = call ptr @kx_str_cat(ptr %r.18301, ptr %t.18302)
  %r.18304 = call ptr @kx_str_cat(ptr %r.18303, ptr @.str.12)
  %r.18305 = call i64 @kx_system(ptr %r.18304)
  ret i64 %r.18305
dead.18306:
  ret i64 0
}

define i64 @CmdCheck(ptr %dir) {
entry:
  %dir.addr = alloca ptr
  store ptr %dir, ptr %dir.addr
  %entry.694 = alloca ptr
  store ptr @.str.563, ptr %entry.694
  %r.18307 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.12)
  %t.18308 = load ptr, ptr %dir.addr
  %r.18309 = call ptr @kx_str_cat(ptr %r.18307, ptr %t.18308)
  %r.18310 = call ptr @kx_str_cat(ptr %r.18309, ptr @.str.13)
  %t.18311 = load ptr, ptr %entry.694
  %r.18312 = call ptr @kx_str_cat(ptr %r.18310, ptr %t.18311)
  %r.18313 = call ptr @kx_str_cat(ptr %r.18312, ptr @.str.12)
  %r.18314 = call i64 @kx_read_file(ptr %r.18313)
  %src.695 = alloca i64
  store i64 %r.18314, ptr %src.695
  %t.18315 = load i64, ptr %src.695
  %ext.18317 = inttoptr i64 %t.18315 to ptr
  %r.18318 = call i1 @kx_str_eq(ptr %ext.18317, ptr @.str.12)
  br i1 %r.18318, label %if.then.18319, label %if.merge.18320
if.then.18319:
  %r.18321 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.564)
  %t.18322 = load ptr, ptr %dir.addr
  %r.18323 = call ptr @kx_str_cat(ptr %r.18321, ptr %t.18322)
  %r.18324 = call ptr @kx_str_cat(ptr %r.18323, ptr @.str.13)
  %t.18325 = load ptr, ptr %entry.694
  %r.18326 = call ptr @kx_str_cat(ptr %r.18324, ptr %t.18325)
  %r.18327 = call ptr @kx_str_cat(ptr %r.18326, ptr @.str.12)
  %r.18328 = call i64 @kx_println(ptr %r.18327)
  %ext.18329 = sext i32 1 to i64
  ret i64 %ext.18329
dead.18330:
  br label %if.merge.18320
if.merge.18320:
  %t.18331 = load i64, ptr %src.695
  %cast.18332 = inttoptr i64 %t.18331 to ptr
  %r.18333 = call i64 @LexAll(ptr %cast.18332)
  %tokens.696 = alloca i64
  store i64 %r.18333, ptr %tokens.696
  %r.18334 = call i64 @kx_list_new(i32 0)
  %pos.697 = alloca i64
  store i64 %r.18334, ptr %pos.697
  %t.18335 = load i64, ptr %pos.697
  %ext.18336 = sext i32 0 to i64
  call void @kx_list_add(i64 %t.18335, i64 %ext.18336)
  %r.18337 = call i64 @kx_list_new(i32 0)
  %arena.698 = alloca i64
  store i64 %r.18337, ptr %arena.698
  %r.18338 = call i64 @kx_list_new(i32 0)
  %errors.699 = alloca i64
  store i64 %r.18338, ptr %errors.699
  %t.18339 = load i64, ptr %tokens.696
  %t.18340 = load i64, ptr %pos.697
  %t.18341 = load i64, ptr %arena.698
  %t.18342 = load i64, ptr %errors.699
  %t.18343 = load ptr, ptr %entry.694
  %r.18344 = call i64 @ParseProgram(i64 %t.18339, i64 %t.18340, i64 %t.18341, i64 %t.18342, ptr %t.18343)
  %rootIdx.700 = alloca i64
  store i64 %r.18344, ptr %rootIdx.700
  %t.18345 = load i64, ptr %errors.699
  %r.18346 = call i64 @kx_list_size(i64 %t.18345)
  %ext.18347 = sext i32 0 to i64
  %t.18348 = icmp sgt i64 %r.18346, %ext.18347
  br i1 %t.18348, label %if.then.18349, label %if.merge.18350
if.then.18349:
  %_ei.701 = alloca i32
  store i32 0, ptr %_ei.701
  br label %for.cond.18351
for.cond.18351:
  %t.18355 = load i32, ptr %_ei.701
  %t.18356 = load i64, ptr %errors.699
  %r.18357 = call i64 @kx_list_size(i64 %t.18356)
  %ext.18358 = sext i32 %t.18355 to i64
  %t.18359 = icmp slt i64 %ext.18358, %r.18357
  br i1 %t.18359, label %for.body.18352, label %for.end.18354
for.body.18352:
  %t.18360 = load i64, ptr %errors.699
  %t.18361 = load i32, ptr %_ei.701
  %ext.18363 = sext i32 %t.18361 to i64
  %r.18362 = call i64 @kx_list_get(i64 %t.18360, i64 %ext.18363)
  %ptr.18364 = inttoptr i64 %r.18362 to ptr
  %r.18365 = call i64 @kx_println(ptr %ptr.18364)
  br label %for.inc.18353
for.inc.18353:
  %t.18366 = load i32, ptr %_ei.701
  %t.18367 = add i32 %t.18366, 1
  store i32 %t.18367, ptr %_ei.701
  br label %for.cond.18351
for.end.18354:
  %ext.18368 = sext i32 1 to i64
  ret i64 %ext.18368
dead.18369:
  br label %if.merge.18350
if.merge.18350:
  %r.18370 = call i64 @kx_println(ptr @.str.582)
  %ext.18371 = sext i32 0 to i64
  ret i64 %ext.18371
dead.18372:
  ret i64 0
}

define i64 @CmdNew(i64 %name) {
entry:
  %name.addr = alloca i64
  store i64 %name, ptr %name.addr
  %t.18373 = load i64, ptr %name.addr
  %r.18374 = call i64 @CmdInit(i64 %t.18373)
  ret i64 %r.18374
dead.18375:
  ret i64 0
}

define i64 @CmdPublish() {
entry:
  %r.18376 = call i64 @ParseKxConf(ptr @.str.561)
  %conf.702 = alloca i64
  store i64 %r.18376, ptr %conf.702
  %name.703 = alloca ptr
  store ptr @.str.12, ptr %name.703
  %t.18377 = load i64, ptr %conf.702
  %c.18378 = ptrtoint ptr @.str.567 to i64
  %r.18379 = call i1 @kx_map_has(i64 %t.18377, i64 %c.18378)
  br i1 %r.18379, label %if.then.18380, label %if.merge.18381
if.then.18380:
  %t.18382 = load i64, ptr %conf.702
  %c.18384 = ptrtoint ptr @.str.567 to i64
  %r.18383 = call i64 @kx_map_get(i64 %t.18382, i64 %c.18384)
  %inttoptr.18385 = inttoptr i64 %r.18383 to ptr
  store ptr %inttoptr.18385, ptr %name.703
  br label %if.merge.18381
if.merge.18381:
  %version.704 = alloca ptr
  store ptr @.str.12, ptr %version.704
  %t.18386 = load i64, ptr %conf.702
  %c.18387 = ptrtoint ptr @.str.583 to i64
  %r.18388 = call i1 @kx_map_has(i64 %t.18386, i64 %c.18387)
  br i1 %r.18388, label %if.then.18389, label %if.merge.18390
if.then.18389:
  %t.18391 = load i64, ptr %conf.702
  %c.18393 = ptrtoint ptr @.str.583 to i64
  %r.18392 = call i64 @kx_map_get(i64 %t.18391, i64 %c.18393)
  %inttoptr.18394 = inttoptr i64 %r.18392 to ptr
  store ptr %inttoptr.18394, ptr %version.704
  br label %if.merge.18390
if.merge.18390:
  %t.18395 = load ptr, ptr %name.703
  %r.18397 = call i1 @kx_str_eq(ptr %t.18395, ptr @.str.12)
  %t.18398 = load ptr, ptr %version.704
  %r.18400 = call i1 @kx_str_eq(ptr %t.18398, ptr @.str.12)
  %t.18401 = or i1 %r.18397, %r.18400
  br i1 %t.18401, label %if.then.18402, label %if.merge.18403
if.then.18402:
  %r.18404 = call i64 @kx_println(ptr @.str.584)
  %ext.18405 = sext i32 1 to i64
  ret i64 %ext.18405
dead.18406:
  br label %if.merge.18403
if.merge.18403:
  %r.18407 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.585)
  %t.18408 = load ptr, ptr %name.703
  %r.18409 = call ptr @kx_str_cat(ptr %r.18407, ptr %t.18408)
  %r.18410 = call ptr @kx_str_cat(ptr %r.18409, ptr @.str.586)
  %t.18411 = load ptr, ptr %version.704
  %r.18412 = call ptr @kx_str_cat(ptr %r.18410, ptr %t.18411)
  %r.18413 = call ptr @kx_str_cat(ptr %r.18412, ptr @.str.587)
  %r.18414 = call i64 @kx_println(ptr %r.18413)
  %r.18415 = call i64 @kx_println(ptr @.str.588)
  %ext.18416 = sext i32 0 to i64
  ret i64 %ext.18416
dead.18417:
  ret i64 0
}

define i64 @CmdInstall(i64 %pkg) {
entry:
  %pkg.addr = alloca i64
  store i64 %pkg, ptr %pkg.addr
  %r.18418 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.589)
  %t.18419 = load i64, ptr %pkg.addr
  %r.18420 = call ptr @kx_int_str(i64 %t.18419)
  %r.18421 = call ptr @kx_str_cat(ptr %r.18418, ptr %r.18420)
  %r.18422 = call ptr @kx_str_cat(ptr %r.18421, ptr @.str.587)
  %r.18423 = call i64 @kx_println(ptr %r.18422)
  %r.18424 = call i64 @kx_println(ptr @.str.590)
  %ext.18425 = sext i32 0 to i64
  ret i64 %ext.18425
dead.18426:
  ret i64 0
}

define i64 @CmdSearch(i64 %query) {
entry:
  %query.addr = alloca i64
  store i64 %query, ptr %query.addr
  %r.18427 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.591)
  %t.18428 = load i64, ptr %query.addr
  %r.18429 = call ptr @kx_int_str(i64 %t.18428)
  %r.18430 = call ptr @kx_str_cat(ptr %r.18427, ptr %r.18429)
  %r.18431 = call ptr @kx_str_cat(ptr %r.18430, ptr @.str.587)
  %r.18432 = call i64 @kx_println(ptr %r.18431)
  %r.18433 = call i64 @kx_println(ptr @.str.592)
  %ext.18434 = sext i32 0 to i64
  ret i64 %ext.18434
dead.18435:
  ret i64 0
}

define i64 @CmdLogin() {
entry:
  %r.18436 = call i64 @kx_println(ptr @.str.593)
  %ext.18437 = sext i32 0 to i64
  ret i64 %ext.18437
dead.18438:
  ret i64 0
}

define i64 @CmdKeygen() {
entry:
  %r.18439 = call i64 @kx_println(ptr @.str.594)
  %r.18440 = call i64 @kx_system(ptr @.str.595)
  %r.18441 = call i64 @kx_println(ptr @.str.596)
  %ext.18442 = sext i32 0 to i64
  ret i64 %ext.18442
dead.18443:
  ret i64 0
}

define i64 @CmdSbom() {
entry:
  %r.18444 = call i64 @kx_println(ptr @.str.597)
  %r.18445 = call i64 @kx_println(ptr @.str.598)
  %ext.18446 = sext i32 0 to i64
  ret i64 %ext.18446
dead.18447:
  ret i64 0
}

define i64 @CmdAudit() {
entry:
  %r.18448 = call i64 @kx_println(ptr @.str.599)
  %r.18449 = call i64 @kx_system(ptr @.str.600)
  %ext.18450 = sext i32 0 to i64
  ret i64 %ext.18450
dead.18451:
  ret i64 0
}

define i64 @PrintUsage() {
entry:
  %r.18452 = call i64 @kx_println(ptr @.str.601)
  %r.18453 = call i64 @kx_println(ptr @.str.12)
  %r.18454 = call i64 @kx_println(ptr @.str.602)
  %r.18455 = call i64 @kx_println(ptr @.str.603)
  %r.18456 = call i64 @kx_println(ptr @.str.604)
  %r.18457 = call i64 @kx_println(ptr @.str.605)
  %r.18458 = call i64 @kx_println(ptr @.str.606)
  %r.18459 = call i64 @kx_println(ptr @.str.607)
  %r.18460 = call i64 @kx_println(ptr @.str.12)
  %r.18461 = call i64 @kx_println(ptr @.str.608)
  %r.18462 = call i64 @kx_println(ptr @.str.609)
  %r.18463 = call i64 @kx_println(ptr @.str.610)
  %r.18464 = call i64 @kx_println(ptr @.str.611)
  %r.18465 = call i64 @kx_println(ptr @.str.612)
  %r.18466 = call i64 @kx_println(ptr @.str.613)
  %r.18467 = call i64 @kx_println(ptr @.str.614)
  %r.18468 = call i64 @kx_println(ptr @.str.615)
  %r.18469 = call i64 @kx_println(ptr @.str.12)
  %r.18470 = call i64 @kx_println(ptr @.str.616)
  %r.18471 = call i64 @kx_println(ptr @.str.617)
  %r.18472 = call i64 @kx_println(ptr @.str.618)
  %ext.18473 = sext i32 0 to i64
  ret i64 %ext.18473
dead.18474:
  ret i64 0
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @kx_save_args(i32 %argc, ptr %argv)
  %r.18475 = call i64 @kx_list_new(i32 0)
  %args.705 = alloca i64
  store i64 %r.18475, ptr %args.705
  %r.18476 = call i64 @kx_argc()
  %_ac.706 = alloca i64
  store i64 %r.18476, ptr %_ac.706
  %_ai.707 = alloca i32
  store i32 0, ptr %_ai.707
  br label %w.cond.18477
w.cond.18477:
  %t.18480 = load i32, ptr %_ai.707
  %t.18481 = load i64, ptr %_ac.706
  %ext.18482 = sext i32 %t.18480 to i64
  %t.18483 = icmp slt i64 %ext.18482, %t.18481
  br i1 %t.18483, label %w.body.18478, label %w.end.18479
w.body.18478:
  %t.18484 = load i64, ptr %args.705
  %t.18485 = load i32, ptr %_ai.707
  %cast.18486 = sext i32 %t.18485 to i64
  %r.18487 = call i64 @kx_argv(i64 %cast.18486)
  call void @kx_list_add(i64 %t.18484, i64 %r.18487)
  %t.18488 = load i32, ptr %_ai.707
  %t.18489 = add i32 %t.18488, 1
  store i32 %t.18489, ptr %_ai.707
  br label %w.cond.18477
w.end.18479:
  %t.18490 = load i64, ptr %args.705
  %r.18491 = call i64 @kx_list_size(i64 %t.18490)
  %ext.18492 = sext i32 2 to i64
  %t.18493 = icmp slt i64 %r.18491, %ext.18492
  br i1 %t.18493, label %if.then.18494, label %if.merge.18495
if.then.18494:
  %r.18496 = call i64 @PrintUsage()
  ret i32 0
dead.18497:
  br label %if.merge.18495
if.merge.18495:
  %t.18498 = load i64, ptr %args.705
  %ext.18500 = sext i32 1 to i64
  %r.18499 = call i64 @kx_list_get(i64 %t.18498, i64 %ext.18500)
  %ptr.18501 = inttoptr i64 %r.18499 to ptr
  %cmd.708 = alloca ptr
  store ptr %ptr.18501, ptr %cmd.708
  %t.18502 = load ptr, ptr %cmd.708
  %r.18504 = call i1 @kx_str_eq(ptr %t.18502, ptr @.str.619)
  %t.18505 = load ptr, ptr %cmd.708
  %r.18507 = call i1 @kx_str_eq(ptr %t.18505, ptr @.str.620)
  %t.18508 = or i1 %r.18504, %r.18507
  br i1 %t.18508, label %if.then.18509, label %if.merge.18510
if.then.18509:
  %r.18511 = call i64 @PrintUsage()
  ret i32 0
dead.18512:
  br label %if.merge.18510
if.merge.18510:
  %t.18513 = load ptr, ptr %cmd.708
  %r.18515 = call i1 @kx_str_eq(ptr %t.18513, ptr @.str.621)
  br i1 %r.18515, label %if.then.18516, label %if.merge.18517
if.then.18516:
  %r.18518 = call i64 @kx_println(ptr @.str.622)
  ret i32 0
dead.18519:
  br label %if.merge.18517
if.merge.18517:
  %t.18520 = load ptr, ptr %cmd.708
  %r.18522 = call i1 @kx_str_eq(ptr %t.18520, ptr @.str.623)
  %t.18523 = load ptr, ptr %cmd.708
  %r.18525 = call i1 @kx_str_eq(ptr %t.18523, ptr @.str.47)
  %t.18526 = or i1 %r.18522, %r.18525
  br i1 %t.18526, label %if.then.18527, label %if.merge.18528
if.then.18527:
  %t.18529 = load i64, ptr %args.705
  %r.18530 = call i64 @kx_list_size(i64 %t.18529)
  %ext.18531 = sext i32 3 to i64
  %t.18532 = icmp slt i64 %r.18530, %ext.18531
  br i1 %t.18532, label %if.then.18533, label %if.merge.18534
if.then.18533:
  %r.18535 = call i64 @kx_println(ptr @.str.624)
  ret i32 1
dead.18536:
  br label %if.merge.18534
if.merge.18534:
  %t.18537 = load i64, ptr %args.705
  %ext.18539 = sext i32 2 to i64
  %r.18538 = call i64 @kx_list_get(i64 %t.18537, i64 %ext.18539)
  %ptr.18540 = inttoptr i64 %r.18538 to ptr
  %cast.18541 = ptrtoint ptr %ptr.18540 to i64
  %r.18542 = call i64 @CmdInit(i64 %cast.18541)
  %ext.18543 = trunc i64 %r.18542 to i32
  ret i32 %ext.18543
dead.18544:
  br label %if.merge.18528
if.merge.18528:
  %t.18545 = load ptr, ptr %cmd.708
  %r.18547 = call i1 @kx_str_eq(ptr %t.18545, ptr @.str.625)
  br i1 %r.18547, label %if.then.18548, label %if.merge.18549
if.then.18548:
  %t.18550 = load i64, ptr %args.705
  %r.18551 = call i64 @kx_list_size(i64 %t.18550)
  %ext.18552 = sext i32 2 to i64
  %t.18553 = icmp sgt i64 %r.18551, %ext.18552
  br i1 %t.18553, label %tern.then.18554, label %tern.else.18555
tern.then.18554:
  %t.18557 = load i64, ptr %args.705
  %ext.18559 = sext i32 2 to i64
  %r.18558 = call i64 @kx_list_get(i64 %t.18557, i64 %ext.18559)
  %ptr.18560 = inttoptr i64 %r.18558 to ptr
  br label %tern.merge.18556
tern.else.18555:
  br label %tern.merge.18556
tern.merge.18556:
  %phi.18561 = phi ptr [%ptr.18560, %tern.then.18554], [@.str.60, %tern.else.18555]
  %dir.709 = alloca ptr
  store ptr %phi.18561, ptr %dir.709
  %t.18562 = load ptr, ptr %dir.709
  %r.18563 = call i64 @CmdBuild(ptr %t.18562)
  %ext.18564 = trunc i64 %r.18563 to i32
  ret i32 %ext.18564
dead.18565:
  br label %if.merge.18549
if.merge.18549:
  %t.18566 = load ptr, ptr %cmd.708
  %r.18568 = call i1 @kx_str_eq(ptr %t.18566, ptr @.str.626)
  br i1 %r.18568, label %if.then.18569, label %if.merge.18570
if.then.18569:
  %t.18571 = load i64, ptr %args.705
  %r.18572 = call i64 @kx_list_size(i64 %t.18571)
  %ext.18573 = sext i32 2 to i64
  %t.18574 = icmp sgt i64 %r.18572, %ext.18573
  br i1 %t.18574, label %tern.then.18575, label %tern.else.18576
tern.then.18575:
  %t.18578 = load i64, ptr %args.705
  %ext.18580 = sext i32 2 to i64
  %r.18579 = call i64 @kx_list_get(i64 %t.18578, i64 %ext.18580)
  %ptr.18581 = inttoptr i64 %r.18579 to ptr
  br label %tern.merge.18577
tern.else.18576:
  br label %tern.merge.18577
tern.merge.18577:
  %phi.18582 = phi ptr [%ptr.18581, %tern.then.18575], [@.str.60, %tern.else.18576]
  %dir.710 = alloca ptr
  store ptr %phi.18582, ptr %dir.710
  %t.18583 = load ptr, ptr %dir.710
  %r.18584 = call i64 @CmdRun(ptr %t.18583)
  %ext.18585 = trunc i64 %r.18584 to i32
  ret i32 %ext.18585
dead.18586:
  br label %if.merge.18570
if.merge.18570:
  %t.18587 = load ptr, ptr %cmd.708
  %r.18589 = call i1 @kx_str_eq(ptr %t.18587, ptr @.str.627)
  br i1 %r.18589, label %if.then.18590, label %if.merge.18591
if.then.18590:
  %t.18592 = load i64, ptr %args.705
  %r.18593 = call i64 @kx_list_size(i64 %t.18592)
  %ext.18594 = sext i32 2 to i64
  %t.18595 = icmp sgt i64 %r.18593, %ext.18594
  br i1 %t.18595, label %tern.then.18596, label %tern.else.18597
tern.then.18596:
  %t.18599 = load i64, ptr %args.705
  %ext.18601 = sext i32 2 to i64
  %r.18600 = call i64 @kx_list_get(i64 %t.18599, i64 %ext.18601)
  %ptr.18602 = inttoptr i64 %r.18600 to ptr
  br label %tern.merge.18598
tern.else.18597:
  br label %tern.merge.18598
tern.merge.18598:
  %phi.18603 = phi ptr [%ptr.18602, %tern.then.18596], [@.str.60, %tern.else.18597]
  %dir.711 = alloca ptr
  store ptr %phi.18603, ptr %dir.711
  %t.18604 = load ptr, ptr %dir.711
  %r.18605 = call i64 @CmdCheck(ptr %t.18604)
  %ext.18606 = trunc i64 %r.18605 to i32
  ret i32 %ext.18606
dead.18607:
  br label %if.merge.18591
if.merge.18591:
  %t.18608 = load ptr, ptr %cmd.708
  %r.18610 = call i1 @kx_str_eq(ptr %t.18608, ptr @.str.628)
  br i1 %r.18610, label %if.then.18611, label %if.merge.18612
if.then.18611:
  %r.18613 = call i64 @CmdPublish()
  %ext.18614 = trunc i64 %r.18613 to i32
  ret i32 %ext.18614
dead.18615:
  br label %if.merge.18612
if.merge.18612:
  %t.18616 = load ptr, ptr %cmd.708
  %r.18618 = call i1 @kx_str_eq(ptr %t.18616, ptr @.str.629)
  br i1 %r.18618, label %if.then.18619, label %if.merge.18620
if.then.18619:
  %t.18621 = load i64, ptr %args.705
  %r.18622 = call i64 @kx_list_size(i64 %t.18621)
  %ext.18623 = sext i32 3 to i64
  %t.18624 = icmp slt i64 %r.18622, %ext.18623
  br i1 %t.18624, label %if.then.18625, label %if.merge.18626
if.then.18625:
  %r.18627 = call i64 @kx_println(ptr @.str.630)
  ret i32 1
dead.18628:
  br label %if.merge.18626
if.merge.18626:
  %t.18629 = load i64, ptr %args.705
  %ext.18631 = sext i32 2 to i64
  %r.18630 = call i64 @kx_list_get(i64 %t.18629, i64 %ext.18631)
  %ptr.18632 = inttoptr i64 %r.18630 to ptr
  %cast.18633 = ptrtoint ptr %ptr.18632 to i64
  %r.18634 = call i64 @CmdInstall(i64 %cast.18633)
  %ext.18635 = trunc i64 %r.18634 to i32
  ret i32 %ext.18635
dead.18636:
  br label %if.merge.18620
if.merge.18620:
  %t.18637 = load ptr, ptr %cmd.708
  %r.18639 = call i1 @kx_str_eq(ptr %t.18637, ptr @.str.631)
  br i1 %r.18639, label %if.then.18640, label %if.merge.18641
if.then.18640:
  %t.18642 = load i64, ptr %args.705
  %r.18643 = call i64 @kx_list_size(i64 %t.18642)
  %ext.18644 = sext i32 3 to i64
  %t.18645 = icmp slt i64 %r.18643, %ext.18644
  br i1 %t.18645, label %if.then.18646, label %if.merge.18647
if.then.18646:
  %r.18648 = call i64 @kx_println(ptr @.str.632)
  ret i32 1
dead.18649:
  br label %if.merge.18647
if.merge.18647:
  %t.18650 = load i64, ptr %args.705
  %ext.18652 = sext i32 2 to i64
  %r.18651 = call i64 @kx_list_get(i64 %t.18650, i64 %ext.18652)
  %ptr.18653 = inttoptr i64 %r.18651 to ptr
  %cast.18654 = ptrtoint ptr %ptr.18653 to i64
  %r.18655 = call i64 @CmdSearch(i64 %cast.18654)
  %ext.18656 = trunc i64 %r.18655 to i32
  ret i32 %ext.18656
dead.18657:
  br label %if.merge.18641
if.merge.18641:
  %t.18658 = load ptr, ptr %cmd.708
  %r.18660 = call i1 @kx_str_eq(ptr %t.18658, ptr @.str.633)
  br i1 %r.18660, label %if.then.18661, label %if.merge.18662
if.then.18661:
  %r.18663 = call i64 @CmdLogin()
  %ext.18664 = trunc i64 %r.18663 to i32
  ret i32 %ext.18664
dead.18665:
  br label %if.merge.18662
if.merge.18662:
  %t.18666 = load ptr, ptr %cmd.708
  %r.18668 = call i1 @kx_str_eq(ptr %t.18666, ptr @.str.634)
  br i1 %r.18668, label %if.then.18669, label %if.merge.18670
if.then.18669:
  %r.18671 = call i64 @CmdKeygen()
  %ext.18672 = trunc i64 %r.18671 to i32
  ret i32 %ext.18672
dead.18673:
  br label %if.merge.18670
if.merge.18670:
  %t.18674 = load ptr, ptr %cmd.708
  %r.18676 = call i1 @kx_str_eq(ptr %t.18674, ptr @.str.635)
  br i1 %r.18676, label %if.then.18677, label %if.merge.18678
if.then.18677:
  %r.18679 = call i64 @CmdSbom()
  %ext.18680 = trunc i64 %r.18679 to i32
  ret i32 %ext.18680
dead.18681:
  br label %if.merge.18678
if.merge.18678:
  %t.18682 = load ptr, ptr %cmd.708
  %r.18684 = call i1 @kx_str_eq(ptr %t.18682, ptr @.str.636)
  br i1 %r.18684, label %if.then.18685, label %if.merge.18686
if.then.18685:
  %r.18687 = call i64 @CmdAudit()
  %ext.18688 = trunc i64 %r.18687 to i32
  ret i32 %ext.18688
dead.18689:
  br label %if.merge.18686
if.merge.18686:
  %r.18690 = call ptr @kx_str_cat(ptr @.str.12, ptr @.str.637)
  %t.18691 = load ptr, ptr %cmd.708
  %r.18692 = call ptr @kx_str_cat(ptr %r.18690, ptr %t.18691)
  %r.18693 = call ptr @kx_str_cat(ptr %r.18692, ptr @.str.12)
  %r.18694 = call i64 @kx_println(ptr %r.18693)
  %r.18695 = call i64 @kx_println(ptr @.str.638)
  ret i32 1
dead.18696:
  ret i32 0
}

@.str.1 = private unnamed_addr constant [2 x i8] c"0\00"
@.str.2 = private unnamed_addr constant [2 x i8] c"9\00"
@.str.3 = private unnamed_addr constant [2 x i8] c"a\00"
@.str.4 = private unnamed_addr constant [2 x i8] c"z\00"
@.str.5 = private unnamed_addr constant [2 x i8] c"A\00"
@.str.6 = private unnamed_addr constant [2 x i8] c"Z\00"
@.str.7 = private unnamed_addr constant [2 x i8] c"_\00"
@.str.8 = private unnamed_addr constant [2 x i8] c" \00"
@.str.9 = private unnamed_addr constant [2 x i8] c"\09\00"
@.str.10 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.11 = private unnamed_addr constant [2 x i8] c"\00"
@.str.12 = private unnamed_addr constant [1 x i8] c"\00"
@.str.13 = private unnamed_addr constant [2 x i8] c"/\00"
@.str.14 = private unnamed_addr constant [2 x i8] c"*\00"
@.str.15 = private unnamed_addr constant [3 x i8] c"id\00"
@.str.16 = private unnamed_addr constant [10 x i8] c"component\00"
@.str.17 = private unnamed_addr constant [7 x i8] c"system\00"
@.str.18 = private unnamed_addr constant [4 x i8] c"tag\00"
@.str.19 = private unnamed_addr constant [7 x i8] c"struct\00"
@.str.20 = private unnamed_addr constant [5 x i8] c"enum\00"
@.str.21 = private unnamed_addr constant [6 x i8] c"const\00"
@.str.22 = private unnamed_addr constant [4 x i8] c"var\00"
@.str.23 = private unnamed_addr constant [5 x i8] c"void\00"
@.str.24 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.25 = private unnamed_addr constant [5 x i8] c"long\00"
@.str.26 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.27 = private unnamed_addr constant [7 x i8] c"double\00"
@.str.28 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str.29 = private unnamed_addr constant [5 x i8] c"byte\00"
@.str.30 = private unnamed_addr constant [7 x i8] c"string\00"
@.str.31 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.32 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.33 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.34 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.35 = private unnamed_addr constant [8 x i8] c"foreach\00"
@.str.36 = private unnamed_addr constant [3 x i8] c"in\00"
@.str.37 = private unnamed_addr constant [6 x i8] c"break\00"
@.str.38 = private unnamed_addr constant [9 x i8] c"continue\00"
@.str.39 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.40 = private unnamed_addr constant [6 x i8] c"spawn\00"
@.str.41 = private unnamed_addr constant [8 x i8] c"despawn\00"
@.str.42 = private unnamed_addr constant [7 x i8] c"attach\00"
@.str.43 = private unnamed_addr constant [7 x i8] c"detach\00"
@.str.44 = private unnamed_addr constant [5 x i8] c"self\00"
@.str.45 = private unnamed_addr constant [5 x i8] c"with\00"
@.str.46 = private unnamed_addr constant [8 x i8] c"without\00"
@.str.47 = private unnamed_addr constant [4 x i8] c"new\00"
@.str.48 = private unnamed_addr constant [5 x i8] c"tags\00"
@.str.49 = private unnamed_addr constant [6 x i8] c"using\00"
@.str.50 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.51 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.52 = private unnamed_addr constant [3 x i8] c"is\00"
@.str.53 = private unnamed_addr constant [6 x i8] c"exact\00"
@.str.54 = private unnamed_addr constant [6 x i8] c"panic\00"
@.str.55 = private unnamed_addr constant [7 x i8] c"switch\00"
@.str.56 = private unnamed_addr constant [5 x i8] c"case\00"
@.str.57 = private unnamed_addr constant [8 x i8] c"default\00"
@.str.58 = private unnamed_addr constant [7 x i8] c"extern\00"
@.str.59 = private unnamed_addr constant [3 x i8] c"kw\00"
@.str.60 = private unnamed_addr constant [2 x i8] c".\00"
@.str.61 = private unnamed_addr constant [2 x i8] c"$\00"
@.str.62 = private unnamed_addr constant [2 x i8] c"\22\00"
@.str.63 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.64 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.65 = private unnamed_addr constant [2 x i8] c"\5C\00"
@.str.66 = private unnamed_addr constant [5 x i8] c"dstr\00"
@.str.67 = private unnamed_addr constant [2 x i8] c"n\00"
@.str.68 = private unnamed_addr constant [2 x i8] c"t\00"
@.str.69 = private unnamed_addr constant [2 x i8] c"r\00"
@.str.70 = private unnamed_addr constant [2 x i8] c"'\00"
@.str.71 = private unnamed_addr constant [3 x i8] c"==\00"
@.str.72 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str.73 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str.74 = private unnamed_addr constant [3 x i8] c">=\00"
@.str.75 = private unnamed_addr constant [3 x i8] c"&&\00"
@.str.76 = private unnamed_addr constant [3 x i8] c"||\00"
@.str.77 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str.78 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str.79 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str.80 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str.81 = private unnamed_addr constant [3 x i8] c"%=\00"
@.str.82 = private unnamed_addr constant [3 x i8] c"++\00"
@.str.83 = private unnamed_addr constant [3 x i8] c"--\00"
@.str.84 = private unnamed_addr constant [3 x i8] c"op\00"
@.str.85 = private unnamed_addr constant [6 x i8] c"punct\00"
@.str.86 = private unnamed_addr constant [4 x i8] c"eof\00"
@.str.87 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.88 = private unnamed_addr constant [3 x i8] c"-0\00"
@.str.89 = private unnamed_addr constant [2 x i8] c":\00"
@.str.90 = private unnamed_addr constant [12 x i8] c": expected \00"
@.str.91 = private unnamed_addr constant [4 x i8] c"loc\00"
@.str.92 = private unnamed_addr constant [11 x i8] c"identifier\00"
@.str.93 = private unnamed_addr constant [11 x i8] c"structinit\00"
@.str.94 = private unnamed_addr constant [2 x i8] c"=\00"
@.str.95 = private unnamed_addr constant [29 x i8] c"'=' in component initializer\00"
@.str.96 = private unnamed_addr constant [6 x i8] c"field\00"
@.str.97 = private unnamed_addr constant [2 x i8] c",\00"
@.str.98 = private unnamed_addr constant [35 x i8] c"'}' to close component initializer\00"
@.str.99 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.100 = private unnamed_addr constant [2 x i8] c")\00"
@.str.101 = private unnamed_addr constant [4 x i8] c"')'\00"
@.str.102 = private unnamed_addr constant [25 x i8] c": expected an expression\00"
@.str.103 = private unnamed_addr constant [5 x i8] c"call\00"
@.str.104 = private unnamed_addr constant [8 x i8] c"typearg\00"
@.str.105 = private unnamed_addr constant [4 x i8] c"'('\00"
@.str.106 = private unnamed_addr constant [4 x i8] c"arg\00"
@.str.107 = private unnamed_addr constant [8 x i8] c"argname\00"
@.str.108 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.109 = private unnamed_addr constant [2 x i8] c">\00"
@.str.110 = private unnamed_addr constant [33 x i8] c": expected member name after '.'\00"
@.str.111 = private unnamed_addr constant [7 x i8] c"member\00"
@.str.112 = private unnamed_addr constant [7 x i8] c"istype\00"
@.str.113 = private unnamed_addr constant [6 x i8] c"isvar\00"
@.str.114 = private unnamed_addr constant [6 x i8] c"unary\00"
@.str.115 = private unnamed_addr constant [8 x i8] c"postinc\00"
@.str.116 = private unnamed_addr constant [8 x i8] c"postdec\00"
@.str.117 = private unnamed_addr constant [7 x i8] c"binary\00"
@.str.118 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.119 = private unnamed_addr constant [4 x i8] c"not\00"
@.str.120 = private unnamed_addr constant [4 x i8] c"neg\00"
@.str.121 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str.122 = private unnamed_addr constant [4 x i8] c"div\00"
@.str.123 = private unnamed_addr constant [2 x i8] c"%\00"
@.str.124 = private unnamed_addr constant [4 x i8] c"mod\00"
@.str.125 = private unnamed_addr constant [2 x i8] c"+\00"
@.str.126 = private unnamed_addr constant [4 x i8] c"add\00"
@.str.127 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str.128 = private unnamed_addr constant [3 x i8] c"lt\00"
@.str.129 = private unnamed_addr constant [3 x i8] c"gt\00"
@.str.130 = private unnamed_addr constant [3 x i8] c"le\00"
@.str.131 = private unnamed_addr constant [3 x i8] c"ge\00"
@.str.132 = private unnamed_addr constant [3 x i8] c"eq\00"
@.str.133 = private unnamed_addr constant [3 x i8] c"ne\00"
@.str.134 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.135 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.136 = private unnamed_addr constant [2 x i8] c"?\00"
@.str.137 = private unnamed_addr constant [8 x i8] c"ternary\00"
@.str.138 = private unnamed_addr constant [15 x i8] c"':' in ternary\00"
@.str.139 = private unnamed_addr constant [7 x i8] c"assign\00"
@.str.140 = private unnamed_addr constant [10 x i8] c"addassign\00"
@.str.141 = private unnamed_addr constant [10 x i8] c"subassign\00"
@.str.142 = private unnamed_addr constant [10 x i8] c"mulassign\00"
@.str.143 = private unnamed_addr constant [10 x i8] c"divassign\00"
@.str.144 = private unnamed_addr constant [10 x i8] c"modassign\00"
@.str.145 = private unnamed_addr constant [16 x i8] c"'{' after spawn\00"
@.str.146 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.147 = private unnamed_addr constant [15 x i8] c"'[' after tags\00"
@.str.148 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.149 = private unnamed_addr constant [9 x i8] c"spawntag\00"
@.str.150 = private unnamed_addr constant [18 x i8] c"']' to close tags\00"
@.str.151 = private unnamed_addr constant [19 x i8] c"'}' to close spawn\00"
@.str.152 = private unnamed_addr constant [9 x i8] c"compinit\00"
@.str.153 = private unnamed_addr constant [9 x i8] c"compname\00"
@.str.154 = private unnamed_addr constant [25 x i8] c"'{' after component type\00"
@.str.155 = private unnamed_addr constant [13 x i8] c"interpolated\00"
@.str.156 = private unnamed_addr constant [4 x i8] c"lit\00"
@.str.157 = private unnamed_addr constant [11 x i8] c"interpexpr\00"
@.str.158 = private unnamed_addr constant [6 x i8] c"block\00"
@.str.159 = private unnamed_addr constant [19 x i8] c"'{' to start block\00"
@.str.160 = private unnamed_addr constant [19 x i8] c"'}' to close block\00"
@.str.161 = private unnamed_addr constant [8 x i8] c"vardecl\00"
@.str.162 = private unnamed_addr constant [8 x i8] c"varname\00"
@.str.163 = private unnamed_addr constant [28 x i8] c"'=' in variable declaration\00"
@.str.164 = private unnamed_addr constant [2 x i8] c";\00"
@.str.165 = private unnamed_addr constant [31 x i8] c"';' after variable declaration\00"
@.str.166 = private unnamed_addr constant [13 x i8] c"'(' after if\00"
@.str.167 = private unnamed_addr constant [23 x i8] c"')' after if condition\00"
@.str.168 = private unnamed_addr constant [16 x i8] c"'(' after while\00"
@.str.169 = private unnamed_addr constant [26 x i8] c"')' after while condition\00"
@.str.170 = private unnamed_addr constant [14 x i8] c"'(' after for\00"
@.str.171 = private unnamed_addr constant [19 x i8] c"';' after for init\00"
@.str.172 = private unnamed_addr constant [24 x i8] c"';' after for condition\00"
@.str.173 = private unnamed_addr constant [22 x i8] c"')' after for clauses\00"
@.str.174 = private unnamed_addr constant [18 x i8] c"'(' after foreach\00"
@.str.175 = private unnamed_addr constant [27 x i8] c": expected 'in' in foreach\00"
@.str.176 = private unnamed_addr constant [28 x i8] c"')' after foreach container\00"
@.str.177 = private unnamed_addr constant [17 x i8] c"';' after return\00"
@.str.178 = private unnamed_addr constant [16 x i8] c"';' after break\00"
@.str.179 = private unnamed_addr constant [19 x i8] c"';' after continue\00"
@.str.180 = private unnamed_addr constant [17 x i8] c"'(' after switch\00"
@.str.181 = private unnamed_addr constant [27 x i8] c"')' after switch condition\00"
@.str.182 = private unnamed_addr constant [20 x i8] c"'{' to start switch\00"
@.str.183 = private unnamed_addr constant [21 x i8] c"':' after case value\00"
@.str.184 = private unnamed_addr constant [18 x i8] c"':' after default\00"
@.str.185 = private unnamed_addr constant [31 x i8] c": expected 'case' or 'default'\00"
@.str.186 = private unnamed_addr constant [20 x i8] c"'}' to close switch\00"
@.str.187 = private unnamed_addr constant [17 x i8] c"'(' after attach\00"
@.str.188 = private unnamed_addr constant [33 x i8] c"',' between target and component\00"
@.str.189 = private unnamed_addr constant [17 x i8] c"')' after attach\00"
@.str.190 = private unnamed_addr constant [17 x i8] c"';' after attach\00"
@.str.191 = private unnamed_addr constant [17 x i8] c"'(' after detach\00"
@.str.192 = private unnamed_addr constant [38 x i8] c"',' between target and component type\00"
@.str.193 = private unnamed_addr constant [20 x i8] c"component type name\00"
@.str.194 = private unnamed_addr constant [9 x i8] c"typename\00"
@.str.195 = private unnamed_addr constant [17 x i8] c"')' after detach\00"
@.str.196 = private unnamed_addr constant [17 x i8] c"';' after detach\00"
@.str.197 = private unnamed_addr constant [18 x i8] c"';' after despawn\00"
@.str.198 = private unnamed_addr constant [5 x i8] c"expr\00"
@.str.199 = private unnamed_addr constant [21 x i8] c"';' after expression\00"
@.str.200 = private unnamed_addr constant [9 x i8] c"declname\00"
@.str.201 = private unnamed_addr constant [25 x i8] c"'{' after component name\00"
@.str.202 = private unnamed_addr constant [22 x i8] c"'{' after struct name\00"
@.str.203 = private unnamed_addr constant [22 x i8] c": expected field name\00"
@.str.204 = private unnamed_addr constant [21 x i8] c"'=' in field default\00"
@.str.205 = private unnamed_addr constant [16 x i8] c"';' after field\00"
@.str.206 = private unnamed_addr constant [23 x i8] c"'}' to close component\00"
@.str.207 = private unnamed_addr constant [20 x i8] c"'}' to close struct\00"
@.str.208 = private unnamed_addr constant [9 x i8] c"function\00"
@.str.209 = private unnamed_addr constant [4 x i8] c"ret\00"
@.str.210 = private unnamed_addr constant [24 x i8] c"'(' after function name\00"
@.str.211 = private unnamed_addr constant [6 x i8] c"param\00"
@.str.212 = private unnamed_addr constant [21 x i8] c"')' after parameters\00"
@.str.213 = private unnamed_addr constant [16 x i8] c"parent tag name\00"
@.str.214 = private unnamed_addr constant [7 x i8] c"parent\00"
@.str.215 = private unnamed_addr constant [14 x i8] c"';' after tag\00"
@.str.216 = private unnamed_addr constant [20 x i8] c"'{' after enum name\00"
@.str.217 = private unnamed_addr constant [18 x i8] c"'}' to close enum\00"
@.str.218 = private unnamed_addr constant [13 x i8] c"'=' in const\00"
@.str.219 = private unnamed_addr constant [16 x i8] c"';' after const\00"
@.str.220 = private unnamed_addr constant [15 x i8] c"'(' after with\00"
@.str.221 = private unnamed_addr constant [20 x i8] c"')' after with list\00"
@.str.222 = private unnamed_addr constant [18 x i8] c"'(' after without\00"
@.str.223 = private unnamed_addr constant [23 x i8] c"')' after without list\00"
@.str.224 = private unnamed_addr constant [5 x i8] c"attr\00"
@.str.225 = private unnamed_addr constant [9 x i8] c"attrname\00"
@.str.226 = private unnamed_addr constant [25 x i8] c"')' after attribute args\00"
@.str.227 = private unnamed_addr constant [23 x i8] c"']' to close attribute\00"
@.str.228 = private unnamed_addr constant [8 x i8] c"program\00"
@.str.229 = private unnamed_addr constant [5 x i8] c"useg\00"
@.str.230 = private unnamed_addr constant [26 x i8] c"';' after using directive\00"
@.str.231 = private unnamed_addr constant [10 x i8] c"paramtype\00"
@.str.232 = private unnamed_addr constant [29 x i8] c"';' after extern declaration\00"
@.str.233 = private unnamed_addr constant [51 x i8] c": attributes before a declaration require 'extern'\00"
@.str.234 = private unnamed_addr constant [35 x i8] c": expected a top-level declaration\00"
@.str.235 = private unnamed_addr constant [9 x i8] c"(program\00"
@.str.236 = private unnamed_addr constant [7 x i8] c" file:\00"
@.str.237 = private unnamed_addr constant [10 x i8] c"(string \22\00"
@.str.238 = private unnamed_addr constant [3 x i8] c"\22)\00"
@.str.239 = private unnamed_addr constant [7 x i8] c"(bool \00"
@.str.240 = private unnamed_addr constant [13 x i8] c"(identifier \00"
@.str.241 = private unnamed_addr constant [8 x i8] c"(float \00"
@.str.242 = private unnamed_addr constant [6 x i8] c"(int \00"
@.str.243 = private unnamed_addr constant [9 x i8] c"(member \00"
@.str.244 = private unnamed_addr constant [6 x i8] c"(call\00"
@.str.245 = private unnamed_addr constant [3 x i8] c" <\00"
@.str.246 = private unnamed_addr constant [14 x i8] c"(interpolated\00"
@.str.247 = private unnamed_addr constant [3 x i8] c" \22\00"
@.str.248 = private unnamed_addr constant [3 x i8] c" {\00"
@.str.249 = private unnamed_addr constant [7 x i8] c"(spawn\00"
@.str.250 = private unnamed_addr constant [6 x i8] c" tag:\00"
@.str.251 = private unnamed_addr constant [14 x i8] c"(structinit (\00"
@.str.252 = private unnamed_addr constant [3 x i8] c"))\00"
@.str.253 = private unnamed_addr constant [7 x i8] c" case \00"
@.str.254 = private unnamed_addr constant [3 x i8] c" (\00"
@.str.255 = private unnamed_addr constant [6 x i8] c"(tag \00"
@.str.256 = private unnamed_addr constant [4 x i8] c" : \00"
@.str.257 = private unnamed_addr constant [7 x i8] c"(enum \00"
@.str.258 = private unnamed_addr constant [8 x i8] c"(const \00"
@.str.259 = private unnamed_addr constant [9 x i8] c"(system \00"
@.str.260 = private unnamed_addr constant [7 x i8] c" with:\00"
@.str.261 = private unnamed_addr constant [10 x i8] c" without:\00"
@.str.262 = private unnamed_addr constant [3 x i8] c" [\00"
@.str.263 = private unnamed_addr constant [11 x i8] c"(function \00"
@.str.264 = private unnamed_addr constant [12 x i8] c"BUG: Child(\00"
@.str.265 = private unnamed_addr constant [9 x i8] c") count=\00"
@.str.266 = private unnamed_addr constant [10 x i8] c" at line \00"
@.str.267 = private unnamed_addr constant [6 x i8] c"error\00"
@.str.268 = private unnamed_addr constant [11 x i8] c"0123456789\00"
@.str.269 = private unnamed_addr constant [4 x i8] c"i64\00"
@.str.270 = private unnamed_addr constant [6 x i8] c"%ext.\00"
@.str.271 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.272 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.273 = private unnamed_addr constant [17 x i8] c" = ptrtoint ptr \00"
@.str.274 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str.275 = private unnamed_addr constant [13 x i8] c" = sext i32 \00"
@.str.276 = private unnamed_addr constant [7 x i8] c"%cast.\00"
@.str.277 = private unnamed_addr constant [17 x i8] c" = inttoptr i64 \00"
@.str.278 = private unnamed_addr constant [8 x i8] c" to ptr\00"
@.str.279 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str.280 = private unnamed_addr constant [3 x i8] c"i1\00"
@.str.281 = private unnamed_addr constant [16 x i8] c" = icmp ne i64 \00"
@.str.282 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str.283 = private unnamed_addr constant [12 x i8] c" = zext i1 \00"
@.str.284 = private unnamed_addr constant [2 x i8] c"|\00"
@.str.285 = private unnamed_addr constant [8 x i8] c"unknown\00"
@.str.286 = private unnamed_addr constant [8 x i8] c"struct:\00"
@.str.287 = private unnamed_addr constant [5 x i8] c"kind\00"
@.str.288 = private unnamed_addr constant [5 x i8] c"text\00"
@.str.289 = private unnamed_addr constant [13 x i8] c"struct:Token\00"
@.str.290 = private unnamed_addr constant [6 x i8] c"value\00"
@.str.291 = private unnamed_addr constant [9 x i8] c"children\00"
@.str.292 = private unnamed_addr constant [15 x i8] c"struct:AstNode\00"
@.str.293 = private unnamed_addr constant [7 x i8] c"Length\00"
@.str.294 = private unnamed_addr constant [10 x i8] c"Substring\00"
@.str.295 = private unnamed_addr constant [9 x i8] c"Contains\00"
@.str.296 = private unnamed_addr constant [11 x i8] c"StartsWith\00"
@.str.297 = private unnamed_addr constant [9 x i8] c"EndsWith\00"
@.str.298 = private unnamed_addr constant [6 x i8] c"Upper\00"
@.str.299 = private unnamed_addr constant [6 x i8] c"Lower\00"
@.str.300 = private unnamed_addr constant [6 x i8] c"Count\00"
@.str.301 = private unnamed_addr constant [4 x i8] c"std\00"
@.str.302 = private unnamed_addr constant [9 x i8] c"readFile\00"
@.str.303 = private unnamed_addr constant [7 x i8] c"readln\00"
@.str.304 = private unnamed_addr constant [5 x i8] c"args\00"
@.str.305 = private unnamed_addr constant [4 x i8] c"rng\00"
@.str.306 = private unnamed_addr constant [8 x i8] c"println\00"
@.str.307 = private unnamed_addr constant [6 x i8] c"print\00"
@.str.308 = private unnamed_addr constant [5 x i8] c"exit\00"
@.str.309 = private unnamed_addr constant [5 x i8] c"stop\00"
@.str.310 = private unnamed_addr constant [4 x i8] c"Get\00"
@.str.311 = private unnamed_addr constant [4 x i8] c"Set\00"
@.str.312 = private unnamed_addr constant [4 x i8] c"Add\00"
@.str.313 = private unnamed_addr constant [4 x i8] c"Has\00"
@.str.314 = private unnamed_addr constant [5 x i8] c"List\00"
@.str.315 = private unnamed_addr constant [4 x i8] c"Map\00"
@.str.316 = private unnamed_addr constant [7 x i8] c"IntStr\00"
@.str.317 = private unnamed_addr constant [7 x i8] c"CharAt\00"
@.str.318 = private unnamed_addr constant [6 x i8] c"dead.\00"
@.str.319 = private unnamed_addr constant [6 x i8] c"  br \00"
@.str.320 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str.321 = private unnamed_addr constant [14 x i8] c"  unreachable\00"
@.str.322 = private unnamed_addr constant [4 x i8] c"\5C0A\00"
@.str.323 = private unnamed_addr constant [4 x i8] c"\5C09\00"
@.str.324 = private unnamed_addr constant [5 x i8] c"\5C\5C5C\00"
@.str.325 = private unnamed_addr constant [4 x i8] c"\5C00\00"
@.str.326 = private unnamed_addr constant [4 x i8] c"\5C22\00"
@.str.327 = private unnamed_addr constant [3 x i8] c"\5C0\00"
@.str.328 = private unnamed_addr constant [7 x i8] c"@.str.\00"
@.str.329 = private unnamed_addr constant [4 x i8] c"\5C5C\00"
@.str.330 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str.331 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str.332 = private unnamed_addr constant [5 x i8] c"\5C00\22\00"
@.str.333 = private unnamed_addr constant [23 x i8] c"declare i32 @kx_argc()\00"
@.str.334 = private unnamed_addr constant [26 x i8] c"declare ptr @kx_argv(i32)\00"
@.str.335 = private unnamed_addr constant [29 x i8] c"declare i64 @kx_println(ptr)\00"
@.str.336 = private unnamed_addr constant [27 x i8] c"declare i64 @kx_print(ptr)\00"
@.str.337 = private unnamed_addr constant [31 x i8] c"declare ptr @kx_read_file(ptr)\00"
@.str.338 = private unnamed_addr constant [36 x i8] c"declare i1 @kx_write_file(ptr, ptr)\00"
@.str.339 = private unnamed_addr constant [29 x i8] c"declare ptr @kx_int_str(i64)\00"
@.str.340 = private unnamed_addr constant [28 x i8] c"declare i64 @kx_system(ptr)\00"
@.str.341 = private unnamed_addr constant [27 x i8] c"declare void @kx_exit(i32)\00"
@.str.342 = private unnamed_addr constant [28 x i8] c"declare void @kx_panic(ptr)\00"
@.str.343 = private unnamed_addr constant [37 x i8] c"declare void @kx_save_args(i32, ptr)\00"
@.str.344 = private unnamed_addr constant [26 x i8] c"declare i64 @kx_args(i64)\00"
@.str.345 = private unnamed_addr constant [30 x i8] c"declare ptr @kx_str_trim(ptr)\00"
@.str.346 = private unnamed_addr constant [39 x i8] c"declare i64 @kx_str_index_of(ptr, ptr)\00"
@.str.347 = private unnamed_addr constant [30 x i8] c"declare i64 @kx_list_new(i32)\00"
@.str.348 = private unnamed_addr constant [36 x i8] c"declare void @kx_list_add(i64, i64)\00"
@.str.349 = private unnamed_addr constant [35 x i8] c"declare i64 @kx_list_get(i64, i64)\00"
@.str.350 = private unnamed_addr constant [41 x i8] c"declare void @kx_list_set(i64, i64, i64)\00"
@.str.351 = private unnamed_addr constant [31 x i8] c"declare i64 @kx_list_size(i64)\00"
@.str.352 = private unnamed_addr constant [42 x i8] c"declare void @kx_list_remove_at(i64, i64)\00"
@.str.353 = private unnamed_addr constant [33 x i8] c"declare void @kx_list_clear(i64)\00"
@.str.354 = private unnamed_addr constant [34 x i8] c"declare i64 @kx_map_new(i32, i32)\00"
@.str.355 = private unnamed_addr constant [40 x i8] c"declare void @kx_map_set(i64, i64, i64)\00"
@.str.356 = private unnamed_addr constant [34 x i8] c"declare i64 @kx_map_get(i64, i64)\00"
@.str.357 = private unnamed_addr constant [33 x i8] c"declare i1 @kx_map_has(i64, i64)\00"
@.str.358 = private unnamed_addr constant [29 x i8] c"declare i64 @kx_str_len(ptr)\00"
@.str.359 = private unnamed_addr constant [34 x i8] c"declare ptr @kx_str_cat(ptr, ptr)\00"
@.str.360 = private unnamed_addr constant [32 x i8] c"declare i1 @kx_str_eq(ptr, ptr)\00"
@.str.361 = private unnamed_addr constant [32 x i8] c"declare i1 @kx_str_lt(ptr, ptr)\00"
@.str.362 = private unnamed_addr constant [32 x i8] c"declare i1 @kx_str_le(ptr, ptr)\00"
@.str.363 = private unnamed_addr constant [32 x i8] c"declare i1 @kx_str_gt(ptr, ptr)\00"
@.str.364 = private unnamed_addr constant [32 x i8] c"declare i1 @kx_str_ge(ptr, ptr)\00"
@.str.365 = private unnamed_addr constant [42 x i8] c"declare ptr @kx_str_substr(ptr, i64, i64)\00"
@.str.366 = private unnamed_addr constant [38 x i8] c"declare i1 @kx_str_contains(ptr, ptr)\00"
@.str.367 = private unnamed_addr constant [41 x i8] c"declare i1 @kx_str_starts_with(ptr, ptr)\00"
@.str.368 = private unnamed_addr constant [39 x i8] c"declare i1 @kx_str_ends_with(ptr, ptr)\00"
@.str.369 = private unnamed_addr constant [31 x i8] c"declare ptr @kx_str_upper(ptr)\00"
@.str.370 = private unnamed_addr constant [31 x i8] c"declare ptr @kx_str_lower(ptr)\00"
@.str.371 = private unnamed_addr constant [40 x i8] c"declare double @kx_rng_next_double(i64)\00"
@.str.372 = private unnamed_addr constant [32 x i8] c"declare i64 @kx_struct_new(i32)\00"
@.str.373 = private unnamed_addr constant [37 x i8] c"declare i64 @kx_struct_get(i64, i32)\00"
@.str.374 = private unnamed_addr constant [43 x i8] c"declare void @kx_struct_set(i64, i32, i64)\00"
@.str.375 = private unnamed_addr constant [27 x i8] c"declare i64 @kx_spawn(i64)\00"
@.str.376 = private unnamed_addr constant [30 x i8] c"declare void @kx_despawn(i64)\00"
@.str.377 = private unnamed_addr constant [34 x i8] c"declare void @kx_attach(i64, i32)\00"
@.str.378 = private unnamed_addr constant [34 x i8] c"declare void @kx_detach(i64, i32)\00"
@.str.379 = private unnamed_addr constant [51 x i8] c"declare void @kx_set_field_i64(i64, i32, i32, i64)\00"
@.str.380 = private unnamed_addr constant [45 x i8] c"declare i64 @kx_get_field_i64(i64, i32, i32)\00"
@.str.381 = private unnamed_addr constant [51 x i8] c"declare void @kx_set_field_str(i64, i32, i32, ptr)\00"
@.str.382 = private unnamed_addr constant [45 x i8] c"declare ptr @kx_get_field_str(i64, i32, i32)\00"
@.str.383 = private unnamed_addr constant [54 x i8] c"declare void @kx_set_field_f64(i64, i32, i32, double)\00"
@.str.384 = private unnamed_addr constant [48 x i8] c"declare double @kx_get_field_f64(i64, i32, i32)\00"
@.str.385 = private unnamed_addr constant [5 x i8] c"i32 \00"
@.str.386 = private unnamed_addr constant [5 x i8] c"i64 \00"
@.str.387 = private unnamed_addr constant [5 x i8] c"ptr \00"
@.str.388 = private unnamed_addr constant [4 x i8] c"%r.\00"
@.str.389 = private unnamed_addr constant [32 x i8] c" = call i64 @kx_struct_new(i32 \00"
@.str.390 = private unnamed_addr constant [32 x i8] c"  call void @kx_struct_set(i64 \00"
@.str.391 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str.392 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str.393 = private unnamed_addr constant [6 x i8] c"i64 0\00"
@.str.394 = private unnamed_addr constant [29 x i8] c" = call ptr @kx_int_str(i64 \00"
@.str.395 = private unnamed_addr constant [29 x i8] c" = call ptr @kx_str_cat(ptr \00"
@.str.396 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str.397 = private unnamed_addr constant [4 x i8] c"i1 \00"
@.str.398 = private unnamed_addr constant [8 x i8] c"i1 true\00"
@.str.399 = private unnamed_addr constant [9 x i8] c"i1 false\00"
@.str.400 = private unnamed_addr constant [4 x i8] c"%t.\00"
@.str.401 = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.402 = private unnamed_addr constant [8 x i8] c" = add \00"
@.str.403 = private unnamed_addr constant [3 x i8] c", \00"
@.str.404 = private unnamed_addr constant [8 x i8] c" = sub \00"
@.str.405 = private unnamed_addr constant [8 x i8] c" = mul \00"
@.str.406 = private unnamed_addr constant [9 x i8] c" = sdiv \00"
@.str.407 = private unnamed_addr constant [9 x i8] c" = srem \00"
@.str.408 = private unnamed_addr constant [27 x i8] c" = call i1 @kx_str_eq(ptr \00"
@.str.409 = private unnamed_addr constant [12 x i8] c" = icmp eq \00"
@.str.410 = private unnamed_addr constant [27 x i8] c" = call i1 @kx_str_lt(ptr \00"
@.str.411 = private unnamed_addr constant [13 x i8] c" = icmp slt \00"
@.str.412 = private unnamed_addr constant [27 x i8] c" = call i1 @kx_str_gt(ptr \00"
@.str.413 = private unnamed_addr constant [13 x i8] c" = icmp sgt \00"
@.str.414 = private unnamed_addr constant [12 x i8] c" = icmp ne \00"
@.str.415 = private unnamed_addr constant [27 x i8] c" = call i1 @kx_str_le(ptr \00"
@.str.416 = private unnamed_addr constant [13 x i8] c" = icmp sle \00"
@.str.417 = private unnamed_addr constant [27 x i8] c" = call i1 @kx_str_ge(ptr \00"
@.str.418 = private unnamed_addr constant [13 x i8] c" = icmp sge \00"
@.str.419 = private unnamed_addr constant [11 x i8] c" = and i1 \00"
@.str.420 = private unnamed_addr constant [10 x i8] c" = or i1 \00"
@.str.421 = private unnamed_addr constant [5 x i8] c" 0, \00"
@.str.422 = private unnamed_addr constant [11 x i8] c" = xor i1 \00"
@.str.423 = private unnamed_addr constant [7 x i8] c", true\00"
@.str.424 = private unnamed_addr constant [6 x i8] c"%old.\00"
@.str.425 = private unnamed_addr constant [6 x i8] c"%inc.\00"
@.str.426 = private unnamed_addr constant [12 x i8] c" = add i64 \00"
@.str.427 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str.428 = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.429 = private unnamed_addr constant [12 x i8] c" = add i32 \00"
@.str.430 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.431 = private unnamed_addr constant [6 x i8] c"%dec.\00"
@.str.432 = private unnamed_addr constant [12 x i8] c" = sub i64 \00"
@.str.433 = private unnamed_addr constant [12 x i8] c" = sub i32 \00"
@.str.434 = private unnamed_addr constant [5 x i8] c"%is.\00"
@.str.435 = private unnamed_addr constant [14 x i8] c" = alloca ptr\00"
@.str.436 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str.437 = private unnamed_addr constant [14 x i8] c" = alloca i64\00"
@.str.438 = private unnamed_addr constant [16 x i8] c" = icmp ne ptr \00"
@.str.439 = private unnamed_addr constant [7 x i8] c", null\00"
@.str.440 = private unnamed_addr constant [31 x i8] c" = call i64 @kx_list_size(i64 \00"
@.str.441 = private unnamed_addr constant [29 x i8] c" = call i64 @kx_str_len(ptr \00"
@.str.442 = private unnamed_addr constant [32 x i8] c" = call i64 @kx_struct_get(i64 \00"
@.str.443 = private unnamed_addr constant [8 x i8] c"%field.\00"
@.str.444 = private unnamed_addr constant [28 x i8] c"  call i64 @kx_println(ptr \00"
@.str.445 = private unnamed_addr constant [7 x i8] c"void 0\00"
@.str.446 = private unnamed_addr constant [22 x i8] c"  call i64 @kx_print(\00"
@.str.447 = private unnamed_addr constant [31 x i8] c" = call ptr @kx_read_file(ptr \00"
@.str.448 = private unnamed_addr constant [10 x i8] c"writeFile\00"
@.str.449 = private unnamed_addr constant [31 x i8] c" = call i1 @kx_write_file(ptr \00"
@.str.450 = private unnamed_addr constant [25 x i8] c" = call ptr @kx_readln()\00"
@.str.451 = private unnamed_addr constant [32 x i8] c" = call i64 @kx_list_new(i32 2)\00"
@.str.452 = private unnamed_addr constant [26 x i8] c"  call void @kx_args(i64 \00"
@.str.453 = private unnamed_addr constant [26 x i8] c"  call void @kx_exit(i32 \00"
@.str.454 = private unnamed_addr constant [28 x i8] c" = call i64 @kx_system(ptr \00"
@.str.455 = private unnamed_addr constant [23 x i8] c"  call void @kx_stop()\00"
@.str.456 = private unnamed_addr constant [30 x i8] c" = call i64 @kx_rng_next(i64 \00"
@.str.457 = private unnamed_addr constant [30 x i8] c"  call void @kx_list_add(i64 \00"
@.str.458 = private unnamed_addr constant [7 x i8] c"ItemAt\00"
@.str.459 = private unnamed_addr constant [4 x i8] c"%c.\00"
@.str.460 = private unnamed_addr constant [29 x i8] c" = call i64 @kx_map_get(i64 \00"
@.str.461 = private unnamed_addr constant [30 x i8] c" = call i64 @kx_list_get(i64 \00"
@.str.462 = private unnamed_addr constant [6 x i8] c"%ptr.\00"
@.str.463 = private unnamed_addr constant [29 x i8] c"  call void @kx_map_set(i64 \00"
@.str.464 = private unnamed_addr constant [30 x i8] c"  call void @kx_list_set(i64 \00"
@.str.465 = private unnamed_addr constant [28 x i8] c" = call i1 @kx_map_has(i64 \00"
@.str.466 = private unnamed_addr constant [7 x i8] c"Remove\00"
@.str.467 = private unnamed_addr constant [32 x i8] c"  call void @kx_map_remove(i64 \00"
@.str.468 = private unnamed_addr constant [9 x i8] c"RemoveAt\00"
@.str.469 = private unnamed_addr constant [36 x i8] c"  call void @kx_list_remove_at(i64 \00"
@.str.470 = private unnamed_addr constant [6 x i8] c"Clear\00"
@.str.471 = private unnamed_addr constant [32 x i8] c"  call void @kx_list_clear(i64 \00"
@.str.472 = private unnamed_addr constant [32 x i8] c" = call ptr @kx_str_substr(ptr \00"
@.str.473 = private unnamed_addr constant [33 x i8] c" = call i1 @kx_str_contains(ptr \00"
@.str.474 = private unnamed_addr constant [36 x i8] c" = call i1 @kx_str_starts_with(ptr \00"
@.str.475 = private unnamed_addr constant [34 x i8] c" = call i1 @kx_str_ends_with(ptr \00"
@.str.476 = private unnamed_addr constant [31 x i8] c" = call ptr @kx_str_upper(ptr \00"
@.str.477 = private unnamed_addr constant [31 x i8] c" = call ptr @kx_str_lower(ptr \00"
@.str.478 = private unnamed_addr constant [32 x i8] c" = call i64 @kx_list_new(i32 0)\00"
@.str.479 = private unnamed_addr constant [38 x i8] c" = call i64 @kx_map_new(i32 0, i32 0)\00"
@.str.480 = private unnamed_addr constant [27 x i8] c"  call void @kx_panic(ptr \00"
@.str.481 = private unnamed_addr constant [4 x i8] c"Chr\00"
@.str.482 = private unnamed_addr constant [4 x i8] c"Ord\00"
@.str.483 = private unnamed_addr constant [5 x i8] c"i64|\00"
@.str.484 = private unnamed_addr constant [14 x i8] c"  call void @\00"
@.str.485 = private unnamed_addr constant [9 x i8] c" = call \00"
@.str.486 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.487 = private unnamed_addr constant [11 x i8] c"tern.then.\00"
@.str.488 = private unnamed_addr constant [11 x i8] c"tern.else.\00"
@.str.489 = private unnamed_addr constant [12 x i8] c"tern.merge.\00"
@.str.490 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str.491 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str.492 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str.493 = private unnamed_addr constant [14 x i8] c" = trunc i64 \00"
@.str.494 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str.495 = private unnamed_addr constant [6 x i8] c"%phi.\00"
@.str.496 = private unnamed_addr constant [8 x i8] c" = phi \00"
@.str.497 = private unnamed_addr constant [4 x i8] c", %\00"
@.str.498 = private unnamed_addr constant [5 x i8] c"], [\00"
@.str.499 = private unnamed_addr constant [8 x i8] c"%trunc.\00"
@.str.500 = private unnamed_addr constant [11 x i8] c"%inttoptr.\00"
@.str.501 = private unnamed_addr constant [11 x i8] c"%ptrtoint.\00"
@.str.502 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str.503 = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.504 = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.505 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str.506 = private unnamed_addr constant [11 x i8] c"  ret void\00"
@.str.507 = private unnamed_addr constant [9 x i8] c"if.then.\00"
@.str.508 = private unnamed_addr constant [10 x i8] c"if.merge.\00"
@.str.509 = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.510 = private unnamed_addr constant [8 x i8] c"w.cond.\00"
@.str.511 = private unnamed_addr constant [8 x i8] c"w.body.\00"
@.str.512 = private unnamed_addr constant [7 x i8] c"w.end.\00"
@.str.513 = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.514 = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.515 = private unnamed_addr constant [9 x i8] c"for.inc.\00"
@.str.516 = private unnamed_addr constant [9 x i8] c"for.end.\00"
@.str.517 = private unnamed_addr constant [9 x i8] c"%fe.idx.\00"
@.str.518 = private unnamed_addr constant [10 x i8] c"%fe.elem.\00"
@.str.519 = private unnamed_addr constant [20 x i8] c"  store i64 0, ptr \00"
@.str.520 = private unnamed_addr constant [9 x i8] c"fe.cond.\00"
@.str.521 = private unnamed_addr constant [9 x i8] c"fe.body.\00"
@.str.522 = private unnamed_addr constant [8 x i8] c"fe.end.\00"
@.str.523 = private unnamed_addr constant [6 x i8] c"%idx.\00"
@.str.524 = private unnamed_addr constant [18 x i8] c" = load i64, ptr \00"
@.str.525 = private unnamed_addr constant [6 x i8] c"%len.\00"
@.str.526 = private unnamed_addr constant [6 x i8] c"%cmp.\00"
@.str.527 = private unnamed_addr constant [17 x i8] c" = icmp slt i64 \00"
@.str.528 = private unnamed_addr constant [7 x i8] c"%elem.\00"
@.str.529 = private unnamed_addr constant [7 x i8] c"%next.\00"
@.str.530 = private unnamed_addr constant [8 x i8] c"sw.end.\00"
@.str.531 = private unnamed_addr constant [9 x i8] c"sw.case.\00"
@.str.532 = private unnamed_addr constant [9 x i8] c"sw.true.\00"
@.str.533 = private unnamed_addr constant [9 x i8] c"%entity.\00"
@.str.534 = private unnamed_addr constant [29 x i8] c" = call i64 @kx_spawn(i64 0)\00"
@.str.535 = private unnamed_addr constant [13 x i8] c"spawn_result\00"
@.str.536 = private unnamed_addr constant [28 x i8] c"  call void @kx_attach(i64 \00"
@.str.537 = private unnamed_addr constant [28 x i8] c"  call void @kx_detach(i64 \00"
@.str.538 = private unnamed_addr constant [29 x i8] c"  call void @kx_despawn(i64 \00"
@.str.539 = private unnamed_addr constant [5 x i8] c"main\00"
@.str.540 = private unnamed_addr constant [21 x i8] c"i32 %argc, ptr %argv\00"
@.str.541 = private unnamed_addr constant [3 x i8] c" %\00"
@.str.542 = private unnamed_addr constant [8 x i8] c"define \00"
@.str.543 = private unnamed_addr constant [4 x i8] c") {\00"
@.str.544 = private unnamed_addr constant [7 x i8] c"entry:\00"
@.str.545 = private unnamed_addr constant [48 x i8] c"  call void @kx_save_args(i32 %argc, ptr %argv)\00"
@.str.546 = private unnamed_addr constant [6 x i8] c".addr\00"
@.str.547 = private unnamed_addr constant [12 x i8] c"  ret i32 0\00"
@.str.548 = private unnamed_addr constant [15 x i8] c"  ret ptr null\00"
@.str.549 = private unnamed_addr constant [15 x i8] c"  ret i1 false\00"
@.str.550 = private unnamed_addr constant [3 x i8] c" 0\00"
@.str.551 = private unnamed_addr constant [4 x i8] c"pwd\00"
@.str.552 = private unnamed_addr constant [3 x i8] c"//\00"
@.str.553 = private unnamed_addr constant [10 x i8] c"mkdir -p \00"
@.str.554 = private unnamed_addr constant [21 x i8] c"[package]\5Cnname = \5C\22\00"
@.str.555 = private unnamed_addr constant [92 x i8] c"\5C\22\5Cnversion = \5C\220.1.0\5C\22\5Cn\5Cntarget\5Cnkind = \5C\22binary\5C\22\5Cnentry = \5C\22main.kx\5C\22\5Cn\5Cndependencies\5Cn\00"
@.str.556 = private unnamed_addr constant [9 x i8] c"/.kxconf\00"
@.str.557 = private unnamed_addr constant [9 x i8] c"/main.kx\00"
@.str.558 = private unnamed_addr constant [41 x i8] c"int main() {\0A    kx_println(\22Hello from \00"
@.str.559 = private unnamed_addr constant [22 x i8] c"!\22);\0A    return 0;\0A}\0A\00"
@.str.560 = private unnamed_addr constant [17 x i8] c"created project \00"
@.str.561 = private unnamed_addr constant [8 x i8] c".kxconf\00"
@.str.562 = private unnamed_addr constant [6 x i8] c"entry\00"
@.str.563 = private unnamed_addr constant [8 x i8] c"main.kx\00"
@.str.564 = private unnamed_addr constant [20 x i8] c"error: cannot read \00"
@.str.565 = private unnamed_addr constant [43 x i8] c"target triple = \22x86_64-unknown-linux-gnu\22\00"
@.str.566 = private unnamed_addr constant [7 x i8] c"output\00"
@.str.567 = private unnamed_addr constant [13 x i8] c"package.name\00"
@.str.568 = private unnamed_addr constant [4 x i8] c".kx\00"
@.str.569 = private unnamed_addr constant [7 x i8] c".build\00"
@.str.570 = private unnamed_addr constant [11 x i8] c"/output.ll\00"
@.str.571 = private unnamed_addr constant [10 x i8] c"/output.o\00"
@.str.572 = private unnamed_addr constant [10 x i8] c"compiled \00"
@.str.573 = private unnamed_addr constant [5 x i8] c" -> \00"
@.str.574 = private unnamed_addr constant [8 x i8] c"llc-21 \00"
@.str.575 = private unnamed_addr constant [19 x i8] c" -filetype=obj -o \00"
@.str.576 = private unnamed_addr constant [22 x i8] c" 2>&1 && gcc -no-pie \00"
@.str.577 = private unnamed_addr constant [27 x i8] c" runtime/runtime.c -lm -o \00"
@.str.578 = private unnamed_addr constant [6 x i8] c" 2>&1\00"
@.str.579 = private unnamed_addr constant [15 x i8] c"linking failed\00"
@.str.580 = private unnamed_addr constant [7 x i8] c"built \00"
@.str.581 = private unnamed_addr constant [8 x i8] c"/build/\00"
@.str.582 = private unnamed_addr constant [10 x i8] c"check: OK\00"
@.str.583 = private unnamed_addr constant [16 x i8] c"package.version\00"
@.str.584 = private unnamed_addr constant [58 x i8] c"error: .kxconf must have package.name and package.version\00"
@.str.585 = private unnamed_addr constant [12 x i8] c"publishing \00"
@.str.586 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.587 = private unnamed_addr constant [4 x i8] c"...\00"
@.str.588 = private unnamed_addr constant [39 x i8] c"(publish requires registry connection)\00"
@.str.589 = private unnamed_addr constant [12 x i8] c"installing \00"
@.str.590 = private unnamed_addr constant [39 x i8] c"(install requires registry connection)\00"
@.str.591 = private unnamed_addr constant [15 x i8] c"searching for \00"
@.str.592 = private unnamed_addr constant [38 x i8] c"(search requires registry connection)\00"
@.str.593 = private unnamed_addr constant [35 x i8] c"login requires registry connection\00"
@.str.594 = private unnamed_addr constant [26 x i8] c"generating signing key...\00"
@.str.595 = private unnamed_addr constant [72 x i8] c"openssl ecparam -genkey -name ed25519 -out ~/.kubex/key.pem 2>/dev/null\00"
@.str.596 = private unnamed_addr constant [34 x i8] c"key generated at ~/.kubex/key.pem\00"
@.str.597 = private unnamed_addr constant [19 x i8] c"generating SBOM...\00"
@.str.598 = private unnamed_addr constant [38 x i8] c"(SBOM generation not yet implemented)\00"
@.str.599 = private unnamed_addr constant [32 x i8] c"scanning for vulnerabilities...\00"
@.str.600 = private unnamed_addr constant [60 x i8] c"osv-scanner 2>/dev/null || echo 'osv-scanner not installed'\00"
@.str.601 = private unnamed_addr constant [46 x i8] c"kubex -- Kubexic compiler and package manager\00"
@.str.602 = private unnamed_addr constant [19 x i8] c"compiler commands:\00"
@.str.603 = private unnamed_addr constant [58 x i8] c"  build <dir>      Compile .kx files to native executable\00"
@.str.604 = private unnamed_addr constant [39 x i8] c"  run <dir>        Compile and execute\00"
@.str.605 = private unnamed_addr constant [40 x i8] c"  check <dir>      Type-check a project\00"
@.str.606 = private unnamed_addr constant [40 x i8] c"  new <name>       Create a new project\00"
@.str.607 = private unnamed_addr constant [40 x i8] c"  init <name>      Create a new project\00"
@.str.608 = private unnamed_addr constant [18 x i8] c"package commands:\00"
@.str.609 = private unnamed_addr constant [39 x i8] c"  publish          Publish to registry\00"
@.str.610 = private unnamed_addr constant [37 x i8] c"  install <pkg>    Install a package\00"
@.str.611 = private unnamed_addr constant [35 x i8] c"  search <query>   Search packages\00"
@.str.612 = private unnamed_addr constant [32 x i8] c"  login            Authenticate\00"
@.str.613 = private unnamed_addr constant [41 x i8] c"  keygen           Generate signing keys\00"
@.str.614 = private unnamed_addr constant [33 x i8] c"  sbom             Generate SBOM\00"
@.str.615 = private unnamed_addr constant [44 x i8] c"  audit            Scan for vulnerabilities\00"
@.str.616 = private unnamed_addr constant [9 x i8] c"options:\00"
@.str.617 = private unnamed_addr constant [34 x i8] c"  --help, -h       Show this help\00"
@.str.618 = private unnamed_addr constant [32 x i8] c"  --version        Show version\00"
@.str.619 = private unnamed_addr constant [7 x i8] c"--help\00"
@.str.620 = private unnamed_addr constant [3 x i8] c"-h\00"
@.str.621 = private unnamed_addr constant [10 x i8] c"--version\00"
@.str.622 = private unnamed_addr constant [12 x i8] c"kubex 0.1.0\00"
@.str.623 = private unnamed_addr constant [5 x i8] c"init\00"
@.str.624 = private unnamed_addr constant [25 x i8] c"usage: kubex init <name>\00"
@.str.625 = private unnamed_addr constant [6 x i8] c"build\00"
@.str.626 = private unnamed_addr constant [4 x i8] c"run\00"
@.str.627 = private unnamed_addr constant [6 x i8] c"check\00"
@.str.628 = private unnamed_addr constant [8 x i8] c"publish\00"
@.str.629 = private unnamed_addr constant [8 x i8] c"install\00"
@.str.630 = private unnamed_addr constant [27 x i8] c"usage: kubex install <pkg>\00"
@.str.631 = private unnamed_addr constant [7 x i8] c"search\00"
@.str.632 = private unnamed_addr constant [28 x i8] c"usage: kubex search <query>\00"
@.str.633 = private unnamed_addr constant [6 x i8] c"login\00"
@.str.634 = private unnamed_addr constant [7 x i8] c"keygen\00"
@.str.635 = private unnamed_addr constant [5 x i8] c"sbom\00"
@.str.636 = private unnamed_addr constant [6 x i8] c"audit\00"
@.str.637 = private unnamed_addr constant [18 x i8] c"unknown command: \00"
@.str.638 = private unnamed_addr constant [29 x i8] c"run 'kubex --help' for usage\00"
