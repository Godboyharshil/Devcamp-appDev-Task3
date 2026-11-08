import 'package:flutter/material.dart';
import 'api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<Map<String, dynamic>> getData({int page = 1, bool search = false, String? movie}) async {
  http.Response response;
  if (search==false){
    response = await http.get(Uri.parse('https://api.themoviedb.org/3/trending/movie/day?api_key=$apiKey&page=$page'));}
  else{
    response = await http.get(Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$movie&page=$page'));
  }
  if (response.statusCode == 200) {
    String data = response.body;
    var decodedData = jsonDecode(data);
    return(decodedData) as Map<String, dynamic>;
  } else {
    return({'error': response.statusCode});
  }
}
bool isFavorite(int movieId, List<Map<String, dynamic>> favorite) {
  for (var i = 0; i < favorite.length; i++) {
    if (favorite[i]['id'] == movieId) {
      return true;
    }
  }
  return false;
}
void main() {

  runApp(const MyApp());
}
class Movie_Short extends StatefulWidget {
  Movie_Short({super.key, required this.results, this.favorite});
  final Map<String, dynamic> results;
  final List<Map<String, dynamic>>? favorite;

  @override
  State<Movie_Short> createState() => _Movie_ShortState();
}

class _Movie_ShortState extends State<Movie_Short> {

