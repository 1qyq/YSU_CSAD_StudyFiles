#include <iostream>
#include <stack>
#include <unordered_map>
using namespace std;

string str;
unordered_map<char,int> pri = {{'+', 1}, {'-', 1}, {'*', 2}, {'/', 2}};

stack<int> num;
stack<char> op;

void eval()
{
    int b = num.top(); num.pop();
    int a = num.top(); num.pop();
    char c = op.top(); op.pop();
    if (c == '+') a = a + b;
    else if (c == '-') a = a - b;
    else if (c == '*') a = a * b;
    else a = a / b;
    num.push(a);
}


int main()
{

    cin >> str;
    for (int i = 0; i < str.size(); i ++)
    {
        char c = str[i];
        if (isdigit(c))
        {
            int x = 0, j = i;
            while (j < str.size() && isdigit(str[j]))
            {
                x = x * 10 + str[j ++] - '0';
            }
            i = j - 1;
            num.push(x);
        }
        else if (c == '(') op.push(c);
        else if (c == ')')
        {
            while (op.top() != '(') eval();
            op.pop();
        }
        else 
        {
            while (op.size() && pri[op.top()] >= pri[c]) eval();
            op.push(c);
        }
    }
    while (op.size()) eval();
    cout << num.top() << endl;
    return 0;
}