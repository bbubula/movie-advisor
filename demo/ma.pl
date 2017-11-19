:- ensure_loaded(knowledge_short).

global_movies_count(3).

/* main choose structure */
choose_movie(Description) :- 
    createAcceptableMoviesSet(),
    filterPart(), 
    /**propositionsPart().*/
    ((acceptableMovie(Result), movieHasHumanReadableDescription(Result, Description)); noResultFound(Description)).

noResultFound("No results found. Try again with modified criteria. ;)").

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
rejectMovie(_). /* if already not acceptable */

rejectMovies([]).
rejectMovies([H|Tail]):-
    rejectMovie(H), rejectMovies(Tail).



/* filtering movies set*/
filterPart() :- 
    whichYearsAreAcceptable(),
    whichGenresAreAcceptable().
    /*whatDurationIsAccpetable(),
    whichContinentsAreAcceptable().*/

whichGenresAreAcceptable() :-
    askIfFictionIsPreferred(),
    askIfActionIsPreferred(),
    askIfAmbitiousMovieIsPreferred().
    /*askIfEmotionalMovieIsPreffered(). */

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
    global_movies_count(X), getMoviesWithIncorrectYear(X, ListOfMovies, MinYear, MaxYear).

getMoviesWithIncorrectYear(-1, [], _, _).

getMoviesWithIncorrectYear(Current, [Current|ListOfMovies], MinYear, MaxYear) :- 
    movieCreatedInYear(Current, Year), 
    or(Year < MinYear, Year > MaxYear),
    NewCurrent is Current - 1,
    getMoviesWithIncorrectYear(NewCurrent, ListOfMovies, MinYear, MaxYear).

getMoviesWithIncorrectYear(Current, ListOfMovies, MinYear, MaxYear) :- 
    NewCurrent is Current - 1,
    getMoviesWithIncorrectYear(NewCurrent, ListOfMovies, MinYear, MaxYear).

/* ambitious filter */
askIfAmbitiousMovieIsPreferred() :- 
    write("Do you like ambitious movies ? (y/n)"),
    nl,
    read(X),
    ((X == y ; X == yes) -> ambitiousMoviePreferred(yes);
    (X == n ; X == no) -> ambitiousMoviePreferred(no);
    (write("\nInavlid input, once again...\n")), askIfAmbitiousMovieIsPreferred()).

ambitiousMoviePreferred(no) :-
    rejectMovieOfGenre("Mystery"),
    rejectMovieOfGenre("Drama").

ambitiousMoviePreferred(yes) :-
    rejectMovieOfGenre("Comedy"),
    rejectMovieOfGenre("Family"),
    rejectMovieOfGenre("Animation"),
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi"),
    rejectMovieOfGenre("Musical"),
    rejectMovieOfGenre("Romance"),
    rejectMovieOfGenre("Western").

/* action filter */
askIfActionIsPreferred() :- 
    write("Do you like action movies ? (y/n)"),
    nl,
    read(X),
    ((X == y ; X == yes) -> actionPreferred(yes);
    (X == n ; X == no) -> actionPreferred(no);
    (write("\nInavlid input, once again...\n")), askIfActionIsPreferred()).

actionPreferred(no) :-
    rejectMovieOfGenre("Action"),
    rejectMovieOfGenre("Thriller"),
    rejectMovieOfGenre("Adventure").

actionPreferred(yes) :-
    rejectMovieOfGenre("Documentary"),
    rejectMovieOfGenre("History"). /* todo: verify and extend list */

/* fiction filter */
askIfFictionIsPreferred() :- 
    write("Do you like fiction movies ? (y/n)"),
    nl,
    read(X),
    ((X == y ; X == yes) -> fictionPreferred(yes);
    (X == n ; X == no) -> fictionPreferred(no);
    (write("\nInavlid input, once again...\n")), askIfFictionIsPreferred()).

fictionPreferred(no) :-
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi").

fictionPreferred(yes) :-
    rejectMovieOfGenre("Documentary"),
    rejectMovieOfGenre("History").

/* genre util */
rejectMovieOfGenre(Genre):-
    global_movies_count(X), getMoviesOfGenre(X, MoviesOfGenre, Genre), rejectMovies(MoviesOfGenre).

getMoviesOfGenre(-1, [], _).

getMoviesOfGenre(Current, [Current|ListOfMovies], Genre) :- 
    movieOfGenre(Current, Genre), 
    NewCurrent is Current - 1,
    getMoviesOfGenre(NewCurrent, ListOfMovies, Genre).

getMoviesOfGenre(Current, ListOfMovies, Genre) :- 
    NewCurrent is Current - 1,
    getMoviesOfGenre(NewCurrent, ListOfMovies, Genre).

/* util */
or(A, B) :-
    A; B.