  @override
  Widget build(BuildContext context) {
    bool Favorite = isFavorite(widget.results['id'], widget.favorite ?? []);
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[800]!, width: 1)
          
        ),
        padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => detailPage(results: widget.results),
                ),
              );
            },
          child: SizedBox(
            width: 200,
            height: 250,
            child: Image.network('https://image.tmdb.org/t/p/w500${widget.results['poster_path']}', fit: BoxFit.cover,
            loadingBuilder:(context,child,progress){
              if (progress==null){return child;}
              return const Center(child: CircularProgressIndicator());
            },
            ),
          ),
          ),
          Text(""),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => detailPage(results: widget.results),
                    ),
                  );
                },
                child: Text('${widget.results['title']}', style:TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: Icon(Favorite ? Icons.favorite : Icons.favorite_border,
              color: Favorite ? Colors.red : Colors.white),
              onPressed:(){
                setState(() {Favorite = !Favorite;});
                if (Favorite){
                  widget.favorite?.add(widget.results);
                }
                else{
                  widget.favorite?.removeWhere((i) => i['id'] == widget.results['id']);
                }
    
              })
            ],
          ),
          Text('${widget.results['release_date']}', style:TextStyle(color: Colors.white, fontSize: 16)),
          Text('${widget.results['overview']}', style:TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
}}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool favorited=false;
  List<Map<String, dynamic>>? favorite=[];
  String? question;
  bool searched=false;
  bool searching=false;
  TextEditingController searchController = TextEditingController();
  TextEditingController pageController = TextEditingController();
  Map<String, dynamic>? data = {"results":[]};
  Future<void> loadPage({int page=1, bool search=false, String? movie}) async {
    final result = await getData(page: page, search: search, movie: movie);
    if (!mounted)
    { return;}
    setState(() {data = result;});
  }
  @override
  void initState() {
    super.initState();
    loadPage(page:1);
  }

  @override
  Widget build(BuildContext context) {
    if (data?["results"] != null && (data?["results"].isNotEmpty))
    {return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions:[
          Row(
            children: [
              IconButton(icon:Icon(searching?Icons.close : Icons.search),
              onPressed: (){
                setState((){
                  searching=!searching;
                  if (!searching){
                    searchController.clear();
                  }
                });
              },),
              IconButton(icon : Icon(Icons.favorite),
              onPressed: (){
                setState((){
                  favorited=true;
                  data?["results"] = favorite;
                  });
                
              },),
            ],
          )
        ],
        backgroundColor: Colors.blue,
        title: searching ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search Movies',
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
          onSubmitted: (query) => {
            loadPage(page:1, search:true, movie:query),
            setState((){
              searched=true;
              question=query;
              searching=false;
              favorited=false;
            })
          },
        ) : 
        
            TextButton(child:Text("Movie App"),
            onPressed: (){
              loadPage(page:1);
              setState((){
                searched=false;
                searching=false;
                favorited=false;
                searchController.clear();
              });
              },
            ),
          
        
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if(!favorited)
            Container(
            margin: EdgeInsets.all(16.0),
            child: 
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: pageController,
                decoration: InputDecoration(
                  hintText: 'Enter Page NO.',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                )
                ),
            
          ),
            if(!favorited)
            ElevatedButton(
              onPressed: () {
                
                int page = int.tryParse(pageController.text) ?? 1;
                if (searched==false){
                if (page > 0 && page <= data!['total_pages']){
                loadPage(page:page);}
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Page number must be between 1 and ${data!['total_pages']}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }}
                else{
                  if (page > 0 && page <= data!['total_pages']){
                loadPage(page:page, search: true, movie: question);}
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Page number must be between 1 and ${data!['total_pages']}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                }
              },
              child: const Text('Find Page'),
            ),
            for (var i=0; i<data?['results'].length; i++)
              Movie_Short(results : data!['results'][i], favorite: favorite),
            if (!favorited)
            Padding(
              padding: EdgeInsets.all(25.0),
              child: Text('Page ${data?['page']} of ${data?['total_pages']}', style: TextStyle(color: Colors.white, fontSize: 16)),
              
            )
          ],
        ),
      ),
      
    );
  }
  else if (data?["results"].isEmpty && data?["total_results"]==0){
    return Scaffold(
      appBar: AppBar(
        actions:[
          Row(
            children: [
              IconButton(icon:Icon(searching?Icons.close : Icons.search),
              onPressed: (){
                setState((){
                  searching=!searching;
                  if (!searching){
                    searchController.clear();
                  }
                });
              },),
              IconButton(icon : Icon(Icons.favorite),
              onPressed: (){
                setState((){
                  favorited=true;
                  data?["results"] = favorite;
                  });
                
              },),
            ],
          )
        ],
        backgroundColor: Colors.blue,
        title: searching ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search Movies',
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
          onSubmitted: (query) => {
            loadPage(page:1, search:true, movie:query),
            setState((){
              searched=true;
              question=query;
              searching=false;
              favorited=false;
            })
          },
        ) : 
        
            TextButton(child:Text("Movie App"),
            onPressed: (){
              loadPage(page:1);
              setState((){
                searched=false;
                searching=false;
                favorited=false;
                searchController.clear();
              });
              },
            ),
          
        
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No Such Movies available', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('Please Retry with a different movie name', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text("$data", style: TextStyle(color: Colors.white, fontSize: 16)),

          ],
        ),
      ),
    );
  }
  
  else{
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  }
  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    super.dispose();
    }
}

class detailPage extends StatelessWidget {
  detailPage({super.key, required this.results});
  final Map<String, dynamic> results;

  

  final Map<int,String>? genreMap= {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions:[
          
        ],
        backgroundColor: Colors.blue,
        title: TextButton(child:Text("Movie App"),
            onPressed: (){
              Navigator.pop(context);
              },
            ),
          
        
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('${results['title']}', style:TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              width: 200,
              height: 250,
              child: Image.network('https://image.tmdb.org/t/p/w500${results['poster_path']}', fit: BoxFit.cover,
              loadingBuilder:(context,child,progress){
                if (progress==null){return child;}
                return const Center(child: CircularProgressIndicator());
              },
              ),
            ),
            Text('Release Date: ${results['release_date']}', style:TextStyle(color: Colors.white, fontSize: 16)),
            Text('Genres: ${results['genre_ids']?.map((id) => genreMap?[id] ?? '').join(', ')}', style:TextStyle(color: Colors.white, fontSize: 16)),
            Text('Overview: ${results['overview']}', style:TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
