module source.app;

import std.stdio;

import vibe.d;
import std.json;
import std.string;
import std.net.curl;
import std.base64;
import source.exceptions;

string edbBaseURL = "https://codeberg.org/api/v1/repos/crxn/entitydb/";

/** 
 * Get the networks registered
 *
 * Returns: A <code>string[]</code> containing a list of all
 * registered networks
 */
string[] fetchNetworks()
{
	// Collected network information
	string[] networks;

	// Fetch the networks
	string networkData;
	try
	{
		networkData = cast(string)get(edbBaseURL~"contents");
	}
	catch(CurlException e)
	{
		throw new GlasswareException(GlasswareError.NETWORK_ERROR);
	}

	try
	{
		JSONValue jsonParsed;
		jsonParsed = parseJSON(networkData);  // TODO: Handle CurlException

		foreach(JSONValue networkBlock; jsonParsed.array())
		{
			string filename = networkBlock["name"].str();

			// It's only a network if the filename ends in `.json`
			if(endsWith(filename, ".json"))
			{
				// writeln("Found network: "~filename);
				networks ~= split(filename, ".")[0];
			}
			
		}
	}
	catch(JSONException e)
	{
		throw new GlasswareException(GlasswareError.JSON_PARSING_ERROR);
	}
	

	return networks;
}


JSONValue fetchNetwork(string filename)
{
	JSONValue jsonParsed;

	jsonParsed = parseJSON(get(edbBaseURL~"contents"));  // TODO: Handle CurlException

	return jsonParsed;
}

public final class Person
{
	private JSONValue personBlock;
	protected string name, email, gpgKey;

	private this() {}

	/** 
	 * Provided the person block as JSON this will attempt
	 * to parse it, if so returning a <code>Person</code> object. If a
	 * failure occurs during parsing then <code>null</code>
	 * is returned
	 *
	 * Params:
	 *   personBlock = The JSON-encoded person block
	 * Returns: The Person object representing such information
	 */
	public static Person getPerson(JSONValue networkData)
	{
		try
		{
			Person person = new Person();

			JSONValue personBlock = networkData["person"];

			person.name = personBlock["name"].str();
			person.email = personBlock["email"].str();
			person.gpgKey = personBlock["gpg"].str();

			return person;
		}
		catch(JSONException e)
		{
			return null;
		}
	}
}

public final class Network
{
	private string networkName;
	private JSONValue networkData;
	
	this(string networkName)
	{
		this.networkName = networkName;

		// Fetch the data
		initData(networkName);
	}

	private void initData(string networkName)
	{
		try
		{
			writeln("bruh1");

			JSONValue jsonParsed;
			jsonParsed = parseJSON(get(edbBaseURL~"contents/"~networkName~".json")); // TODO: Handle CurlException

			writeln("bruh");

			// Extract the data (decode base64-encoded data)
			string base64Data = jsonParsed["content"].str();

			string contents = cast(string)Base64.decode(base64Data);
			JSONValue networkContents = parseJSON(contents);

			writeln(networkContents.toPrettyString());

			networkData = networkContents;
		}
		catch(CurlException e)
		{
			throw new GlasswareException(GlasswareError.NETWORK_ERROR);
		}
		catch(JSONException e)
		{
			throw new GlasswareException(GlasswareError.JSON_PARSING_ERROR);
		}
			
	}

	/** 
	 * Returns the owner/contact details for this network
	 *
	 * Returns: The <code>Person</code> object representing
	 * this information, <code>null</code> if such information
	 * does not exist
	 */
	public Person getPerson()
	{
		return Person.getPerson(networkData);
	}

	// TODO: We should be throwing our own exceptions
	public string[] getRegisteredRoutes()
	{
		try
		{
			JSONValue routesBlock = networkData["route"];
			
			return routesBlock.object().keys();
		}
		catch(JSONException e)
		{
			throw new GlasswareException(GlasswareError.JSON_PARSING_ERROR);
		}
	}

	public JSONValue getJSON()
	{
		// TOOD: Implement me
		JSONValue netInfo;

		// Compute a list of registered routes
		string[] registeredRoutes;
		try
		{
			registeredRoutes = getRegisteredRoutes();
		}
		catch(GlasswareException e)
		{
			// TODO: Fill in
		}

		netInfo["routes"] = registeredRoutes;




		return netInfo;
	}
}

