#define _CRT_SECURE_NO_WARNINGS 1
#include <iostream>
#include <algorithm>
#include <cstring>
#include <vector>
#include <set> 
#include <queue> 
#include <deque>
#include <map>
#include <unordered_map>
using namespace std;
const int N = 110;
typedef pair<int, int> PII;

void MyPrint(set<int> T);
void MyPrint();
int find(vector<set<int>> DFA, set<int> U);
bool Segment(pair<set<int>, int> se, int i);
int Serach(int S, string s);
int Serach(vector<pair<set<int>, int>> segment, int v);
int find(pair<set<int>, int> seg, string a);
int FindLoc(set<int> Q);
void MyPrint_Temp(vector<pair<set<int>, int>> segment);

struct Edge
{
    int v, next;
    string a;
}edge[N];
int head[N], idx;

vector<string> xiTa;//字母表
int k, st, ed;//状态个数和开始状态
vector<int> State;//状态节点
set<int> St, Ed;
set<int> eClosure[N];
int m;

void AddEdge(int u, string a, int v)
{
    edge[idx].v = v;
    edge[idx].a = a;
    edge[idx].next = head[u];
    head[u] = idx++;

}

void init()
{
    memset(head, -1, sizeof head);

    cout << "请输入状态个数 和 开始状态个数 以及 结束状态个数" << endl;
    cin >> k >> st >> ed;
    cout << "请输入状态的编号:" << endl;
    for (int i = 0; i < k; i++) { int s; cin >> s; State.push_back(s); }
    cout << "请输入开始状态" << endl;
    for (int i = 0; i < st; i++) { int s; cin >> s; St.insert(s); }
    cout << "请输入结束状态" << endl;
    for (int i = 0; i < ed; i++) { int s; cin >> s; Ed.insert(s); }

    cout << "请输入字母表个数(除 e 外)" << endl;
    cin >> m;

    cout << "请输入字母表字母" << endl;
    for (int i = 0; i < m; i++)
    {
        string a; cin >> a;
        xiTa.push_back(a);
    }
    cout << "请输入状态转换弧, 格式为(当前状态 输入符号 后继状态), 以 0 e 0 结束, 其中 e 表示空符号" << endl;
    int d, h; string a;
    while (cin >> d >> a >> h && !(d == 0 && a == "e" && h == 0))
    {
        AddEdge(d, a, h);
    }
}

void E_Closure()
{
    bool vis[N];
    cout << endl << "---------------------" << endl << "NFA状态的E_Closure如下:" << endl;
    for (auto i : State)
    {
        memset(vis, false, sizeof vis);
        queue<int> q;
        eClosure[i].insert(i);
        q.push(i);
        while (q.size())
        {
            int k = q.front();
            q.pop();
            // if (vis[k]) continue;
            // vis[k] = 1;
            for (int j = head[k]; j != -1; j = edge[j].next)
            {
                string a = edge[j].a; int v = edge[j].v;
                if (a == "e" && !vis[v])
                {
                    vis[v] = true;
                    eClosure[i].insert(v);
                    q.push(v);
                }
            }
        }
        cout << i << " 的E_Closure为: ";
        MyPrint(eClosure[i]); cout << endl;
    }
}

set<int> Move(set<int> T, string a)
{
    set<int> t;
    for (auto k : T)
    {
        for (int i = head[k]; i != -1; i = edge[i].next)
        {
            string w = edge[i].a; int v = edge[i].v;
            if (w == a) t.insert(v);
        }
    }
    return t;
}

set<int> E_Closure(set<int> T)
{
    set<int> t;
    for (auto k : T)
    {
        t.insert(eClosure[k].begin(), eClosure[k].end());
    }
    return t;
}


vector<set<int>> DFA_1;
deque<set<int>> qTemp;// 状态确定, 在MyPrint更方便
vector<pair<PII, string>> DFA_2;// DFA的边
void Solve()//子集法构造DFA
{
    
    DFA_1.push_back(E_Closure(St));//将K0的e-closure放入集合DFA

    int cnt = 0;
    while (cnt < DFA_1.size())
    {
        auto temp = DFA_1[cnt];
        qTemp.push_back(temp); // 便于以后输出矩阵
        for (auto a : xiTa)
        {
            set<int> U;
            U = Move(temp, a);
            U = E_Closure(U);
            qTemp.push_back(U); // 便于以后输出;
            
            if (find(DFA_1, U) == -1)
            {
                DFA_1.push_back(U);
            }
            int location = find(DFA_1, U);// 先放再找location否则可能为 -1;
            DFA_2.push_back({ { cnt, location }, a });
        }
        cnt++;
    }
}
int find(vector<set<int>> DFA, set<int> U)
{
    for (int i = 0; i < DFA.size(); i ++)
    {
        if (DFA[i] == U) return i;
    }
    return -1;
}


set<int> dfaEd;// 确定化后dfa的终止状态
void MyPrint(vector<set<int>> DFA)
{
    cout << endl << "DFA矩阵表示" << endl << "-----------------------------" << endl;

    for (auto a : xiTa) cout << "                          " << a;
    puts("");


    for (int i = 0; i < DFA.size(); i++)
    {
        cout << 'T' << i << ": ";
        MyPrint(DFA[i]);
        qTemp.pop_front();              // 队列里包括DFA
        for (auto a : xiTa)
        {
            cout << "           T" << FindLoc(qTemp.front()) << " ";
            
            MyPrint(qTemp.front());
            qTemp.pop_front();
        }
        cout << endl;

        for (auto j : Ed)// 判断DFA的终止状态
            if (DFA[i].end() != DFA[i].find(j)) { dfaEd.insert(i); break; }
    }


    cout << endl << "DFA的开始状态为: T0" << endl;
    cout << "DFA的终止状态为:";
    for (auto i : dfaEd)
    {
        cout << " T" << i << ',';
    }
    cout << '\b' << " " << endl;
}

