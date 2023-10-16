package models

type CreateVMRequest struct {
	VMName    string `json:"vm_name"`
	ImageName string `json:"image_name"`
	Memory    string `json:"memory"`
}

type CreateVMResponse struct {
	VMName string `json:"vm_name"`
}

type DeleteVMRequest struct {
	VMName string `json:"vm_name"`
}

type DeleteVMResponse CreateVMResponse

type GetVMTerminalRequest struct {
	VMName string `json:"vm_name"`
}

type GetVMTerminalResponse struct {
	Url string `json:"url"`
}