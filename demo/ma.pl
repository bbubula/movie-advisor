:- ensure_loaded(knowledge_base).
:- ensure_loaded(geo_country).

debug_enabled(no).
maxKeywordsToBeOffered(5).
maxDirectorsToBeOffered(3).

askYesNoQuestion(Question,X) :-
    jpl_call('javax.swing.JOptionPane','showConfirmDialog',[(@null),Question,'Question',0],X).

askQuestion(Question,X) :-
    jpl_call('javax.swing.JOptionPane','showInputDialog',[(@null),Question,'Question',3],X),
    ((X == (@null)) -> write('\nInavlid input, once again...\n'), askQuestion(Question, X);
    write(X)).

showMessage(Message) :-
    jpl_call('javax.swing.JOptionPane','showMessageDialog',[(@null),Message,'Message',1],X).


/* main choose structure */
choose_movie(Description) :-
    createAcceptableMoviesSet(),
    filterPart(),
    propositionsPart(),
    ((acceptableMovie(Result), movieHasHumanReadableDescription(Result, Description)); noResultFound(Description)),
    atom_concat('', Description, M),
    showMessage(M).

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

rejectMovies([]):-
    global_movies_count(X),
    (debug_enabled(no);(write("ACCEPTABLE: "),showAcceptableIds(X),write("\n"))).

rejectMovies([H|Tail]):-
    rejectMovie(H), 
    rejectMovies(Tail).

showAcceptableIds(-1).
showAcceptableIds(X):-
    acceptableMovie(X),
    write(X),
    write(" "),
    NewX is X -1,
    showAcceptableIds(NewX).

showAcceptableIds(X):-
    NewX is X -1,
    showAcceptableIds(NewX).


/* filtering movies set*/
filterPart() :- 
    whichYearsAreAcceptable(),
    whichGenresAreAcceptable(),
    whatDurationIsAcceptable(),
    whichContinentsAreAcceptable().

/* duration filtering */
askForDurationRange(MinDuration, MaxDuration) :-
    askQuestion('Specify min duration for the movie', Min),
    askQuestion('Specify max duration for the movie', Max),
    atom_number(Min, MinDuration),
    atom_number(Max, MaxDuration).


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
    askForContinent('Europe').

askIfAsianMoviesAreAcceptable() :- 
    askForContinent('Asia').

askIfAfricanMoviesAreAcceptable() :- 
    askForContinent('Africa').

askIfAmericanMoviesAreAcceptable() :- 
    askForContinent('America').

askForContinent(Continent) :- 
    atom_concat('Do you like movies from ', Continent, Q),
    askYesNoQuestion(Q, X),
    ((X == 0) -> moviesFromContinentPreferred(yes);
    ((X == 1) -> moviesFromContinentPreferred(no, Continent));
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
     askQuestion('Specify start year for movie', Min),
     askQuestion('Specify end year for movie', Max),
     atom_number(Min, MinYear),
     atom_number(Max, MaxYear).

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
    askYesNoQuestion('Do you like ambitious movies ?', X),
    ((X == 0) -> ambitiousMoviePreferred(yes);
    ((X == 1) -> ambitiousMoviePreferred(no));
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
     askYesNoQuestion('Do you like action movies ?', X),
     ((X == 0) -> actionPreferred(yes);
    ((X == 1) -> actionPreferred(no));
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
    askYesNoQuestion('Do you like fiction movies ?', X),
    ((X == 0) -> fictionPreferred(yes);
    ((X == 1) -> fictionPreferred(no));
    (write("\nInavlid input, once again...\n")), askIfFictionIsPreferred()).

fictionPreferred(no) :-
    rejectMovieOfGenre("Fantasy"),
    rejectMovieOfGenre("Sci-Fi").

fictionPreferred(yes) :-
    rejectMovieOfGenre("Documentary"),
    rejectMovieOfGenre("History").

/* emotional filter */

askIfEmotionalMovieIsPreffered() :-
    askYesNoQuestion('Do you like emotional movies ?', X),
    ((X == 0) -> emotionalMoviePreferred(yes);
    ((X == 1) -> emotionalMoviePreferred(no));
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

/* -------------------------------------------------- propositionsPart --------------------------------------------------*/
propositionsPart() :-
    offerByKeywords(),
    offerByDirectors().

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
offerByKeywords() :- 
    maxKeywordsToBeOffered(Count), 
    acceptableMovieSet(ListOfMovies),
    askForKeywords(ListOfMovies, Count). 

askForKeywords([], _).
askForKeywords(_, 0).

askForKeywords([H|T], Current):-
    movieWithPlotKeyword(H, Keyword),
    askForKeyword(Keyword),
    NewCurrent is Current - 1,
    askForKeywords(T, NewCurrent).

askForKeywords([_|T], Current):-
    askForKeywords(T, Current).

askForKeyword(Keyword) :-
    atom_concat('Are you interested in ', Keyword, Q),
    askYesNoQuestion(Q, X),
    ((X == 0);
    ((X == 1) -> rejectMoviesWithKeyword(Keyword));
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


/* offering by director */
offerByDirectors() :- 
    maxDirectorsToBeOffered(Count), 
    acceptableMovieSet(ListOfMovies),
    askForDirectors(ListOfMovies, Count).

askForDirectors([], _).
askForDirectors(_, 0).

askForDirectors([H|T], Current):-
    movieDirectedBy(H, Director),
    askForDirector(Director),
    NewCurrent is Current - 1,
    askForDirectors(T, NewCurrent).

askForDirectors([_|T], Current):-
    askForDirectors(T, Current).

askForDirector(Director) :- 
     atom_concat('Do you like ', Director, Q),
     askYesNoQuestion(Q, X),
     ((X == 0);
     ((X == 1) -> rejectMoviesWithDirector(Director));
    (write("\nInvalid input. Try again...\n"), askForDirector(Director))).

/* removal based on director */
rejectMoviesWithDirector(Director):-
    global_movies_count(X), 
    getMoviesDirectedBy(X, MoviesList, Director), 
    rejectMovies(MoviesList).

getMoviesDirectedBy(-1, [], _).

getMoviesDirectedBy(Current, [Current|ListOfMovies], Director) :- 
    movieDirectedBy(Current, Director), 
    NewCurrent is Current - 1,
    getMoviesDirectedBy(NewCurrent, ListOfMovies, Director).

getMoviesDirectedBy(Current, ListOfMovies, Director) :- 
    NewCurrent is Current - 1,
    getMoviesDirectedBy(NewCurrent, ListOfMovies, Director).


/* util */
or(A, B) :-
    A; B.