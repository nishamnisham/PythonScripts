#%%
# -- importing libraries
import PyPDF2
import os, sys

# %%
# -- specifying file name and location
parent_path = 'C:/Users/nisha/OneDrive - Floating Solutions Consulting/Documents/04. Projects/SAN-06 HISIM/03. Working/Integrity Management/2022/Inspection Reports'
file_name =  '4035479-001 - NV.CPR.Rev.B.pdf'
file_path = os.path.join(parent_path,file_name)
#%%
# --  creating a pdf object
pdfFileObj = open(file_path, 'rb')
pdf = PyPDF2.PdfFileReader(pdfFileObj)

# %%
# -- create a page object


def getContentsFromPages(pdf):
    '''Takes in pdf object,
    Create a list for page numbers
    Create a list for content in the pages
    Zip them into a dictionary so that it can be sliced based on page number
    '''
    number_of_pages = pdf.numPages
    page_index = [i for i in range(number_of_pages)]
    page_content_list = [pdf.getPage(i).extract_text() for i in page_index]
    page_index = [i+1 for i in range(number_of_pages)]
    content_dict = dict(zip(page_index,page_content_list))
    return content_dict

# --  Extract contents of the page and store into a dictionary with page numbers as keys
page_content_raw = getContentsFromPages(pdf)


def splitByLines(page_content_raw):
    '''Split each page of the pdf by lines
    and store them as lists into the same dictionary
    '''
    page_content = {}
    for key,value in page_content_raw.items():
        new_value = value.split('\n')
        page_content.update({key:new_value})
    return page_content

# -- extract text from page
page_contents = splitByLines(page_content_raw)
# %%
def pageWithSpecificText(page_contents,Text):
    x = []
    y = []
    for key,value in page_contents.items():
        
        for ind,i in enumerate(value):
            if i.count(Text) >= 1:
                x.append(key)
                y.append(ind)
    return x,y
# %%
def CriticalFindings(page_contents,Text):
    x,y = pageWithSpecificText(page_contents,Text)[0]
    
    #critical_finding = page_contents[x[1]][y[0]]
    return x,y
# %%
