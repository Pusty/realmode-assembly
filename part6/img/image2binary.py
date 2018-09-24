from PIL import Image #Import Image from Pillow
import sys

palleteFile = "colors.png" #pallete the BIOS uses
if len(sys.argv) < 2:
    convertFile = "fox.png" #image to turn into a binary
    outputFile  = "fox.bin" #name of output file
elif len(sys.argv) < 3:
    convertFile = sys.argv[1]
    outputFile  = sys.argv[1]+".bin"
elif len(sys.argv) >= 3:
    convertFile = sys.argv[1]
    outputFile  = sys.argv[2]

pal = Image.open(palleteFile).convert('RGB')
pallete = pal.load() #load pixels of the pallete
image = Image.open(convertFile).convert('RGB')
pixels = image.load() #load pixels of the image

binary = open(outputFile, "wb") #open/create binary file

list = [] #create a list for the pallete
for y in range(pal.height):
    for x in range(pal.width):
        list.append(pallete[x,y]) #save the pallete into an array

binary.write(bytearray([image.width&0xFF,image.height&0xFF])) #write width and height as the first two bytes
data = []
print(image.height)
print(image.width)
for y in range(image.height):
    for x in range(image.width):
        difference = 0xFFFFFFF #init difference with a high value
        choice = 0 #the index of the color nearest to the original pixel color
        index = 0 #current index within the pallete array
        #print sum([(pixels[x,y][i])**2 for i in range(3)])
        for c in list:
            dif = sum([(pixels[x,y][i] - c[i])**2 for i in range(3)]) #calculate difference for RGB values
            if dif < difference:
                difference = dif
                choice = index
            index += 1
        data = bytearray([choice&0xFF])
        print("[%d,%d] %d = %d (%d)" % (x,y,choice, difference, len(data)))
        binary.write(data) #write nearest pallete index into binary file
binary.close() # close file handle
print("Done.")