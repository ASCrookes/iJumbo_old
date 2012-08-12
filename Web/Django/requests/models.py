from django.db import models


class Request(models.Model):
	date = models.DateTimeField('date requested')
	device = models.CharField(max_length=200)

	def __unicode__(self):
		return str(self.id)
