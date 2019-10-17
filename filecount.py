#!/usr/bin/python2.7

import os, sys
from stat import *

# This is a quick program to solve a problem... recursively walk down a file tree accounting the files that are found. Display the totals at the end.
# Credit to u/mysticalfruit from Reddit for creating this.

MAX_EXT_LENGTH = 5

class file_extension(object):
    count = 0
    size = 0 # total size


class file_sorter(object):
    def __init__(self, top_location):
        self.top_location = top_location
        self.file_ext = {}
        self.failed_count = 0

    def count_extensions(self):
        """
        This function recursively walks the directory looking for files. When it finds one
        it checks to see if we already have seen this extension, if not it adds an entry to the dictionary
        then it adds one to the count and gets the size
        """
        for root, dirs, files in os.walk(self.top_location):
            for name in files:
                full_path = os.path.join(root, name)
                #print full_path
                extension = name.split('.')[-1].lower() # we just want the last bit and let's lower case it so .MP3 and .mp3 are the same time.
                if len(extension) > MAX_EXT_LENGTH: # bail on weird super long extensions
                    continue
                #print extension
                if not extension: # what if you have a file without an extension?
                    continue
                if not self.file_ext.has_key(extension):
                    self.file_ext[extension] = file_extension()
                    self.file_ext[extension].extension = extension
                
                try:
                    size = os.stat(full_path).st_size
                except:
                    #print "Failed on file:", full_path
                    self.failed_count += 1
                    continue
                self.file_ext
                self.file_ext[extension].count += 1
                self.file_ext[extension].size += size # this is in bytes
    
    def print_results(self):
        # This just prints sorting by key..
        #for key in sorted(self.file_ext.keys()):
        #    print "%-10s\t%d\t%d" % (key, self.file_ext[key].count, self.file_ext[key].size)
        """
        This function reverse sorts the dictionary using the size as a lamda key
        change size to count to get the counts
        """
        print "FileType\tCount\tSize"
        for key in sorted(self.file_ext, key=lambda i: int(self.file_ext[i].size), reverse = True):
            print "%-10s\t%d\t%s" % (key, self.file_ext[key].count, self.human_size(self.file_ext[key].size))
        print "Faile to scan %d files" % self.failed_count
     
    def human_size(self, size_bytes):
        """
        format a size in bytes into a 'human' file size, e.g. bytes, KB, MB, GB, TB, PB
        Note that bytes/KB will be reported in whole numbers but MB and above will have greater precision
        e.g. 1 byte, 43 bytes, 443 KB, 4.3 MB, 4.43 GB, etc
        """
        if size_bytes == 1:
            # because I really hate unnecessary plurals
            return "1 byte"

        suffixes_table = [('bytes',0),('KB',0),('MB',1),('GB',2),('TB',2), ('PB',2)]

        num = float(size_bytes)
        for suffix, precision in suffixes_table:
            if num < 1024.0:
                break
            num /= 1024.0

        if precision == 0:
            formatted_size = "%d" % num
        else:
            formatted_size = str(round(num, ndigits=precision))

        return "%s %s" % (formatted_size, suffix)   
        
        
                    

def main(argv):
    if len(argv) == 0:
        print("Doh! You must enter a path to search!")
        exit(-1)
    x = file_sorter(argv[0])
    x.count_extensions()
    x.print_results()

if __name__ == '__main__':
    main(sys.argv[1:])
