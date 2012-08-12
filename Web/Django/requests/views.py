from django.http import HttpResponse
from requests.models import Request
from django.utils import timezone
from django.template import Context, loader
import os


def homepage(request):
	pageReq = Request(device='iOS, Android, Mac, PC, Natty Narwal',date=timezone.now())
	pageReq.save()
	temp = loader.get_template('iJumbo.html')
	c = Context({
	})
	return HttpResponse(temp.render(c))

def static(request,path):
	pass