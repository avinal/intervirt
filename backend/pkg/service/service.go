package service

import (
	"context"

	"k8s.io/api/core/v1"
	nv1 "k8s.io/api/networking/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
	"kubevirt.io/client-go/kubecli"
)

func CreateServiceForVM(vmName, namespace string, client kubecli.KubevirtClient) (string, error) {
	service := &v1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      vmName + "-service",
			Namespace: namespace,
		},
		Spec: v1.ServiceSpec{
			Selector: map[string]string{
				"vm.kubevirt.io/name": vmName,
			},
			Ports: []v1.ServicePort{
				{
					Protocol: v1.ProtocolTCP,
					Port:     80,
					TargetPort: intstr.IntOrString{
						IntVal: 80,
					},
				},
			},
		},
	}

	svc, err := client.CoreV1().Services(namespace).Create(context.TODO(), service, metav1.CreateOptions{})
	if err != nil {
		return "", err
	}

	return svc.Name, nil
}

func CreateIngressForVM(vmiName, namespace string, client kubecli.KubevirtClient) (string, error) {
	ingressName := vmiName + "-ingress"

	ingress := &nv1.Ingress{
		ObjectMeta: metav1.ObjectMeta{
			Name:      ingressName,
			Namespace: namespace,
		},
		Spec: nv1.IngressSpec{
			Rules: []nv1.IngressRule{
				{
					IngressRuleValue: nv1.IngressRuleValue{
						HTTP: &nv1.HTTPIngressRuleValue{
							Paths: []nv1.HTTPIngressPath{
								{
									Path: "/ttyd/" + vmiName,
									Backend: nv1.IngressBackend{
										Service: &nv1.IngressServiceBackend{
											Name: vmiName + "-service",
											Port: nv1.ServiceBackendPort{
												Number: 80,
											},
										},
									},
									PathType: &[]nv1.PathType{
										nv1.PathTypePrefix,
									}[0],
								},
							},
						},
					},
				},
			},
		},
	}

	createdIngress, err := client.NetworkingV1().Ingresses(namespace).Create(context.TODO(), ingress, metav1.CreateOptions{})
	if err != nil {
		return "", err
	}

	return createdIngress.Name, nil
}
