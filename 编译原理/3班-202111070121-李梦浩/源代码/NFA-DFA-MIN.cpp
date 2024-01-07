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

vector<string> xiTa;//��ĸ��
int k, st, ed;//״̬�����Ϳ�ʼ״̬
vector<int> State;//״̬�ڵ�
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

    cout << "������״̬���� �� ��ʼ״̬���� �Լ� ����״̬����" << endl;
    cin >> k >> st >> ed;
    cout << "������״̬�ı��:" << endl;
    for (int i = 0; i < k; i++) { int s; cin >> s; State.push_back(s); }
    cout << "�����뿪ʼ״̬" << endl;
    for (int i = 0; i < st; i++) { int s; cin >> s; St.insert(s); }
    cout << "���������״̬" << endl;
    for (int i = 0; i < ed; i++) { int s; cin >> s; Ed.insert(s); }

    cout << "��������ĸ�����(�� e ��)" << endl;
    cin >> m;

    cout << "��������ĸ����ĸ" << endl;
    for (int i = 0; i < m; i++)
    {
        string a; cin >> a;
        xiTa.push_back(a);
    }
    cout << "������״̬ת����, ��ʽΪ(��ǰ״̬ ������� ���״̬), �� 0 e 0 ����, ���� e ��ʾ�շ���" << endl;
    int d, h; string a;
    while (cin >> d >> a >> h && !(d == 0 && a == "e" && h == 0))
    {
        AddEdge(d, a, h);
    }
}

