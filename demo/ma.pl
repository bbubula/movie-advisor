:- ensure_loaded(knowledge_short).
:- ensure_loaded(geo_country).

global_movies_count(25).
maxKeywordsToBeOffered(3).

/* main choose structure */
choose_movie(Description) :- 
    createAcceptableMoviesSet(),
    filterPart(),
    propositionsPart(),
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
    whichGenresAreAcceptable(),
    whatDurationIsAcceptable(),
    whichContinentsAreAcceptable().

/* duration filtering */
askForDurationRange(MinDuration, MaxDuration) :- 
    write("Specify movie duration range"),
    nl,
    write("Specify min duration for the movie"),
    nl,
    read(MinDuration),
    nl,
    write("Specify max duration for the movie"),
    nl,
    read(MaxDuration).

whatDurationIsAcceptable() :- 
    askForDurationRange(MinDuration, MaxDuration),
    moviesOutsideDurationRange(ListOfMovies, MinDuration, MaxDuration),
    rejectMovies(ListOfMovies).

moviesOutsideDurationRange(ListOfMovies, MinDuration, MaxDuration) :-
    global_movies_count(X), getMoviesWithIncorrectDuration(X, ListOfMovies, MinDuration, MaxDuration).

getMoviesWithIncorrectDuration(-1, [], _, _).

getMoviesWithIncorrectDuration(Current, [Current|ListOfMovies], MinDuration, MaxDuration) :- 
    movieOfDuration(Current, Duration), 
    or(Duration < MinDuration, Duration > MaxDuration),
    NewCurrent is Current - 1,
    getMoviesWithIncorrectDuration(NewCurrent, ListOfMovies, MinDuration, MaxDuration).

getMoviesWithIncorrectDuration(Current, ListOfMovies, MinDuration, MaxDuration) :- 
    NewCurrent is Current - 1,
    getMoviesWithIncorrectDuration(NewCurrent, ListOfMovies, MinDuration, MaxDuration).

/* genres filtering */
whichGenresAreAcceptable() :-
    askIfFictionIsPreferred(),
    askIfActionIsPreferred(),
    askIfAmbitiousMovieIsPreferred(),
    askIfEmotionalMovieIsPreffered().

/* continent filtering */
whichContinentsAreAcceptable() :-
    askIfEuropeanMoviesAreAcceptable(),
    askIfAmericanMoviesAreAcceptable(),
    askIfAsianMoviesAreAcceptable(),
    askIfAfricanMoviesAreAcceptable().

askIfEuropeanMoviesAreAcceptable() :- 
    askForContinent("Europe").

askIfAsianMoviesAreAcceptable() :- 
    askForContinent("Asia").

askIfAfricanMoviesAreAcceptable() :- 
    askForContinent("Africa").

askIfAmericanMoviesAreAcceptable() :- 
    askForContinent("America").

askForContinent(Continent) :- 
    write("Do you like movies from: "),
    write(Continent),
    write(" (y/n) ?"),
    nl,
    read(X),
    ((X == y ; X == yes) -> moviesFromContinentPreferred(yes);
    (X == n ; X == no) -> moviesFromContinentPreferred(no, Continent);
    (write("\nInavlid input, once again...\n")), askForContinent()).

moviesFromContinentPreferred(yes).

moviesFromContinentPreferred(no, Continent) :- 
    rejectMoviesFromContinent(Continent).

rejectMoviesFromContinent(Continent) :- 
    moviesFromContinent(ListOfMovies, Continent),
    rejectMovies(ListOfMovies).

moviesFromContinent(ListOfMovies, Continent) :-
    global_movies_count(X), getMoviesFromContinent(X, ListOfMovies, Continent).

getMoviesFromContinent(-1, [], _).

getMoviesFromContinent(Current, [Current|ListOfMovies], Continent) :- 
    movieCreatedInCountry(Current, Country), 
    belongsToContinent(Country, Continent),
    NewCurrent is Current - 1,
    getMoviesFromContinent(NewCurrent, ListOfMovies, Continent).

getMoviesFromContinent(Current, ListOfMovies, Continent) :- 
    NewCurrent is Current - 1,
    getMoviesFromContinent(NewCurrent, ListOfMovies, Continent).

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

/* emotional filter */

askIfEmotionalMovieIsPreffered() :- 
    write("Do you like emotional movies ? (y/n)"),
    nl,
    read(X),
    ((X == y ; X == yes) -> emotionalMoviePreferred(yes);
    (X == n ; X == no) -> emotionalMoviePreferred(no);
    (write("\nInavlid input, once again...\n")), askIfEmotionalMovieIsPreferred()).

emotionalMoviePreferred(no) :-
    rejectMovieOfGenre("Romance"),
    rejectMovieOfGenre("Drama"),
    rejectMovieOfGenre("Thriller").

emotionalMoviePreferred(yes) :-
    rejectMovieOfGenre("Comedy"),
    rejectMovieOfGenre("Family"),
    rejectMovieOfGenre("Animation"),
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi").

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

/* propositionsPart */
propositionsPart() :- 
    maxKeywordsToBeOffered(Count), offerByKeywords(Count).

/* getting list of acceptable movies */
acceptableMovieSet(ListOfMovies) :-
    global_movies_count(X), getAcceptableMovieSet(X, ListOfMovies).

getAcceptableMovieSet(-1, []).

getAcceptableMovieSet(Current, [Current|ListOfMovies]) :- 
    acceptableMovie(Current), 
    NewCurrent is Current - 1,
    getAcceptableMovieSet(NewCurrent, ListOfMovies).

getAcceptableMovieSet(Current, ListOfMovies) :- 
    NewCurrent is Current - 1,
    getAcceptableMovieSet(NewCurrent, ListOfMovies).

/* offering by keywords */
offerByKeywords(Count) :- 
    acceptableMovieSet(ListOfMovies),
    askForKeywords(ListOfMovies, Count). 

askForKeywords([], _).
askForKeywords(_, -1).

askForKeywords([H|T], Current):-
    movieWithPlotKeyword(H, Keyword),
    askForKeyword(Keyword),
    NewCurrent is Current - 1,
    askForKeywords(T, NewCurrent).

askForKeywords([_|T], Current):-
    askForKeywords(T, Current).

askForKeyword(Keyword) :- 
    write("Are you interested with '"),
    write(Keyword),
    write("' (y/n) ?"),
    nl,
    read(X),
    (((X == n ; X == no) -> rejectMoviesWithKeyword(Keyword));
    (X == y; X == yes);
    (write("\nInvalid input. Try again...\n"), askForKeyword(Keyword))).

/* removal based on keyword */
rejectMoviesWithKeyword(Keyword):-
    global_movies_count(X), 
    getMoviesWithKeyword(X, MoviesList, Keyword), 
    rejectMovies(MoviesList).

getMoviesWithKeyword(-1, [], _).

getMoviesWithKeyword(Current, [Current|ListOfMovies], Keyword) :- 
    movieWithPlotKeyword(Current, Keyword), 
    NewCurrent is Current - 1,
    getMoviesWithKeyword(NewCurrent, ListOfMovies, Keyword).

getMoviesWithKeyword(Current, ListOfMovies, Keyword) :- 
    NewCurrent is Current - 1,
    getMoviesWithKeyword(NewCurrent, ListOfMovies, Keyword).


/* util */
or(A, B) :-
    A; B.