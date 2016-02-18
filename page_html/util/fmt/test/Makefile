
all: base64 escapeless

# Compare and bijecton test.
base64:
	sh base64.sh | head

escapeless: escapeless_0 escapeless_1 escapeless_2 escapeless_3 escapeless_n

# Bijection test.
escapeless_0:
	echo -n | lua bin_escapeless.lua

escapeless_1:
	head -c 1 /dev/random | lua bin_escapeless.lua
escapeless_2:
	head -c 2 /dev/random | lua bin_escapeless.lua
escapeless_3:
	head -c 3 /dev/random | lua bin_escapeless.lua

escapeless_n:
	head -c "$(expr $RANDOM % 64)" /dev/random | lua bin_escapeless.lua
