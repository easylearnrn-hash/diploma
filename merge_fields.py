import re

with open("final-form.html", "r") as f:
    html = f.read()

# extract the form groups using basic regex
# we won't reinvent the wheel, we will just copy the form sections manually into info-form if we can.
