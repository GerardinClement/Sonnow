import json
from django.http import JsonResponse

def decode_json_body(request):
	try:
		data = json.loads(request.body.decode("utf-8"))

		for key, value in data.items():
			if isinstance(value, int):
				data[key] = str(value)

		return data
	except json.JSONDecodeError as e:
		return JsonResponse(data={'error': "Invalid JSON format"}, status=406)
	except Exception as e:
		return JsonResponse(data={'error': "Error during the decoding of the JSON"}, status=406)