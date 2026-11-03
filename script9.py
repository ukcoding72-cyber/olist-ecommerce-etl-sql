name = "maam"
reverse = ""
i = 0
while i < len(name):
    reverse = name[i] + reverse
    i += 1
if (name == reverse):
     print("palindrome")
else:
    print("not palindrome")



