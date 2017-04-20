import sys

file = open('/home/Agora/resources/current_ports.txt', 'r+')
current_ports = file.read().split('\n')
port = 0

# To edit the number of connections, modify this variable
max_connections = 100

for i in range(1,max_connections):
  if not (str(i) in current_ports):
    # If this port is not currently being used, use it
    file.write(str(i) + "\n")
    port = i
    break

file.close()
sys.exit(port)
