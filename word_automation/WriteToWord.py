#%%
import os, sys # standard Python libraries
from docxtpl import DocxTemplate, InlineImage
from docx.shared import Cm, Inches, Mm, Emu
import win32com.client as win32


# change path to the current working directory
os.chdir(sys.path[0])

doc =  DocxTemplate('Template.docx')

placeholder_1 =  InlineImage(doc, 'Images/Image_1.png', Cm(14))

context = {'Heading_1': 'Introduction','name_a':2500,
            'name_b': 'The information in this communication is general in nature. World First Pty Limited (“WFPTY”) is an Australian company (Company No 132 368 971), holds an Australian Financial Services Licence (AFSL No 331945), is regulated by the Australian Securities and Investments Commission and is a member of the Australian Financial Complaints Authority (Membership No. 13405). In New Zealand, WFPTY is registered as an overseas ASIC Company (CN: 5837089, NZBN: 9429042041061), a financial service provider on the FSP Register (FSP1000732), an AML/CTF reporting entity regulated by the Department of Internal Affairs for remittance and a member of Financial Services Complaints Limited (Membership No. 8696). Registered office: 7/33 York Street, Sydney 2000, NSW, Australia',
            'superscript2':2,
            'placeholder_1':placeholder_1,
            'caption_image_1': 'A screenshot from VS Code.'}

#%%
output_name = 'Template_rendered.docx'
doc.render(context)
doc.save(output_name)
# %%

# -- Converting the word document to pdf

def convert_to_pdf(document_name):
    '''Convert given word document to pdf'''
    word = win32.DispatchEx("Word.Application")
    new_name = document_name.replace(".docx", r" .pdf")
    worddoc = word.Documents.Open(document_name)
    worddoc.SaveAs(new_name, FileFormat=17)
    worddoc.Close()
    return None

# %%
#%%
path_to_word_document = os.path.join(os.getcwd(), output_name)
convert_to_pdf(path_to_word_document)
# %%
