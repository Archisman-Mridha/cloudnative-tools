#! run kubectl proxy before this in a separate terminal
show-kubernetes-dashboard:
#* generate token for admin to access the dashboard
	echo 🔑 use this token to signin -
	kubectl -n kubernetes-dashboard create token admin-service-account

#* open uri in browser
	explorer.exe http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/#/workloads