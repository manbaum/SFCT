(** * 基础知识: Coq中的函数式编程 *)

(*
   [Admitted]是Coq的"紧急出口"，就是说接受一个定义而暂不证明。我们用它
   来代表学习过程中的'空白'，这些空白应该由你的作业练习来补上。在实际
   运用中，当你一步步地完成一个大型证明时[Admitted]也非常有用。 *)
Definition admit {T: Type} : T.  Admitted.

(* ###################################################################### *)
(** * 简介 *)

(** 函数式编程风格使得编程更接近简单的、日常的数学：当一个过程或方法
    没有副作用，那么所有你需要去理解的也就是如何将输入对应到输出而已
    —— 或者说，你可以把它当做是一个用来计算数学函数的具体方法。这也就是
    "函数式编程"中"函数式"一词的含义之一。程序与简单数学对象之间的关联
    同时支撑了有关程序行为正确性的形式化证明以及非形式化合理论证。
    
    函数式编程中'函数式'一词的另一个含义是它强调把函数(或方法)作为
    第一等的值 —— 换言之，这个值可以作为参数传递给其他函数，可以作为
    结果返回，也可以存储在数据结构中，等等。这种把函数当做数据的认可
    形式使得很多既有用且强大的用法成为可能。
    
    其他一些常见的函数式语言的特性包括 _代数数据类型_ 和 _模式匹配_
    (使得构造和处理更丰富的数据结构更简单)，以及复杂的 _多态类型系统_
    (用来支持抽象和代码复用)。Coq提供所有这些特性。
    
    这一章的前半部分介绍了Coq函数式编程语言的最基本的元素，后半部分
    介绍了可被用于证明Coq程序一些简单特点的基本策略。 *)

(* ###################################################################### *)
(** * 可枚举类型 *)

(** Coq一个不寻常的地方就是它内置的特性集合 _极其_ 之小。比如，Coq不提供
    通常的原子数据类型(如布尔值、整数、字符串等等)，而是提供一种极其强大的
    可从头定义新数据类型的机制 —— 强大到以上这些常见的类型都是它定义产生出的
    实例。

    当然，Coq发行版也同时提供了一个内容丰富的标准库，包含了布尔值、数值，
    以及如列表、杂凑表等很多常用的数据结构。但是这些库中的定义并没有
    任何地方特殊或者是语言里原生的：它们都是普普通通的用户代码。为了说明
    这个，我们在整个教程里显式的重新定义了所有我们所需要的数据类型，
    而不是隐式的使用库里那些。

    来看看这个机制是如何工作的，让我们从一个非常简单的例子开始。 *)

(* ###################################################################### *)
(** ** 一周里的日子 *)

(** 下面的声明形式告诉Coq我们在定义一个新的数值集合 —— 一个类型。 *)

Inductive day : Type :=
  | monday : day
  | tuesday : day
  | wednesday : day
  | thursday : day
  | friday : day
  | saturday : day
  | sunday : day.

(** 这个类型叫做[day], 它的成员包括[monday]、[tuesday]等等。定义从第二行起，
    包括后面的行，可以被读作"[monday]是一个[day]"，"[tuesday]是一个[day]"，以此类推。

    在定义了[day]类型以后, 我们就可以来写一些函数操作day了. *)

Definition next_weekday (d:day) : day :=
  match d with
  | monday    => tuesday
  | tuesday   => wednesday
  | wednesday => thursday
  | thursday  => friday
  | friday    => monday
  | saturday  => monday
  | sunday    => monday
  end.

(** 注意，这里函数的参数以及返回值是被显式声明的。其实像大多数函数式
    编程语言一样，如果没有显式给出，Coq自己通常也可以得出这些类型
    —— 也就是说，它会做一些 _类型推断_ —— 但这里我们都会声明它们，
    这样可使得阅读起来方便些。*)
    
(** 在定义完函数后，我们用一些例子来检验它。实际上，在Coq中可以用三种
    不同方式来做这件事。
    
    第一，我们可以用命令[Compute]来计算一个包含[next_weekday]的合成表达式。*)

Compute (next_weekday friday).
   (* ==> monday : day *)
Compute (next_weekday (next_weekday saturday)).
   (* ==> tuesday : day *)

(** 如果你手边就有电脑，那现在是一个好机会来打开Coq解释器并选用一个你
    喜欢的IDE —— CoqIde 或是 Proof General 都可以 —— 然后自己试一试。
    从这本书附带的Coq源码中载入[Basics.v]文件，找到上述例子，提交到Coq，
    然后查看结果。*)

(** 第二，我们可以用Coq例子的形式来记录我们所期望的结果是什么： *)

Example test_next_weekday:
  (next_weekday (next_weekday saturday)) = tuesday.

(** 这个声明形式做了两件事：一是它做了一个断言(即：[saturday]之后的
    第二个工作日是[tuesday])；二是它给这个断言起了个名字，以便于以后
    用此名字来引用此断言。*)
(** 定义好断言后，我们还能要求Coq来验证它，像这样：*)

Proof. simpl. reflexivity.  Qed.

(** 在这里一些细节不重要(后面我们还会回顾它)，重要的是这可以是说
    "进行一些化简后，通过观察等式两边计算得到相同的东西，我们刚刚给出的
    断言就可以被验证了。"*)

(** 第三，我们可以让Coq从我们的[Definition]中 _提炼出_ 一个其他编程
    语言(诸如OCaml、Scheme、Haskell等)的程序，这些语言有着高性能的
    编译器。这个能力非常有用，因为它能够提供给我们一种使用主流编程语言来
    构造 _经过充分验证的_ 程序的方式。实际上，这也是Coq被开发出来以后
    最主要的一种使用方式。后面的章节我们会再回来说这个内容。更多内容
    可以在Bertot和Casteran编写的Coq's Art一书中找到，或者是Coq参考手册。*)


(* ###################################################################### *)
(** ** 布尔值 *)

(** 用类似的方式，我们可以定义标准类型[bool]表示布尔值，它包含
    [true]和[false]两个成员。*)

Inductive bool : Type :=
  | true : bool
  | false : bool.

(** 尽管我们为了所谓"一切从头来"而在这里搞出我们自己的布尔类型，实际上，
    Coq在其标准库中也提供了布尔类型的缺省实现，同时提供大量有用的函数和
    定理。(有兴趣的话可参见Coq库文档中的[Coq.Init.Datatypes]。)尽可能地，
    我们会将我们自己的定义和定理的命名做成与标准库中的命名完全一致。*)

(** 布尔值上的函数可用与上文相同的方式来定义：*)

Definition negb (b:bool) : bool := 
  match b with
  | true => false
  | false => true
  end.

Definition andb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => b2 
  | false => false
  end.

Definition orb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => true
  | false => b2
  end.

(** 后面两个演示了具有多个参数的函数的定义语法。*)

(** 下面四个"单元测试"构成了针对[orb]函数的完整规范 —— 真值表：*)

Example test_orb1:  (orb true  false) = true. 
Proof. simpl. reflexivity.  Qed.
Example test_orb2:  (orb false false) = false.
Proof. simpl. reflexivity.  Qed.
Example test_orb3:  (orb false true)  = true.
Proof. simpl. reflexivity.  Qed.
Example test_orb4:  (orb true  true)  = true.
Proof. simpl. reflexivity.  Qed.

(** _关于标记方式的说明_ ：在.v文件里，我们用方括号来界定注释中的
    Coq代码片段；这种习惯，也用于[coqdoc]文档工具里，这使得代码与其
    左右的文字在视觉上分离开。在HTML版的文件里，这部分文字会以
    [不同字体]的形式出现。 *)

(** 文字[Admitted]和[admit]被用来填充不完整的定义或证明。在后续的
    例子中我们就会用到。通常，你的练习作业就是将[Admitted]和[admit]
    替换为实际的定义和证明。 *)

(** **** 练习：1星级 (nandb)  *)
(** 完成以下函数的定义，并确保下列[Example]中的断言每一个都能被
    Coq验证通过。 *)

(** 当其中一个输入或两个输入都为[false]时，下面的函数返回[true]。 *)

Definition nandb (b1:bool) (b2:bool) : bool :=
  (* 请补充 *) admit.

(** 删除"[Admitted.]"并且在以下每一个证明中填写 
    "[Proof. simpl. reflexivity. Qed.]" *)

Example test_nandb1:               (nandb true false) = true.
(* 请补充 *) Admitted.
Example test_nandb2:               (nandb false false) = true.
(* 请补充 *) Admitted.
Example test_nandb3:               (nandb false true) = true.
(* 请补充 *) Admitted.
Example test_nandb4:               (nandb true true) = false.
(* 请补充 *) Admitted.
(** [] *)

(** **** 练习: 1星级 (andb3)  *)
(** 与前面的做法一样来完成下面的[andb3]函数。此函数应该在其所有
    输入都为[true]时返回[true]，否则返回[false]。*)

Definition andb3 (b1:bool) (b2:bool) (b3:bool) : bool :=
  (* 请补充 *) admit.

Example test_andb31:                 (andb3 true true true) = true.
(* 请补充 *) Admitted.
Example test_andb32:                 (andb3 false true true) = false.
(* 请补充 *) Admitted.
Example test_andb33:                 (andb3 true false true) = false.
(* 请补充 *) Admitted.
Example test_andb34:                 (andb3 true true false) = false.
(* 请补充 *) Admitted.
(** [] *)

(* ###################################################################### *)
(** ** 函数类型 *)

(** [Check]命令让Coq显示一个表达式的类型。比如：
    [negb true]的类型是[bool]。*)

Check true.
(* ===> true : bool *)
Check (negb true).
(* ===> negb true : bool *)

(** 像[negb]这样的函数其本身也是数据值，就像[true]和[false]一样。
    它们的类型被称为 _函数类型_，而且表示为箭头。*)

Check negb.
(* ===> negb : bool -> bool *)

(** [negb]的类型，写为[bool -> bool]，读做"[bool]箭头[bool]"，
    可被看做是"给定一个[bool]类型的输入，此函数产生一个[bool]类型的输出。"
    同样的，[andb]的类型，写为[bool -> bool -> bool]，可被看做是
    "给定两个输入，都是[bool]类型，此函数产生一个[bool]类型的输出。"*)

(* ###################################################################### *)
(** ** 数 *)

(** _技术题外话_：Coq提供了相当复杂的 _模块系统_，以帮助组织大型开发。
    在本教程里，我们不打算使用太多这方面的特性，但是其中有一样非常有用：
    如果我们将一组定义放在[Module X]和[End X]标记之间，那么，在文件中
    [End]之后的地方，这些定义需要用像[X.foo]形式的名字来引用，而不能
    仅仅用[foo]。这里，我们用此特性在一个内部模块中引入[nat]类型的定义，
    这样就不会导致标准库中的同名定义被覆盖。*)

Module Playground1.

(** 至此为止我们所定义的所有类型，都是"可枚举类型"的例子：这些定义都是
    显式的列举出一个有限集合中的元素。更有意思的定义类型的一种方式是
    通过一组"归纳性规则"来描述其元素。比如，我们可以对自然数做如下定义：*)

Inductive nat : Type :=
  | O : nat
  | S : nat -> nat.

(** 此定义中的句子可以被看做是：
      - [O]是一个自然数（注意这里是字母"[O]"，不是数字"[0]"）。
      - [S]是一个构造器，取一个自然数而生成另一个 —— 也就是说，
        如果[n]是一个自然数，那么[S n]也是。

    让我们来更详细的看看这个定义。

    所有可归纳式定义的集合([day]、[nat]、 [bool]等等)实际上都是
    _表达式_ 的集合。[nat]的定义说明了集合[nat]中的表达式是如何被构造的。

    - 表达式[O]属于集合[nat]；
    - 如果[n]是属于集合[nat]的表达式，那么[S n]也是属于集合[nat]的表达式；并且，
    - 只有这两种方式形成的表达式才属于集合[nat]。

    同样的规则也适用于[day]和[bool]的定义。对于它们的构造器我们使用的标记
    形式类似于[O]构造器，表示这些构造器都不接收任何参数。*)

(** 以上三个条件是形成[归纳式]声明的主要推动力。它们暗示着表达式[O]、
    表达式[S O]、表达式[S (S O)]、表达式[ S (S (S O))]，等等等等都属于集合[nat]，
    而像[true]、[andb true false]、[S (S false)]的表达式都不属于。

    我们可以编写简单的函数对如前所述的自然数进行模式匹配 —— 比如，前趋函数：*)

Definition pred (n : nat) : nat :=
  match n with
    | O => O
    | S n' => n'
  end.

(** 第二个分支可以被看做是："如果[n]对于某个[n']有[S n']的形式，
    那么返回[n']。"*)

End Playground1.

Definition minustwo (n : nat) : nat :=
  match n with
    | O => O
    | S O => O
    | S (S n') => n'
  end.

(** 由于自然数被使用的非常普遍，Coq对自然数进行词法分析和输出时搞了点小魔术：
    一般的阿拉伯数字被看做是对[S]和[O]构造器所定义的"一进制"自然数表示法的替代品，
    Coq在缺省情况下也把自然数输出为阿拉伯数字形式。*)

Check (S (S (S (S O)))).
Compute (minustwo 4).

(** 构造器[S]具有类型[nat -> nat]，如同函数[minustwo]和[pred]：*)

Check S.
Check pred.
Check minustwo.

(** 以上所有这些都是作用在一个数上面并产生另一个数，但其中有个重要区别：
    像[pred]和[minustwo]这样的函数带有 _计算规则_ —— 也就是说，
    [pred]的定义意思是[pred 2]可被简化为[1] —— 然而[S]的定义却没有
    附带这种计算行为。尽管它看上去像是一个函数作用到一个参数上的感觉，
    但它完全没有 _执行_ 任何计算。*)

(** 对于定义在数上的大部分函数来说，单纯的模式匹配是不够的：
    还需要递归。比如，想要判断一个数[n]偶数，我们需要递归的判断
    [n-2]是偶数。为了写出这样的函数，可以使用[Fixpoint]关键字。*)

Fixpoint evenb (n:nat) : bool :=
  match n with
  | O        => true
  | S O      => false
  | S (S n') => evenb n'
  end.

(** 我们可以使用类似的[Fixpoint]声明来定义[odd]函数，但有个更简单的
    定义能让我们做起来更容易：*)

Definition oddb (n:nat) : bool   :=   negb (evenb n).

Example test_oddb1:    (oddb (S O)) = true.
Proof. simpl. reflexivity.  Qed.
Example test_oddb2:    (oddb (S (S (S (S O))))) = false.
Proof. simpl. reflexivity.  Qed.

(** 当然，我们也能用递归定义具有多个参数的函数。(这里我们还是用模块
    来防止污染名字空间。)*)

Module Playground2.

Fixpoint plus (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus n' m)
  end.

(** 将三加到二上会得到五，就如我们所期望的。*)

Compute (plus (S (S (S O))) (S (S O))).

(** 为得出此结论，Coq所执行的化简步骤如下所示：*)

(*  [plus (S (S (S O))) (S (S O))]    
==> [S (plus (S (S O)) (S (S O)))] 使用第二个[match]子句
==> [S (S (plus (S O) (S (S O))))] 使用第二个[match]子句
==> [S (S (S (plus O (S (S O)))))] 使用第二个[match]子句
==> [S (S (S (S (S O))))]          使用第一个[match]子句
*)

(** 为了书写方便，如果两个或更多参数具有相同的类型，可以写在一起。
    下面的定义里，[(n m : nat)]表示与写成[(n : nat) (m : nat)]相同的意思。*)

Fixpoint mult (n m : nat) : nat :=
  match n with
    | O => O
    | S n' => plus m (mult n' m)
  end.

Example test_mult1: (mult 3 3) = 9.
Proof. simpl. reflexivity.  Qed.

(** 你可以通过在两个表达式之间添加一个逗号来同时匹配两个表达式：*)

Fixpoint minus (n m:nat) : nat :=
  match n, m with
  | O   , _    => O
  | S _ , O    => n
  | S n', S m' => minus n' m'
  end.

(** 第一行里的 _ 是一个 _通配符_。在模式中使用 _ 就如同写一个变量但在
    匹配的右端不使用该变量。这可以防止不得不去声明一些无用变量名。*)

End Playground2.

Fixpoint exp (base power : nat) : nat :=
  match power with
    | O => S O
    | S p => mult base (exp base p)
  end.

(** **** 练习: 1 星级 (factorial)  *)
(** 回想一下标准的阶乘函数：
<<
    factorial(0)  =  1 
    factorial(n)  =  n * factorial(n-1)     (if n>0)
>>
    把它翻译成Coq语言。*)

Fixpoint factorial (n:nat) : nat := 
(* 请补充 *) admit.

Example test_factorial1:          (factorial 3) = 6.
(* 请补充 *) Admitted.
Example test_factorial2:          (factorial 5) = (mult 10 12).
(* 请补充 *) Admitted.

(** [] *)

(** 我们可以通过引入加法、乘法和减法的"表示法"以使得数字表达式更易读一些。*)

Notation "x + y" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x - y" := (minus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x * y" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.

Check ((0 + 1) + 1).

(** ([level]、[associativity]和[nat_scope]标记控制了Coq语法分析器如何处理
    上述表示法。细节不重要，有兴趣的读者可以参考本章末尾"进阶资料"部分
    中的"关于表示法的更多内容"一节。) *)

(** 注意，这些并不会影响我们以前已经定义的那些：它们只是指导Coq语法分析器
    接受用[x + y]来代替[plus x y]，另外反过来，在Coq美化输出时将[plus x y]
    显示为[x + y]。*)

(** 我们说Coq不包含任何内置定义时，我们实际上是指：甚至像数值的相等性测试
    也是用户定义的操作！*)
(** [beq_nat]函数测试[nat]自然数的[eq]相等性，返回一个[b]布尔值。
    注意嵌套匹配[match]的使用(我们也可以使用同时匹配，与[minus]中的做法一样)。*)

Fixpoint beq_nat (n m : nat) : bool :=
  match n with
  | O => match m with
         | O => true
         | S m' => false
         end
  | S n' => match m with
            | O => false
            | S m' => beq_nat n' m'
            end
  end.

(** 类似的，[ble_nat]函数测试[nat]自然数的小于[l]或等于[e]，返回一个[b]布尔值。*)

Fixpoint ble_nat (n m : nat) : bool :=
  match n with
  | O => true
  | S n' =>
      match m with
      | O => false
      | S m' => ble_nat n' m'
      end
  end.

Example test_ble_nat1:             (ble_nat 2 2) = true.
Proof. simpl. reflexivity.  Qed.
Example test_ble_nat2:             (ble_nat 2 4) = true.
Proof. simpl. reflexivity.  Qed.
Example test_ble_nat3:             (ble_nat 4 2) = false.
Proof. simpl. reflexivity.  Qed.

(** **** 练习: 2 星级 (blt_nat)  *)
(** [blt_nat]函数测试[nat]自然数的小于[lt]，产生一个[b]布尔值。
    这次不必完全重新定义一个[Fixpoint]，可以利用前面已经定义的函数来定义。*)

Definition blt_nat (n m : nat) : bool :=
  (* 请补充 *) admit.

Example test_blt_nat1:             (blt_nat 2 2) = false.
(* 请补充 *) Admitted.
Example test_blt_nat2:             (blt_nat 2 4) = true.
(* 请补充 *) Admitted.
Example test_blt_nat3:             (blt_nat 4 2) = false.
(* 请补充 *) Admitted.

(** [] *)

(* ###################################################################### *)
(** * 基于化简的证明 *)

(** 至此我们已经定义了一些数据类型和函数，让我们把问题转到如何表述
    和证明它们行为的特性。实际在某种意义上，我们已经开始做了一些了：
    前面几节里的[Example]就给出了一些函数在一些特定输入上行为的
    准确断言。对于这些断言的证明都一样：使用[simpl]来化简等式两边，
    然后用[reflexivity]来检查两边具有相同的值。
    
    这类"基于化简的证明"还可以用来证明更多有趣的特性。比如，对于[0]出现在左边时
    是加法[+]的"零元"，可通过观察[0 + n]不论[n]值为多少都可化简为[n]而得到证明，
    一个仅需要读一遍[plus]的定义就能得到的事实。*)

Theorem plus_O_n : forall n : nat, 0 + n = n.
Proof.
  intros n. simpl. reflexivity.  Qed.

(** (_注意_：你可能发现上述内容在源文件里和在HTML输出里看上去不太一样。
    在Coq文件里，我们用"_forall_"保留标识符来表示[forall]全称量词。
    显示出来则像倒立的"A"，与在逻辑中使用的符号一样。) *)

(** 这里顺便说一下，[reflexivity]其实要比其字面意思更强大。在前面的例子里，
    对[simpl]的调用完全是不必要的，因为[reflexivity]在检查等式两边是否相等时
    会自动做一些化简；那些增加的[simpl]只是为了解释说明。比如，下面是对
    同一个定理的另一个证明：*)

Theorem plus_O_n' : forall n : nat, 0 + n = n.
Proof.
  intros n. reflexivity. Qed.

(** 事实上，要了解[reflexivity]某种程度上做了比[simpl]更多的化简，这对
    以后很有用 —— 比如，它会尝试"展开"所定义的项，用其定义右端的值替代该项。
    产生这种差别的原因是，当自反性成立时，整个证明目标就完成了，而且
    我们没必要再去看看[reflexivity]展开了什么表达式；与此不同的是，
    [simpl]用于我们必须去观察和理解新产生的证明目标的场景，因此我们不会
    期望它盲目的展开一些定义。*)

(** 我们刚刚声明的定理及其证明与前面例子的基本相同，但也有一些差异。

    首先，我们使用了关键字[Theorem]而不是[Example]。说实话，这种差别
    纯粹是风格而已；在Coq中，关键字[Example]、[Theorem](以及其他一些，
    包括[Lemma]、[Fact]和[Remark])都是表示完全一样的东西。

    其次，我们增加了量词[forall n:nat]，因此我们的定理讨论了_所有的_
    自然数[n]。为了证明这种形式的定理，我们需要能够依据 _假定_ 一个
    任意自然数的存在性来推理。在证明中，这是用[intros n]来实现的，
    它将量词从证明目标移动到当前假设的"上下文"中。达到的效果就是，
    我们说"OK，假设[n]是任意一个自然数"，然后我们开始证明。

    关键字[intros]、[simpl]和[reflexivity]都是_策略_的例子。策略是
    一条可用在[Proof](证明)和[Qed](证明完毕)之间的命令，它告诉Coq
    如何去检查我们所做的一些断言的正确性。在课程的后面部分以及未来的
    讲座里我们会见到更多的策略。

    其他类似的定理可以用相同的模式进行证明。*)

Theorem plus_1_l : forall n:nat, 1 + n = S n. 
Proof.
  intros n. reflexivity.  Qed.

Theorem mult_0_l : forall n:nat, 0 * n = 0.
Proof.
  intros n. reflexivity.  Qed.

(** 上述定理名称的后缀[_l]读作"从左边"。*)

(** 跟进这些证明的每个步骤，观察上下文及证明目标是如何变化的，非常有用。*)
(** 你可能要在[reflexivity]前面增加[simpl]的调用，以观察Coq在检查它们相等前
    做的一些化简。*)

(** 最后，需要说明的是，尽管对于证明一些相当普遍的事实已经非常强大了，
    但是还有很多陈述是无法仅用化简来处理的。比如，可能会有点让人吃惊，
    当[0]出现在[+] _右侧_ 时，用化简就无法证明它是"零元"。*)

Theorem plus_n_O : forall n, n + 0 = n.
Proof.
  intros n. simpl. (* 不起作用！ *)

(** (你能解释这为什么会出现么？在Coq里跟踪两个证明的每一步骤，注意观察
    证明目标和上下文的变化。)

    当在证明过程中卡住时，可以用[Abort]命令来暂时放弃证明。 *)

Abort.

(** 下一章里，我们会用到一种技术来证明这个目标。 *)

(* ###################################################################### *)
(** * 基于改写的证明 *)

(** 下面是一个有趣的定理： *)

Theorem plus_id_example : forall n m:nat,
  n = m -> 
  n + n = m + m.

(** 这个定理没有在自然数[n]和[m]的所有可能值上做全称论断，而是仅仅讨论了
    一个更特定的仅当[n = m]的情况。箭头符号读作"蕴含"。

    和前面一样，我们需要能够在假定自然数[n]和[m]存在性的基础上进行推理。
    另外我们需要假定有前提[n = m]。[intros]策略用来将这三条假设从证明目标
    中移动到当前上下文的假设中。

    由于[n]和[m]是任意自然数，我们无法用化简来证明此定理。相反，我们可以通过
    观察来证明它，如果我们假设了[n = m]，那么我们就可以通过将证明目标中的
    [n]替换成[m]从而获得两边都是相同表达式的等式。用来告诉Coq执行这个替换的
    策略叫做改写[rewrite]。 *)

Proof.
  (* 将两个量词移到上下文中 *)
  intros n m.
  (* 将前提移到上下文中 *)
  intros H.
  (* 用假设改写目标 *)
  rewrite -> H.
  reflexivity.  Qed.

(** 证明的第一行将全称量词变量[n]和[m]移动到上下文中。第二行将假设
    [n = m]移动到上下文中，并将其(随意)命名为[H]。第三行告诉Coq
    改写当前当前目标([n + n = m + m])，把前提[H]等式左边的替换成右边的。

    ([rewrite]里的箭头与蕴含无关：它指示Coq从左往右地应用改写。若要
    从右往左改写，可以使用[rewrite <-]。在上面的证明里试一试这种改变，
    看看Coq的反应有何变化。) *)

(** **** 练习: 1 星级 (plus_id_exercise)  *)
(** 删除 "[Admitted.]" 并补充完整证明。 *)

Theorem plus_id_exercise : forall n m o : nat,
  n = m -> m = o -> n + m = m + o.
Proof.
  (* 请补充 *) Admitted.
(** [] *)

(** 如我们前面看到的例子，[Admitted]命令告诉Coq我们想要跳过此定理的证明而将其
    作为已知条件。这在开发较长的证明时很有用。在进行一些较大的命题论证时，我们
    能够声明一些附加的事实，既然我们认为这些事实是对论证有用的，就可以用[Admitted]
    先不加怀疑的接受这些事实，然后继续思考大命题的论证，直到确认了该命题确实是有意义的，
    在回过头去证明刚才跳过的证明。但是要小心：每次使用[Admitted]或者[admit]，
    你就为进入Coq这个完好、严密、形式化且封闭的世界开了一个毫无道理的后门。 *)

(** 我们还可以使用[rewrite]策略来运用前期已证明过的定理，而不是上下文中的现有前提。*)

Theorem mult_0_plus : forall n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.
  reflexivity.  Qed.

(** **** 练习: 2 星级 (mult_S_1)  *)
Theorem mult_S_1 : forall n m : nat,
  m = S n -> 
  m * (1 + n) = m * m.
Proof.
  (* 请补充 *) Admitted.
(** [] *)


(* ###################################################################### *)
(** * 利用案例分析来证明 *) 

(** 当然，并不是一切都是可以通过简单的计算来证明的：通常，一些未知的、假定值(数值、
    布尔值、列表等等)会阻碍计算求值。比如，我们如果像以前一样使用[simpl]策略尝试
    证明下面的事实，我们会被卡住。 *)

Theorem plus_1_neq_0_firsttry : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. 
  simpl.  (* 无能为力! *)
Abort.

(** 原因就是[beq_nat]和[+]的定义都是对它们的第一个参数进行匹配[match]。
    但在这里，[+]的第一个参数是未知数[n]，而[beq_nat]的第一个参数是
    复合表达式[n + 1]，都不能被简化。

    我们需要能够将[n]可能的形式分开来进行考虑。如果[n]是[0]，那么
    我们可以计算[beq_nat (n + 1) 0]的最终结果并且验证，实际上是[false]。
    而如果相对于某个[n']有[n = S n']，那么，尽管我们无法确切地知道
    [n + 1]得到的数字是几，但我们可以做计算，至少它应该以[S]打头，
    这对于计算已经足够了，同样[beq_nat (n + 1) 0]会得到[false]。

    告诉Coq根据情况[n = 0]和[n = S n']来分开考虑的策略，叫做[destruct]。 *)

Theorem plus_1_neq_0 : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. destruct n as [| n'].
  - reflexivity.
  - reflexivity.  Qed.

(** [destruct]会生成_两个_子目标，这两个目标我们需要分别进行证明，
    然后才能让Coq接受此定理是已证明的。记法"[as [| n']]"叫做
    _引入模板_，用来告诉Coq在每个子目标中引入的变量名是什么。
    通常，在方括号内是一组名字列表的_列表_，中间用[|]分割。这里，
    列表的第一个成员是空，是因为[0]的构造器是零元的(不包含任何参数)。
    第二个成员给出了一个名字[n']，是因为[S]是一元构造器。

    第二和第三行中的[-]符号是_标号_，分隔了分别对应各自子目标的证明部分。
    标号后面的代码是一个子目标的完整证明。在整个例子中，每个子目标
    都被使用[reflexivity]简单地完成证明，通常[reflexivity]本身执行了一些
    化简操作。比如，第一个证明里[beq_nat (S n' + 1) 0]被化简成[false]，
    是通过先将[(S n' + 1)]转写成[S (n' + 1)]，然后再展开[beq_nat]，
    然后在化简[match]完成的。

    用标号来标记区分情况完全是可选的：如果标号不存在，Coq只是简单的要求你
    顺序地依次证明每个子目标。尽管如此，使用标号是一个好习惯，这有两个原因。
    首先，它使得一个证明的结构更显而易见，使其更可读。其次，标号指示Coq
    在试图验证下一个目标时去确认上一个子目标已完成，防止不同子目标的证明
    搅和在一起。这一点在大型开发中尤其重要，一些证明片段会导致很耗时的
    排错过程。

    在Coq中证明如何被格式化没有既严格又便捷的规则 —— 尤指一行在哪里
    断行以及证明中的段落如何缩进以显示其嵌套结构。不管怎样，如果那些由多个
    子目标生成的地方显式地在每行起始处标以标号，那么证明会有很好的可读性，
    不论格式布局的其他方面是被如何选择的。

    这里也很应该提到另一个(貌似很显然)关于代码的每行长度的建议。
    Coq的初学者有时会爱走极端，要么一行只一个策略语句，要么把整个证明
    写在一行里。更好的风格则是在乎两者之间。特别要说的是，一个合理的
    习惯是给你自己一个每行80个字符的限制。比这个长的行会很难读也不便于
    显示及打印。很多编辑器具有功能帮助你做到这个。

    [destruct]策略可以用于任何归纳定义的数据类型。比如，用在这里证明
    布尔值的取反是对合的 —— 即，取反是自身的逆运算。 *)

Theorem negb_involutive : forall b : bool,
  negb (negb b) = b.
Proof.
  intros b. destruct b.
  - reflexivity.
  - reflexivity.  Qed.

(** 注意这里的[destruct]没有[as]子句，因为[destruct]生成的子情况没有一个
    需要绑定任何变量，因此也就不需要指定名字。(我们也可以写成[as [|]]或者
    [as []]。) 实际上，我们也可以省略_任何_[destruct]中的[as]子句，Coq会
    自动填上变量名称。尽管这很方便，但这是个坏习惯，是因为如果任其自由的话
    Coq经常做一些令人容易混淆的名字选择。

    也可以在一个子目标内调用[destruct]，产生出更多的证明目标。这时候，
    我们使用不同的标号来标记目标的不同"层级"，比如： *)

Theorem andb_commutative : forall b c, andb b c = andb c b.
Proof.
  intros b c. destruct b.
  - destruct c.
    + reflexivity.
    + reflexivity.
  - destruct c.
    + reflexivity.
    + reflexivity.
Qed.

(** 这里，每一对[reflexivity]调用对应了紧邻其上的[destruct]行执行后所生成的
    子目标。用[+]而不是[-]来标记这些子目标使得Coq能够区分一个证明里所生成的
    不同层次的子目标，使得其更鲁棒。除了[-]和[+]，Coq证明还可以使用[*]作为
    第三种标号。如果我们遇到一个证明生成了超过三层的子目标，那可以用花括号将
    每个子目标括起来([{ ... }])： *)

Theorem andb_commutative' : forall b c, andb b c = andb c b.
Proof.
  intros b c. destruct b.
  { destruct c.
    { reflexivity. }
    { reflexivity. } }
  { destruct c.
    { reflexivity. }
    { reflexivity. } }
Qed.

(** 由于花括号同时标识了证明的开始和结束，因此它们可同时用在不同的子目标层级，
    如上例所述。进一步地，花括号允许我们在一个证明中在多个层级下使用同一个标号： *)

Theorem andb3_exchange :
  forall b c d, andb (andb b c) d = andb (andb b d) c.
Proof.
  intros b c d. destruct b.
  - destruct c.
    { destruct d.
      - reflexivity.
      - reflexivity. }
    { destruct d.
      - reflexivity.
      - reflexivity. }
  - destruct c.
    { destruct d.
      - reflexivity.
      - reflexivity. }
    { destruct d.
      - reflexivity.
      - reflexivity. }
Qed.

(** **** 练习: 2 星级 (andb_true_elim2)  *)
(** 证明 [andb_true_elim2], 在使用[destruct]后用标号表示情况(及子情况)。 *)

Theorem andb_true_elim2 : forall b c : bool,
  andb b c = true -> c = true.
Proof.
  (* 请补充 *) Admitted.
(** [] *)

(** **** 练习: 1 星级 (zero_nbeq_plus_1)  *)
Theorem zero_nbeq_plus_1 : forall n : nat,
  beq_nat 0 (n + 1) = false.
Proof.
  (* 请补充 *) Admitted.

(** [] *)

(* ###################################################################### *)
(** * 更多练习 *)

(** **** 练习: 2 星级 (boolean_functions)  *)
(** 用你已经学过的策略证明以下关于布尔函数的定理。 *)

Theorem identity_fn_applied_twice : 
  forall (f : bool -> bool), 
  (forall (x : bool), f x = x) ->
  forall (b : bool), f (f b) = b.
Proof.
  (* 请补充 *) Admitted.

(** 现在声明并证明定理[negation_fn_applied_twice]，与上一个类似，但是
    第二个假设是说函数[f]有[f x = negb x]的性质。 *)

(* 请补充 *)
(** [] *)

(** **** 练习: 2 星级 (andb_eq_orb)  *)
(** 证明下列定理。(你有可能需要先证明一到两个辅助引理。或者，你要记住
    并非要同时引入所有假设。) *)

Theorem andb_eq_orb : 
  forall (b c : bool),
  (andb b c = orb b c) ->
  b = c.
Proof.
  (* 请补充 *) Admitted.
(** [] *)

(** **** 练习: 3 星级 (binary)  *)
(** 设想一种不同的、更有效的表示自然数的方法，使用二进制，而不是一进制。
    换言之，并非说每个自然数是零或者另一个自然数的后继，我们可以说每个
    自然数：

      - 要么是零，
      - 要么是一个二进制数的两倍，
      - 要么比一个二进制数的两倍还多一。

    (a) 首先，写出对应上述二进制数类型的归纳定义。 

    (提示：回想一下[nat]的定义，
    Inductive nat : Type :=
      | O : nat
      | S : nat -> nat.
    它并没有说出[O]和[S]的"含义"。它只是说"[O]是在被称之为[nat]的集合中，
    而且，如果[n]在集合中那么[S n]也在集合中。" 把[O]解释为零以及把[S]
    定义为后继或者加一运算，是因为我们按这种方式去"使用"了[nat]的值而已。
    我们写出函数来计算它们，证明与之相关的东西，等等。你的[bin]的定义
    应该相对简单，下一步你写出的函数才会给出它的数学含义。)

    (b) 进一步地，为二进制数写出自增函数[incr]，并且写出函数[bin_to_nat]
        来将二进制数转换成一进制数。

    (c) 针对你写出的自增函数和二进制-一进制转换函数，写5个单元测试，
        如[test_bin_incr1], [test_bin_incr2], 等等。注意，将一个二进制数
        先自增再转换为一进制数，应该与将其先转换成一进制后再自增获得的结果相同。
*)

(* 请补充 *)
(** [] *)

(* ###################################################################### *)
(** * 关于表示法的更多内容 (高级) *)

(** 通常，标记着高级的部分对于跟进本书其他部分的学习来说不是必须的，
    除了那些也标记为高级的部分。在初次阅读时，你可以快速浏览这些部分，
    以便于使你在未来遇到时知道这里有些什么。 *)

Notation "x + y" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x * y" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.

(** 对于Coq中的每个表示法符号，我们可以指定它的_优先级_和_结合性_。
    优先级[n]用[at level n]来表示；这将有助于Coq分析复合表达式。
    结合性的设置有助于消除有相同符号多次出现的表达式的歧义。比如，
    上面这组对于[+]和[*]的参数定义了表达式[1+2*3*4]是[(1+((2*3)*4))]的
    简写。Coq使用0到100的优先级等级，同时支持左结合(left)、右结合(right)
    和不结合(no)的结合性。

    每个表示法符合还与_表示法范围_相关。Coq会尝试根据上下文来猜测
    你所指的范围，因此当你写出[S(0*0)]时，它猜测是[nat_scope]；而当你
    写出笛卡尔积(元组)类型[bool*bool]时，它猜测是[type_scope]。
    有时你可能不得不用百分号表示法写出[(x*y)%nat]来帮助Coq确定范围，
    另外，有时Coq对你的反馈中也包含[%nat]用来指示表示法所在的范围是什么。

    表示法范围同样适用与数字表示([3]、[4]、[5]等等)，因此你有时候会看到
    [0%nat]，表示[0](我们在本章中使用的自然数零[0])，而[0%Z]表示整数零
    (来自于标准库中的里的另一个部分)。 *)

(** * 不动点[Fixpoint]以及结构化递归 (高级) *)

Fixpoint plus' (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus' n' m)
  end.

(** 当Coq查看此定义时，它会意识到[plus']是"在其第一个参数上递减"。
    这意味着我们在参数[n]上执行了_结构化递归_。换言之，我们在进行
    递归调用时仅对严格减小了的[n]值。这隐含说明了对[plus']的调用
    最终会停止。Coq要求每个[Fixpoint]定义中的某些参数必须是"递减的"。

    这项要求是Coq设计的根本特性之一：尤其是，它保证了能在Coq中定义的
    所有函数对于各种输出都会计算结束。然而，由于Coq的"递减分析"不是非常
    精致，在编写函数时有时不得不需要一点点不同寻常。 *)

(** **** 练习: 2 星级, 可选做 (递减)  *)
(** 为了能对此有更具体的认识，找出一个方式写出有效的[Fixpoint]定义
    (比如有关数字的简单函数)，在各种的输入下_确实_能够终止，但是Coq却
    由于此限制而拒绝接受。 *)

(* 请补充 *)
(** [] *)

(** $Date$ *)

