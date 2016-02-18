
all: base64 escapeless

# Compare and bijecton test.
base64:
	sh base64.sh | head

escapeless: escapeless_inp escapeless_0 escapeless_1 escapeless_2 \
 escapeless_3 escapeless_30 escapeless_3000

# Bijection test.
escapeless_0:
	echo -n | lua escapeless.lua

escapeless_inp:
	echo _does. it, Work? KK Q QQ QQQ QKQQ QX AQ PVDA | lua escapeless.lua

escapeless_1:
	head -c 1 /dev/random | lua escapeless.lua
escapeless_2:
	head -c 2 /dev/random | lua escapeless.lua
escapeless_3:
	head -c 3 /dev/random | lua escapeless.lua

escapeless_30:
	head -c 30 /dev/random | lua escapeless.lua

escapeless_3000:
	head -c 3000 /dev/random | lua escapeless.lua > /dev/null