int FindLoc(set<int> Q)//DFA确定化后的位置
{
    for (vector<set<int>>::iterator it = DFA_1.begin(); it != DFA_1.end(); it ++)
    {
        if (Q == *it) return it - DFA_1.begin();
    }
}


void MyPrint(set<int> T)
{
    cout << "{";
        for (set<int> :: iterator it = T.begin(); it != T.end(); it++)
            cout << *it << ",";
    cout << '\b' << "}";//<< endl;
}

void MyPrint()
{
    cout << endl << "NFA表示为:" << endl << "--------------------" << endl;
    for (auto a : xiTa) cout << "          " << a;
    cout << "          e(空字符)";
    puts("");

    for (auto s : State)
    {
        cout << s;
        for (auto a : xiTa)
        {
            cout << "          ";
            for (int i = head[s]; i != -1; i = edge[i].next)
            {
                int v = edge[i].v; string A = edge[i].a;
                if (A == a)
                    cout << " " << v;
            }
        }
        cout << "        ";
        for (int i = head[s]; i != -1; i = edge[i].next)
        {
            int v = edge[i].v; string A = edge[i].a;
            if (A == "e")
                cout << " " << v;
        }
        cout << endl;
    }

    cout << "NFA开始状态为:";
    for (auto s : St) cout << s << ',';
    cout << '\b' << " " << endl;

    cout << "结束状态为:";
    for (auto e : Ed) cout << e << ',';
    cout << '\b' << " " << endl;
}


vector<pair<set<int>, int>> segment; // 分割后的状态集合
void SolveMin()// 分割法
{
    set<int> dfaSt;// 非终态
    for (int i = 0; i < DFA_1.size(); i++)
    {
        if (dfaEd.end() == dfaEd.find(i))dfaSt.insert(i);
    }
    segment.push_back({ dfaSt, segment.size() });
    segment.push_back({ dfaEd, segment.size() });
    
    int cnt = 1;
    cout << endl << "分割法最小化过程" << endl << "---------------------" << endl;
    cout << "第" << cnt++ << "次  ";
    MyPrint_Temp(segment);
    for (int i = 0; i < segment.size();)
    {
        if (Segment(segment[i], i))
        {
            i = 0;
            cout << "第" << cnt++ << "次  ";
            MyPrint_Temp(segment);
        }
        else i++;
    }
}

void MyPrint_Temp(vector<pair<set<int>, int>> segment)
{
    for (auto K : segment)
    {
        cout << "{";
        for (auto U : K.first)
            cout << U << ',';
        cout << '\b' << "}      ";
    }
    cout << endl;
}

bool Segment(pair<set<int>, int> se, int i)//分割函数
{
    for (auto a : xiTa)
    {
        unordered_map<int, set<int>> temp;
        for (auto S : se.first)
        {
            int v = Serach(S,a);//状态的转移状态
            int V = Serach(segment, v);// 每个状态的转移状态所在的子集号
            temp[V].insert(S);
        }

        if (temp.size() > 1)// 只有分割了才放入
        {
            //删除原来的子集并且更新子集号
            segment.erase(segment.begin() + i);
            for (int i = 0; i < segment.size(); i ++)
                segment[i].second = i;

            // 将分割的子集加入
            for (auto it = temp.begin(); it != temp.end(); it++)
            {
                segment.push_back({ (*it).second , segment.size() });
            }
            return true;
        }
    }
    return false;
}
int Serach(int S, string s)// 每个状态的转移状态
{
    for (auto K : DFA_2)
    {
        int u = K.first.first; int v = K.first.second; string a = K.second;
        if (S == u && s == a) return v;
    }
    return -1;
}

int Serach(vector<pair<set<int>, int>> segment, int v)// 每个转移状态所在子集号
{
    for (auto K : segment)
    {
        if (K.first.find(v) != K.first.end()) return K.second;
    }
    return -1;//没有找到
}



set<int> dfaMEd;// 最小化后的结束状态
void Simplify(vector<pair<set<int>, int>> &segment)//合并状态
{
    for (auto &K : segment) // 把多余要合并的状态删了
        if (K.first.end() != K.first.find(0))
        {
            K.first.clear(); K.first.insert(0);
        }
        else
        {
            int t = *K.first.begin();//只留一个状态即可
            K.first.clear(); K.first.insert(t);
        }
}

void MyPrint(vector<pair<set<int>, int>> segment)
{
    cout << endl << "DFA最小化的矩阵表示" << endl << "-----------------------------" << endl;

    for (auto a : xiTa) cout << "          " << a;
    puts("");

    for (auto U : segment)
    {
        int i = *U.first.begin();
        cout << "T" << i;
        for (auto a : xiTa)
        {
            for (auto E : DFA_2)// 分割前的状态图
            {
                if (E.first.first == i && E.second == a)
                {
                    cout << "        T" << E.first.second;
                    break;
                }
            }
        }
        cout << endl;

        //结束状态
        if (dfaEd.end() != dfaEd.find(i)) dfaMEd.insert(i);
    }

    cout << endl << "DFA最小化的开始状态为:T0" << endl;
    cout << endl << "DFA最小化的终止状态为:";
    for (auto k : dfaMEd) cout << " T" << k << ',';
    cout << '\b' << " " << endl;
}


int main()
{
    // 确定化
    init();

    MyPrint(); // 打印NFA

    E_Closure(); // 求初始状态的E_Closure

    Solve();// 子集法求DFA

    MyPrint(DFA_1); // 矩阵打印DFA

    //最小化
    SolveMin(); //分割

    Simplify(segment); //状态合并

    MyPrint(segment);
    return 0;
}