require 'rubygems'
require 'rmagick'



class Integer # chuyen doi tu thap phan sang nhi phan
  def to_bin(width)
    '%0*b' % [width, self]
  end
end

class Encode
	def initialize(link)
		@link = link
		@thongdiep
		@dem = 0
		@image
		@pixel_list = []
	
	end
	

	def converse_bit(pixel) # chuyen RGB 16 bit ve 8bit
		pixel.red /= 257
		pixel.green /= 257
		pixel.blue /= 257
		
	end
	
	
	def ChenThongDiep (pixel) # chen thong diep dang bit vao trong RGB
			
			red = pixel.red.to_bin(8).chars #pixel.red kieu integer -> nhi phan -> array char
			red[7] = @thongdiep[@dem] # chen 1 bit cua thong diep vao bit cuoi cua pixel.red
			pixel.red = red.join.to_i(2) # array char -> string -> integer
			@dem += 1 # dem 
			
			if @dem == @thongdiep.length # kiem tra da chen het thong diep chua
				return 
			end
			green = pixel.green.to_bin(8).chars
			green[7] = @thongdiep[@dem]
			pixel.green = green.join.to_i(2)
			@dem += 1
			
			if @dem == @thongdiep.length
				return 
			end
			blue = pixel.blue.to_bin(8).chars
			blue[7] = @thongdiep[@dem]
			pixel.blue = blue.join.to_i(2)
			@dem += 1
			if @dem == @thongdiep.length
				return  
			end

		
	end

	def encode
		begin
			@image = Magick::Image::read(@link).first #doc file image
			puts "nhap vao thong diep :"
			nhap = gets.chomp # nhap tu ban phim
			@thongdiep = nhap.unpack("B*")# string -> binary data
			thongdiep1 = @thongdiep.pop.chars # binary data -> array char
			@thongdiep = thongdiep1
			@pixel_list = @image.get_pixels(0,0,@image.columns,@image.rows) # lay pixel, tu vi tri x = 0 ,y = 0 cho den het
			@pixel_list.each do |pixel| #duyen danh sach pixel
				converse_bit(pixel) # chuyen ve 8 bit
				if @dem == @thongdiep.length # chen xong thong diep thi cho pixel ke tiep = 0
					pixel.red = 0
					pixel.green = 0
					pixel.blue = 0
					break
				else
					ChenThongDiep(pixel)
				end
			end
			img = Magick::Image.new(@image.columns,@image.rows) # tao iamge moi
			img.store_pixels(0,0,img.columns,img.rows,@pixel_list) # gan danh sach pixel cho anh moi, tu vi tri 0,0 den het
			
			#show_pixel(img)
			image_hidden = @link.split("/")[2] # cat chuoi
			image_hidden = image_hidden.split(".")[0]
			image_hidden = "./Modified_Image/" + image_hidden + "_hidden.png"
			img.write(image_hidden)
			img.display
		rescue
			puts "File not found ! "
		end
	end

end


class Decode 
	def initialize(link)
		@link = link
		@thongdiep = ""
		@quocdanh = ""
		@pixel_list = []
		@image 

	end

	def converse_bit(pixel) #chuyen doi RGB tu 16 bit sang 8 bit
		pixel.red /= 257
		pixel.green /= 257
		pixel.blue /= 257
		
	end

	def LayThongDiep(pixel) 

		red = pixel.red.to_bin(8).chars
		@thongdiep = @thongdiep + red[7]
		green = pixel.green.to_bin(8).chars
		@thongdiep = @thongdiep + green[7]
		blue = pixel.blue.to_bin(8).chars
		@thongdiep = @thongdiep + blue[7]
	end
		
	def GomTu
		
		for i in 1..(@thongdiep.length/8) 
			word = @thongdiep[0,8] # bat dau tu vi tri 0 , lay 8 phan tu (string)
			@quocdanh = @quocdanh + word.to_i(2).chr # 8 bit binary -> integer -> ASCII 
			@thongdiep = @thongdiep[8..@thongdiep.length] # bo di phan da lay
		end
	end


	def decode
		begin
		@image = Magick::Image::read(@link).first 
		
			#pixel_list = image.get_pixels(0,0,image.columns,image.rows)
			@image.each_pixel do |pixel,col,row| # lay pixel cua anh
				if pixel.red == 0 && pixel.green == 0 && pixel.blue == 0
					break
				else
					@pixel_list.push(pixel) # bo vao array pixel
				end

			end
			@pixel_list.each do |pixel|
			 	LayThongDiep(pixel)
			end
			GomTu()
			puts @quocdanh
		rescue
			puts "File not found ! "
		end
	end

	

end

menu = "1.Encode\n2.Decode"
puts menu
print "chon : "
chon = gets.chomp.to_i
case chon
when 1 
	puts "-- Original_Image :"
	system "ls ./Original_Image/"
	print "Nhap anh : "
	link = gets.chomp
	link = "./Original_Image/"+link
	encode = Encode.new(link)
	encode.encode
when 2
	puts "--Modified_Image :"
	system "ls ./Modified_Image/"
	print "Nhap anh : "
	link = gets.chomp
	link = "./Modified_Image/"+link
	decode = Decode.new(link)
	decode.decode
end

