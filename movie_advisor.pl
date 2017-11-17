:- ensure_loaded(knowledge_base).

b_setval(global_movies_count,  149700).

/* main choose structure */
choose_movie(Description) :- 
    createAcceptableMoviesSet(),
    filterPart(), 
    propositionsPart().
    /*acceptableMovie(Result),
    movieHasHumanReadableDescription(Result, Description).*/

/* creating acceptable movies set */
createAcceptableMoviesSet() :- 
    b_getval(global_movies_count, X), addMovieToSet(X).

addMovieToSet(Val) :-
    asserta(acceptableMovie(Val)),
    addMovieToSet(Val - 1).

addMovieToSet(-1).

/* removing movies from acceptable set */
rejectMovie(X):-
    retract(acceptableMovie(X)).

rejectMovies([H|Tail]):-
    rejectMovie(H), rejectMovies(Tail).

rejectMovies([]).

/* filtering movies set*/
filterPart() :- 
    whichYearsAreAcceptable(),
    whichGenresAreAcceptable(),
    whatDurationIsAccpetable(),
    whichContinentsAreAcceptable().

whichGenresAreAcceptable() :-
    askIfFictionIsPreferred(),
    askIfActionIsPreferred(),
    askIfAmbitiousMovieIsPreferred(),
    askIfEmotionalMovieIsPreffered().

/* fiction filter */
askIfFictionIsPreferred(no) :-
    askForFiction(),
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi").

askIfFictionIsPreferred(yes) :-
    askForFiction(),
    rejectMovieOfGenre("Documentary"),
    rejectMovieOfGenre("History").

askForFiction() :- 
    write("Do you like fiction movies ? (y/n)"),
    nl,
    read(X),
    ((X == "y" ; X == "yes") -> askIfFictionIsPreferred(yes);
    (X == "n" ; X == "no") -> askIfFictionIsPreferred(no);
    write(‘\nInavlid input\n’),fail).

/* action filter */
askIfActionIsPreferred(no) :-
    askForAction(), 
    rejectMovieOfGenre("Action"),
    rejectMovieOfGenre("Thriller"),
    rejectMovieOfGenre("Adventure").

askIfActionIsPreferred(yes) :-
    askForAction(), 
    rejectMovieOfGenre("Action"),
    rejectMovieOfGenre("Thriller"),
    rejectMovieOfGenre("Adventure").

askForAction :- 
    write("Do you like actions movies ? (y/n)"),
    nl,
    read(X),
    ((X == "y" ; X == "yes") -> askIfActionIsPreferred(yes);
    (X == "n" ; X == "no") -> askIfActionIsPreferred(no);
    write("\nInavlid input\n"),fail).

/* ambitious movies filter */
askIfAmbitiousMovieIsPreferred(no) :-
    askForAmbitious(),
    rejectMovieOfGenre("Mystery"),
    rejectMovieOfGenre("Drama").

askIfAmbitiousMovieIsPreferred(yes) :-
    askForAmbitious(),
    rejectMovieOfGenre("Comedy"),
    rejectMovieOfGenre("Family"),
    rejectMovieOfGenre("Animation"),
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi"),
    rejectMovieOfGenre("Musical"),
    rejectMovieOfGenre("Romance"),
    rejectMovieOfGenre("Western").

askForAmbitious :- 
    write("Do you like ambitious movies ? (y/n)"),
    nl,
    read(X),
    ((X == "y" ; X == "yes") -> askIfAmbitiousMovieIsPreferred(yes);
    (X == "n" ; X == "no") -> askIfAmbitiousMovieIsPreferred(no);
    write("\nInavlid input\n"),fail).

rejectMoviesOfGenre(Genre):-
    rejectMovie(X), movieOfGenre(X, Genre).

/* years filtering */
whichYearsAreAcceptable() :-
    askForYearRange(),
    rejectMovies(ListOfMovies).

moviesOutsideYearRange(ListOfMovies, MinYear, MaxYear) :-
    b_getval(global_movies_count, X), addMoviesToListByYear(X - 1, ListOfMovies, MinYear, MaxYear).

addMoviesToListByYear(Current, ListOfMovies, MinYear, MaxYear) :- 
    movieCreatedInYear(Current, Year), 
    Year < MinYear || Year > MaxYear,
    addMoviesToListByYear(Current - 1, [Current|ListOfMovies], MinYear, MaxYear).