void E_Closure()
{
    bool vis[N];
    cout << endl << "---------------------" << endl << "NFA״̬��E_Closure����:" << endl;
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
        cout << i << " ��E_ClosureΪ: ";
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
deque<set<int>> qTemp;// ״̬ȷ��, ��MyPrint������
vector<pair<PII, string>> DFA_2;// DFA�ı�
void Solve()//�Ӽ�������DFA
{
    
    DFA_1.push_back(E_Closure(St));//��K0��e-closure���뼯��DFA

    int cnt = 0;
    while (cnt < DFA_1.size())
    {
        auto temp = DFA_1[cnt];
        qTemp.push_back(temp); // �����Ժ��������
        for (auto a : xiTa)
        {
            set<int> U;
            U = Move(temp, a);
            U = E_Closure(U);
            qTemp.push_back(U); // �����Ժ����;
            
            if (find(DFA_1, U) == -1)
            {
                DFA_1.push_back(U);
            }
            int location = find(DFA_1, U);// �ȷ�����location�������Ϊ -1;
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


set<int> dfaEd;// ȷ������dfa����ֹ״̬
void MyPrint(vector<set<int>> DFA)
{
    cout << endl << "DFA�����ʾ" << endl << "-----------------------------" << endl;

    for (auto a : xiTa) cout << "                          " << a;
    puts("");


    for (int i = 0; i < DFA.size(); i++)
    {
        cout << 'T' << i << ": ";
        MyPrint(DFA[i]);
        qTemp.pop_front();              // ���������DFA
        for (auto a : xiTa)
        {
            cout << "           T" << FindLoc(qTemp.front()) << " ";
            
            MyPrint(qTemp.front());
            qTemp.pop_front();
        }
        cout << endl;

        for (auto j : Ed)// �ж�DFA����ֹ״̬
            if (DFA[i].end() != DFA[i].find(j)) { dfaEd.insert(i); break; }
    }


    cout << endl << "DFA�Ŀ�ʼ״̬Ϊ: T0" << endl;
    cout << "DFA����ֹ״̬Ϊ:";
    for (auto i : dfaEd)
    {
        cout << " T" << i << ',';
    }
    cout << '\b' << " " << endl;
}

int FindLoc(set<int> Q)//DFAȷ�������λ��
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
    cout << endl << "NFA��ʾΪ:" << endl << "--------------------" << endl;
    for (auto a : xiTa) cout << "          " << a;
    cout << "          e(���ַ�)";
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

    cout << "NFA��ʼ״̬Ϊ:";
    for (auto s : St) cout << s << ',';
    cout << '\b' << " " << endl;

    cout << "����״̬Ϊ:";
    for (auto e : Ed) cout << e << ',';
    cout << '\b' << " " << endl;
}


vector<pair<set<int>, int>> segment; // �ָ���״̬����
void SolveMin()// �ָ
{
    set<int> dfaSt;// ����̬
    for (int i = 0; i < DFA_1.size(); i++)
    {
        if (dfaEd.end() == dfaEd.find(i))dfaSt.insert(i);
    }
    segment.push_back({ dfaSt, segment.size() });
    segment.push_back({ dfaEd, segment.size() });
    
    int cnt = 1;
    cout << endl << "�ָ��С������" << endl << "---------------------" << endl;
    cout << "��" << cnt++ << "��  ";
    MyPrint_Temp(segment);
    for (int i = 0; i < segment.size();)
    {
        if (Segment(segment[i], i))
        {
            i = 0;
            cout << "��" << cnt++ << "��  ";
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

bool Segment(pair<set<int>, int> se, int i)//�ָ��
{
    for (auto a : xiTa)
    {
        unordered_map<int, set<int>> temp;
        for (auto S : se.first)
        {
            int v = Serach(S,a);//״̬��ת��״̬
            int V = Serach(segment, v);// ÿ��״̬��ת��״̬���ڵ��Ӽ���
            temp[V].insert(S);
        }

        if (temp.size() > 1)// ֻ�зָ��˲ŷ���
        {
            //ɾ��ԭ�����Ӽ����Ҹ����Ӽ���
            segment.erase(segment.begin() + i);
            for (int i = 0; i < segment.size(); i ++)
                segment[i].second = i;

            // ���ָ���Ӽ�����
            for (auto it = temp.begin(); it != temp.end(); it++)
            {
                segment.push_back({ (*it).second , segment.size() });
            }
            return true;
        }
    }
    return false;
}
int Serach(int S, string s)// ÿ��״̬��ת��״̬
{
    for (auto K : DFA_2)
    {
        int u = K.first.first; int v = K.first.second; string a = K.second;
        if (S == u && s == a) return v;
    }
    return -1;
}

int Serach(vector<pair<set<int>, int>> segment, int v)// ÿ��ת��״̬�����Ӽ���
{
    for (auto K : segment)
    {
        if (K.first.find(v) != K.first.end()) return K.second;
    }
    return -1;//û���ҵ�
}



set<int> dfaMEd;// ��С����Ľ���״̬
void Simplify(vector<pair<set<int>, int>> &segment)//�ϲ�״̬
{
    for (auto &K : segment) // �Ѷ���Ҫ�ϲ���״̬ɾ��
        if (K.first.end() != K.first.find(0))
        {
            K.first.clear(); K.first.insert(0);
        }
        else
        {
            int t = *K.first.begin();//ֻ��һ��״̬����
            K.first.clear(); K.first.insert(t);
        }
}

void MyPrint(vector<pair<set<int>, int>> segment)
{
    cout << endl << "DFA��С���ľ����ʾ" << endl << "-----------------------------" << endl;

    for (auto a : xiTa) cout << "          " << a;
    puts("");

    for (auto U : segment)
    {
        int i = *U.first.begin();
        cout << "T" << i;
        for (auto a : xiTa)
        {
            for (auto E : DFA_2)// �ָ�ǰ��״̬ͼ
            {
                if (E.first.first == i && E.second == a)
                {
                    cout << "        T" << E.first.second;
                    break;
                }
            }
        }
        cout << endl;

        //����״̬
        if (dfaEd.end() != dfaEd.find(i)) dfaMEd.insert(i);
    }

    cout << endl << "DFA��С���Ŀ�ʼ״̬Ϊ:T0" << endl;
    cout << endl << "DFA��С������ֹ״̬Ϊ:";
    for (auto k : dfaMEd) cout << " T" << k << ',';
    cout << '\b' << " " << endl;
}


int main()
{
    // ȷ����
    init();

    MyPrint(); // ��ӡNFA

    E_Closure(); // ���ʼ״̬��E_Closure

    Solve();// �Ӽ�����DFA

    MyPrint(DFA_1); // �����ӡDFA

    //��С��
    SolveMin(); //�ָ�

    Simplify(segment); //״̬�ϲ�

    MyPrint(segment);
    return 0;
}