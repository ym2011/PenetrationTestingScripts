from django import forms

class ScanForm(forms.Form):
    target = forms.CharField(label='target', max_length=100)