addMoviesToListByYear(Current, ListOfMovies, MinYear, MaxYear) :-
    movieCreatedInYear(Current, Year),
    Year > MinYear || Year < MaxYear,
    addMoviesToListByYear(Current - 1, ListOfMovies, MinYear, MaxYear).

askForYearRange() :- 
    write("Specify years range for movie"),
    nl,
    write("Specify start year"),
    nl,
    read(MinYear),
    nl,
    write("Specify end year"),
    nl,
    read(MaxYear),
    moviesOutsideYearRange(ListOfMovies, MinYear, MaxYear).

addMoviesToListByYear(-1, [], MinYear, MaxYear).

/* Movie duration filter  */
whatDurationIsAccpetable() :- 
    askForDurationRange(),
    rejectMovies(ListOfMovies).

askForDurationRange() :- 
    write("Specify movie duration range"),
    nl,
    write("Specify min duration for the movie")
    nl,
    read(MinDuration),
    nl,
    write("Specify max duration for the movie"),
    nl,
    read(MaxDuration),
    moviesOutsideRange(ListOfMovies, MinDuration, MaxDuration).

moviesOutsideDurationRange(ListOfMovies, MinDuration, MaxDuration) :-
    b_getval(global_movies_count, X), addMoviesToListByYear(X - 1, ListOfMovies, MinDuration, MaxDuration).

addMoviesToListByDuration(Current, ListOfMovies, MinDuration, MaxDuration) :- 
    movieOfDuration(Current, Duration), 
    Duration < MinDuration || Duration > MaxDuration,
    addMoviesToListByYear(Current - 1, [Current|ListOfMovies], MinDuration, MaxDuration).

addMoviesToListByDuration(Current, ListOfMovies, MinDuration, MaxDuration) :-
    movieOfDuration(Current, Duration), 
    Duration > MinDuration || Duration < MaxDuration,
    addMoviesToListByYear(Current - 1, ListOfMovies, MinDuration, MaxDuration).

addMoviesToListByDuration(-1, [], MinDuration, MaxDuration).

/* Continent filtering */

whichContinentsAreAcceptable() :-
    askIfEuropeanMoviesAreAcceptable(),
    askIfAmericanMoviesAreAcceptable(),
    askIfAsianMoviesAreAcceptable(),
    askIfAfricanMoviesAreAcceptable().

askIfEuropeanMoviesAreAcceptable() :- 
    askForContinent("Europe"),
    rejectMovieFromContinent("Europe").

askIfAsianMoviesAreAcceptable() :- 
    askForContinent("Asia"),
    rejectMovieFromContinent("Asia").

askIfAfricanMoviesAreAcceptable() :- 
    askForContinent("Africa"),
    rejectMovieFromContinent("Africa").

askIfAmericanMoviesAreAcceptable() :- 
    askForContinent("America"),
    rejectMovieFromContinent("America-Pn"),
    rejectMovieFromContinent("America-Pd").

askForContinent(Continent) :- 
    write("Do you like movies from: "),
    write(Continent),
    write(" (y/n) ?"),
    nl,
    read(X),
    ((X == "n" ; X == "no") -> rejectMovieFromContinent(Continent)).

rejectMovieFromContinent(Continent) :- 
    rejectMovie(X), 
    belongsToContinent(Country, Continent).

/* propose movies */
propositionsPart() :- 
    offerByKeywords().

offerByKeywords() :- 
    askForKeyword(Keyword). 

askForKeyword(Keyword) :- 
    write("Are you interested in: "),
    write(Keyword),
    write(" (y/n) ?"),
    nl,
    read(X),
    ((X == "n" ; X == "no") -> rejectMovieWithKeyword(Keyword);
    (X == "y"; X == "yes") -> proposeMoviesForKeyword(Keyword);
    write("\nInavlid input\n"),fail).
 
rejectMovieWithKeyword(Keyword) :-
    movieWithPlotKeyword(X, Keyword), rejectMovie(X).

proposeMoviesForKeyword(Keyword) :-
   movieWithPlotKeyword(MovieId, Keyword), acceptableMovie(MovieId).

acceptableMovie(MovieId) :-
    write("\n Watch: "), write(HyperLink), movieHyperlink(MovieId, HyperLink).

