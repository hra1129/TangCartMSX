import sys

if len(sys.argv) != 2:
    print("Usage: python script.py <input_binary_file>")
    sys.exit(1)

filename = sys.argv[1]

try:
    with open(filename, 'rb') as f:
        data = f.read()
except FileNotFoundError:
    print(f"Error: File {filename} not found.")
    sys.exit(1)

S = len(data)

if S == 0:
    print("Error: Input file is empty.")
    sys.exit(1)

print(f"reg [7:0] ff_ram [0:{S-1}];")
print("initial begin")
for i in range(S):
    hex_str = hex(data[i])[2:].zfill(2).upper()
    print(f"    ff_ram[{i}] = 8'h{hex_str};")
print("end")
