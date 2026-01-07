# s = ["h","e","l","l","o"]
# m= len(s)
# for i in range(m):
#     s.append(s[m-i-1])
# print(s)
# for i in range(m):
#     del s[0]
# print(s)

s = ["h","e","l","l","o"]
left = 0
right = len(s)-1

while left < right:
    s[left],s[right]=s[right],s[left]
    left =left + 1
    right =right - 1
print(s)

