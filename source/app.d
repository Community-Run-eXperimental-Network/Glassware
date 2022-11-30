import std.stdio;

import vibe.d;
import std.json;
import std.string;
import std.net.curl;
import std.base64;

string edbBaseURL = "https://codeberg.org/api/v1/repos/crxn/entitydb/";

/** 
 * Get the networks registered
 *
 * Returns: A <code>string[]</code> containing a list of all
 * registered networks
 */
string[] fetchNetworks()
{
	string[] networks;

	JSONValue jsonParsed;
	jsonParsed = parseJSON(get(edbBaseURL~"contents"));  // TODO: Handle CurlException

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

	return networks;
}


JSONValue fetchNetwork(string filename)
{
	JSONValue jsonParsed;

	jsonParsed = parseJSON(get(edbBaseURL~"contents"));  // TODO: Handle CurlException

	return jsonParsed;
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
			JSONValue jsonParsed;
			jsonParsed = parseJSON(get(edbBaseURL~"contents")); // TODO: Handle CurlException

			

			// Extract the data (decode base64-encoded data)
			string base64Data = networkData["content"].str();

			string contents = cast(string)Base64.decode(base64Data);
			JSONValue networkContents = parseJSON(contents);

			networkData = jsonParsed;
		}
		catch(JSONException e)
		{
			// TODO: Handle this
		}
		catch(CurlException e)
		{
			// TODO: Handle this
		}
	}
}

void main(string[] args)
{
	writeln("Edit source/app.d to start your project.");

	// TODO: Add command-line handling here and configurtion file parsing

	
	// Fetch list of all networks
	string[] networks = fetchNetworks();

	writeln("Found networks: "~to!(string)(networks));

	foreach(string network; networks)
	{
		Network networkFetched = new Network(network);
		writeln(networkFetched);
	}

	// Start the web server
	// runApplication();
}
