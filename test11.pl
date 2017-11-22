ask(Question) :-
    open('out.txt', write, Out),
    write(Out, Question),
    flush_output(Out),
    close(Out),

    open('in.txt', write, TmpOut),
    write(TmpOut, "empty."),
    flush_output(TmpOut),
    close(TmpOut),

    read_input(X, Question).


read_input(X, Question) :-
                 open('in.txt', read, In),
                 sleep(3),
                 read(In, X),
                 close(In),
                 checkIfEmpty(X, Question), !.

read_input(X, Question) :-
                open('in.txt', read, In),
                read(In, X),
                close(In),
                checkIfEmpty(X, Question).

checkIfEmpty(X, Question) :-
                   ((X = 'empty') -> read_input(X, Question);
                   (X \= 'empty') -> checkAnswer(X, Question)).

checkAnswer(X, Question) :-
             ((X == y ; X == yes) -> is(y);
              (X == n ; X == no) -> is(n);
              (write("\nInavlid input, once again...\n")),
              atom_concat(Question, '-', N),
               ask(N)).

clearQuestionStream :-
                        write('----------------I have no more questions-----------------'),
                        nl,
                        open('out.txt', write, Out),
                        write(Out, "end"),
                        flush_output(Out),
                        close(Out).

is(y) :-
          write('----------YOU ANSWER YES----------'),
          nl,
          clearQuestionStream().
is(n) :-
         write('----------YOU ANSWER NO----------'),
         nl,
         clearQuestionStream().