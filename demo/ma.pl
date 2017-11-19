:- ensure_loaded(knowledge_short).

global_movies_count(3).

/* main choose structure */
choose_movie(Description) :- 
    createAcceptableMoviesSet(),
    filterPart(), 
    /**propositionsPart().*/
    acceptableMovie(Result),
    movieHasHumanReadableDescription(Result, Description).

/* creating acceptable movies set */
createAcceptableMoviesSet() :- 
    global_movies_count(X), addMovieToSet(X).

addMovieToSet(-1).
addMovieToSet(Val) :-
    asserta(acceptableMovie(Val)),
    NewVal is Val - 1, 
    addMovieToSet(NewVal).

/* removing movies from acceptable set */

rejectMovie(X):-
    retract(acceptableMovie(X)).

rejectMovies([]).
rejectMovies([H|Tail]):-
    rejectMovie(H), rejectMovies(Tail).



/* filtering movies set*/
filterPart() :- 
    whichYearsAreAcceptable().
    /*whichGenresAreAcceptable(),
    whatDurationIsAccpetable(),
    whichContinentsAreAcceptable().*/

whichGenresAreAcceptable() :-
    askIfFictionIsPreferred(),
    askIfActionIsPreferred(),
    askIfAmbitiousMovieIsPreferred(),
    askIfEmotionalMovieIsPreffered().

/* years filtering */
askForYearRange(MinYear, MaxYear) :- 
    write("Specify years range for movie"),
    nl,
    write("Specify start year"),
    nl,
    read(MinYear),
    nl,
    write("Specify end year"),
    nl,
    read(MaxYear).

whichYearsAreAcceptable() :-
    askForYearRange(MinYear, MaxYear),
    moviesOutsideYearRange(ListOfMovies, MinYear, MaxYear),
    rejectMovies(ListOfMovies).

moviesOutsideYearRange(ListOfMovies, MinYear, MaxYear) :-
    global_movies_count(X), NewX is X - 1, getMoviesWithIncorrectYear(NewX, ListOfMovies, MinYear, MaxYear).

getMoviesWithIncorrectYear(-1, [], _, _).

getMoviesWithIncorrectYear(Current, [Current|ListOfMovies], MinYear, MaxYear) :- 
    movieCreatedInYear(Current, Year), 
    or(Year < MinYear, Year > MaxYear),
    NewCurrent is Current - 1,
    getMoviesWithIncorrectYear(NewCurrent, ListOfMovies, MinYear, MaxYear).

getMoviesWithIncorrectYear(Current, ListOfMovies, MinYear, MaxYear) :- 
    NewCurrent is Current - 1,
    getMoviesWithIncorrectYear(NewCurrent, ListOfMovies, MinYear, MaxYear).

or(A, B) :-
    A; B.

