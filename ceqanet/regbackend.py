# regbackend.py
import profile

def user_created(sender, user, request, **kwargs):
	form = UserRegistrationForm(request.POST)
	data = profile.Profile(user=user)
	data.conphone = form.data["conphone"]
	data.save()

from registration.signals import user_registered
user_registered.connect(user_created)