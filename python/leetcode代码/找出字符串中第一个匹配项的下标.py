haystack = "sadbutsad"
needle = "sad2"
s = len(needle)
s2= len(haystack)
m = 0
if needle[m] in haystack:
    for i in range(s2-1):
        if haystack[i] == needle[m]:
            m = m +1
            if m == s-1:
                print("1")
            break
else:
    print("-1")