unittest
{
	writeln("Edit source/app.d to start your project.");

	// TODO: Add command-line handling here and configurtion file parsing

	
	// Fetch list of all networks
	string[] networks = fetchNetworks();

	import std.algorithm;
	assert(equal(networks, ["bandura", "deavmi", "reddawn", "skiqqy", "ty3r0x"]));


	writeln("Found networks: "~to!(string)(networks));

	foreach(string network; networks)
	{
		Network networkFetched = new Network(network);
		writeln(networkFetched);
		writeln("Person info (if any): ", networkFetched.getPerson());
	}
}

public final class Route
{
	// Network this Route belongs to
	private Network network;

	private this(Network network)
	{
		this.network = network;
	}

	public static Route getRoute(Network network, string routeName)
	{
		Route route;

		


		return route;
	}
}

JSONValue makeError(GlasswareError errorCode)
{
	JSONValue errorBlock;
	errorBlock["detail"] = to!(string)(errorCode);
	errorBlock["error"] = errorCode;

	return errorBlock;
}

void getNetworks(HTTPServerRequest request, HTTPServerResponse response)
{
	// Construct the results JSON
	JSONValue results;
	results["status"] = true;

	// Attempt to get the networks
	try
	{
		JSONValue networksBlock;
		networksBlock["networks"] = parseJSON(to!(string)(fetchNetworks()));

		results["response"] = networksBlock;
	}
	catch(GlasswareException e)
	{
		results["status"] = makeError(e.getError());
	}

	response.writeJsonBody(results);
}

// TODO: We should cache all Network objects that are made
// Infact this can be done with making static fetchNetwork, then
// every now and then returns a fresh objetc with a new curl request
void getNetwork(HTTPServerRequest request, HTTPServerResponse response)
{
	// Fetch the query parameters
	auto queryDict = request.query();

	// Get the network name
	string networkName = queryDict["network"];

	// Construct the results JSON
	JSONValue results;
	results["status"] = true;

	// Attempt to get the networks
	try
	{
		// Fetch the network
		Network networkFetched = new Network(networkName);

		// TODO: Implement this
		JSONValue networksBlock;
		networksBlock["network"] = networkFetched.getJSON();

		results["response"] = networksBlock;
	}
	catch(GlasswareException e)
	{
		results["status"] = makeError(e.getError());
	}

	response.writeJsonBody(results);
}

void listRoutes(HTTPServerRequest request, HTTPServerResponse response)
{
	// Fetch the query parameters
	auto queryDict = request.query();

	// Get the network name
	string networkName = queryDict["network"];

	// Construct the results JSON
	JSONValue results;
	results["status"] = true;

	try
	{
		// Fetch the network
		Network networkFetched = new Network(networkName);

		// Get the routes
		string[] networkRoutes = networkFetched.getRegisteredRoutes();
		results["response"] = networkRoutes;
	}
	catch(GlasswareException e)
	{
		results["status"] = makeError(e.getError());
	}

	response.writeJsonBody(results);
}

void webhookHandler(HTTPServerRequest request, HTTPServerResponse response)
{

}

void initializeRoutes(URLRouter router)
{
	// TODO: Fill in routes here

	// 
	router.get("/api/networks/list", &getNetworks);

	// `/api/networks/get?network=<name>`
	router.get("/api/networks/get", &getNetwork);

	// `/api/routes/list?network=<name>`
	router.get("/api/routes/list", &listRoutes);



	// Webhooks routes to alert for changes
	router.post("/api/refresh", &webhookHandler);
}

void main(string[] args)
{
	// TODO: Add command-line handling and configurtion file parsing here

	// Setup the HTTP socket
	HTTPServerSettings httpServerSettings = new HTTPServerSettings();
	httpServerSettings.bindAddresses = ["::"];
	httpServerSettings.port = 8888;

	// Create a new router
	URLRouter router = new URLRouter();

	// Set the router
	initializeRoutes(router);

	// Bind the HTTP server and set the router
	listenHTTP(httpServerSettings, router);

	// Start the web server
	runApplication();
}
