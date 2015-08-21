all: index.html index-local.html

index.html: README.md
	slidybuild < README.md > index.html

index-local.html: index.html slidy.css slidy.js
	cat index.html | \
	sed 's|"http://www.w3.org/Talks/Tools/Slidy2/styles/slidy.css"|"slidy.css"|' | \
	sed 's|"http://www.w3.org/Talks/Tools/Slidy2/scripts/slidy.js"|"slidy.js"|' > \
	index-local.html

slidy.css:
	wget http://www.w3.org/Talks/Tools/Slidy2/styles/slidy.css

slidy.js:
	wget http://www.w3.org/Talks/Tools/Slidy2/scripts/slidy.js
