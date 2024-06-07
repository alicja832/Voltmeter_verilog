# Enable pyserial extensions
import pyftdi.serialext

# Open a serial port on the second FTDI device interface (IF/2) @ 3Mbaud
brate = 230400
url = 'ftdi://ftdi:232:AB0K3Q4S/1'

while(True):

    port = pyftdi.serialext.serial_for_url(url, baudrate=brate, bytesize=8, stopbits=1, parity='N', xonxoff=False, rtscts=False)
    # Send bytes
            #print("Transmition at", brate)
    b = bytes([0x33, 0xC7])
            #print("-", b)
    print()
    port.write(b)

        # Receive bytes
    nb = 7
    print("Odebrane napięcie")
    data = port.read(nb)
    print('-', data)
       
        #
    port.close()

