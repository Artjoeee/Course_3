#include "tests.h"

using namespace ht;

namespace tests
{
	BOOL test1(HtHandle* htHandle)
	{
		Element* element = new Element("Test 1", 10, "Test 1", 10);

		insert(htHandle, element);

		if (insert(htHandle, element))
		{
			return false;
		}

		return true;
	}

	BOOL test2(HtHandle* htHandle)
	{
		Element* element = new Element("Test 2", 10, "Test 2", 10);

		insert(htHandle, element);

		remove(htHandle, element);

		if (remove(htHandle, element))
		{
			return false;
		}

		return true;
	}

	BOOL test3(HtHandle* htHandle)
	{
		Element* insertEl = new Element("Test 3", 10, "Test 3", 10);

		insert(htHandle, insertEl);

		Element* getEl = get(htHandle, new Element("Test 3", 10));

		if (
			getEl == NULL ||
			insertEl->keyLength != getEl->keyLength ||
			memcmp(insertEl->key, getEl->key, insertEl->keyLength) != NULL ||
			insertEl->payloadLength != getEl->payloadLength ||
			memcmp(insertEl->payload, getEl->payload, insertEl->payloadLength) != NULL
			)
		{
			return false;
		}

		return true;
	}

	BOOL test4(HtHandle* htHandle)
	{
		Element* element = new Element("Test 4", 10, "Test 4", 10);

		insert(htHandle, element);

		remove(htHandle, element);

		if (get(htHandle, element) != NULL)
		{
			return false;
		}

		return true;
	}

	BOOL test5(HtHandle* htHandle)
	{
		Element* element = new Element("Test5", 10, "OldData", 10);

		insert(htHandle, element);

		const char* newPayload = "NewData";

		update(htHandle, element, newPayload, 7);

		Element* getEl = get(htHandle, new Element("Test5", 10));

		if (
			getEl == NULL ||
			memcmp(getEl->payload, newPayload, 7) != 0
			)
		{
			return false;
		}

		return true;
	}

}