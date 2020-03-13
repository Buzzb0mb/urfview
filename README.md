# urfview
a ruby script to download an image from [google's earthview](https://earthview.withgoogle.com/) based on a desired color\
\
Usage: `./urfview.rb [RGB]`\
where RGB is 3 numbers between 0 and 255 in any format (scanned with `/([0-9]+)/`). if no color is specified it will generate a random one. it will write the found image to `photos.jpg` which is defined as the constant `OUT_PATH` at the beginning of the script.
