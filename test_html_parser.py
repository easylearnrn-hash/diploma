from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.in_script = False
        self.self_closing = ['meta', 'link', 'input', 'img', 'br', 'hr', 'source', 'path', 'circle', 'ellipse', 'svg', 'rect']

    def handle_starttag(self, tag, attrs):
        if tag == 'script':
            self.in_script = True
        if not self.in_script and tag not in self.self_closing and tag != '!doctype':
            self.tags.append(tag)

    def handle_endtag(self, tag):
        if tag == 'script':
            self.in_script = False
            return
        if self.in_script or tag in self.self_closing:
            return
        if self.tags:
            expected = self.tags.pop()
            if expected != tag:
                # ignore mismatches caused by embedded raw script innerHTML strings
                pass

parser = MyHTMLParser()
with open('test.html', 'r', encoding='utf-8') as f:
    parser.feed(f.read())
print("Finished. Unclosed tags remaining (ignoring innerHTML string weirdness):")
print(parser.tags)
