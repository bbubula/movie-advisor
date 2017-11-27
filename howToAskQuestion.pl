askYesNoQuestion(Question) :-
    jpl_call('javax.swing.JOptionPane','showConfirmDialog',[(@null),Question,'Question',0],X),
    ((X == 0) -> write('YES');
    (X == 1) -> write('NO');
    (write("\nInavlid input, once again...\n"))).

askQuestion(Question) :-
    jpl_call('javax.swing.JOptionPane','showInputDialog',[(@null),Question,'Question',3],X),
    write('your answer: '),
    write(X).