import os

def has_suffix(string, suffix):
	return len(string) >= len(suffix) and string[-len(suffix):]==suffix

template = open('wrap.html').read()

def wrap_files_in_dir(dir):
	for filename in os.listdir(dir):
		child = os.path.join(dir, filename)
		if os.path.isdir(child):
			wrap_files_in_dir(child)
		elif has_suffix(child, '-src.html'):
			out_path = child[:-len('-src.html')]+'.html'
			open(out_path, 'w').write(template.replace('<!--CONTENT-->', open(child).read()))

wrap_files_in_dir('.')
