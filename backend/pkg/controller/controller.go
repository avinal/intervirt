package controller

import (
	"context"

	"github.com/avinal/intervirt/backend/pkg/service"
	"github.com/spf13/pflag"
	k8sv1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	v1 "kubevirt.io/api/core/v1"
	"kubevirt.io/client-go/kubecli"
)

func CreateVMWithKubeVirt(vmName, imagename, memory string) (string, error) {
	clientconfig := kubecli.DefaultClientConfig(&pflag.FlagSet{})

	namespace, _, err := clientconfig.Namespace()
	if err != nil {
		return "", err
	}

	virtClient, err := kubecli.GetKubevirtClientFromClientConfig(clientconfig)
	if err != nil {
		return "", err
	}

	userData := `#cloud-config
user: fedora
password: fedora
chpasswd: { expire: False }
packages:
  ttyd
runcmd:
  - ["nohup", "ttyd", "-p", "80", "bash"]
`

	falseVal := true
	vm := &v1.VirtualMachine{
		ObjectMeta: metav1.ObjectMeta{
			Name:      vmName,
			Namespace: namespace,
		},
		Spec: v1.VirtualMachineSpec{
			Running: &falseVal,
			Template: &v1.VirtualMachineInstanceTemplateSpec{
				Spec: v1.VirtualMachineInstanceSpec{
					Domain: v1.DomainSpec{
						Devices: v1.Devices{
							Disks: []v1.Disk{
								{
									Name: "containerdisk",
									DiskDevice: v1.DiskDevice{
										Disk: &v1.DiskTarget{
											Bus: "virtio",
										},
									},
								},
								{
									Name: "cloudinitdisk",
									DiskDevice: v1.DiskDevice{
										Disk: &v1.DiskTarget{
											Bus: "virtio",
										},
									},
								},
							},
							Interfaces: []v1.Interface{
								{
									Name: "default",
									InterfaceBindingMethod: v1.InterfaceBindingMethod{
										Masquerade: &v1.InterfaceMasquerade{},
									},
								},
							},
						},
						Resources: v1.ResourceRequirements{
							Requests: k8sv1.ResourceList{
								k8sv1.ResourceMemory: resource.MustParse(memory),
							},
						},
					},
					Networks: []v1.Network{
						{
							Name: "default",
							NetworkSource: v1.NetworkSource{
								Pod: &v1.PodNetwork{},
							},
						},
					},
					Volumes: []v1.Volume{
						{
							Name: "containerdisk",
							VolumeSource: v1.VolumeSource{
								ContainerDisk: &v1.ContainerDiskSource{
									Image:           imagename,
									ImagePullPolicy: k8sv1.PullAlways,
								},
							},
						},
						{
							Name: "cloudinitdisk",
							VolumeSource: v1.VolumeSource{
								CloudInitNoCloud: &v1.CloudInitNoCloudSource{
									UserData: userData,
								},
							},
						},
					},
				},
			},
		},
	}

	vmCreated, err := virtClient.VirtualMachine(namespace).Create(context.Background(), vm)
	if err != nil {
		return "", err
	}

	return vmCreated.Name, nil
}

func DeleteVirtualMachine(vmName string) error {
	clientconfig := kubecli.DefaultClientConfig(&pflag.FlagSet{})

	namespace, _, err := clientconfig.Namespace()
	if err != nil {
		return err
	}

	virtClient, err := kubecli.GetKubevirtClientFromClientConfig(clientconfig)
	if err != nil {
		return err
	}

	err = virtClient.VirtualMachine(namespace).Delete(context.Background(), vmName, &metav1.DeleteOptions{})
	if err != nil {
		return err
	}
	return nil
}

func GetVMTerminal(vmName string) (string, error) {
	clientconfig := kubecli.DefaultClientConfig(&pflag.FlagSet{})

	namespace, _, err := clientconfig.Namespace()
	if err != nil {
		return "", err
	}

	virtClient, err := kubecli.GetKubevirtClientFromClientConfig(clientconfig)
	if err != nil {
		return "", err
	}

	if _, err := service.CreateServiceForVM(vmName, namespace, virtClient); err != nil {
		return "", err
	}

	ingress, err := service.CreateIngressForVM(vmName, namespace, virtClient)
	if err != nil {
		return "", err
	}

	return ingress, nil

}
