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

public final class Person
{
	private JSONValue personBlock;
	private string name, email, gpgKey;

	this(JSONValue personBlock)
	{
		this.personBlock = personBlock;
		initData(personBlock);
	}

	private void initData(JSONValue personBlock)
	{
		try
		{
			name = personBlock["name"].str();
			email = personBlock["email"].str();
			gpgKey = personBlock["gpg"].str();
		}
		catch(JSONException e)
		{
			// TODO: Handle error
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
			JSONValue jsonParsed;
			jsonParsed = parseJSON(get(edbBaseURL~"contents/"~networkName~".json")); // TODO: Handle CurlException

			

			// Extract the data (decode base64-encoded data)
			string base64Data = jsonParsed["content"].str();

			string contents = cast(string)Base64.decode(base64Data);
			JSONValue networkContents = parseJSON(contents);

			writeln(networkContents.toPrettyString());

			networkData = networkContents;
		}
		catch(JSONException e)
		{
			// TODO: Handle this
			writeln(e);
		}
		catch(CurlException e)
		{
			// TODO: Handle this
			writeln(e);
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
		Person person = null;

		try
		{
			person = new Person(networkData["person"]);
		}
		catch(JSONException e)
		{
			writeln("Failed to fetch person details for network '"~networkName~"'");
		}


		return person;
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

void main(string[] args)
{
	

	// Start the web server
	runApplication();
}
