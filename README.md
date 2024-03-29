# Civo Navigate Europe 2023

![slide](https://github.com/rytswd/civo-navigate-eu-2023/assets/23435099/4cd901ec-f942-44e8-82f3-2e17dd3d2930)

> Date: 5th September, 2023
>
> Title: **Multi-Cluster Observability with Service Mesh: Navigating the Sea of
> Metrics**
>
> Presented by [@rytswd](https://github.com/rytswd)

Official Website: https://www.civo.com/navigate/schedule

Original Recording: https://youtu.be/BAubdQezZWE?si=D1whrHt_oPw1WSdU

Original Slide: https://dub.sh/civo-navigate-eu-2023-mco

Related Talk:
[Multi-Cluster Observability with Service Mesh - That Is a Lot of Moving Parts!?](https://github.com/rytswd/kubecon-eu-2023)
from KubeCon EU 2023

## 🌄 About This Repository

This repository holds the supplementary materials for my talk at Civo Navigate
Europe 2023.

- Demo Steps and Details
- References

### About Demo

Thanks to Civo, we can spawn a real cluster for testing.

There are a few ways to go through the demo steps.

- Open up [demo.org](/demo.org) and follow each step
- Run [demo.sh](/demo.sh) -- ℹ️ NOTE: This is WIP.
- Using Emacs with Org Babel Execute

For my talk, I use Emacs because that allows me to simply execute without any
typing.

---

The demo during the talk was fully based on the input in this repository. You
should be able to replicate the same setup following the steps detailed in this
repository.

### Why X? Why Not Y?

I designed my talk specifically on navigating through the complexity around
multi-cluster observability. The solutions such as `istioctl` provide friendly
UX for Istio management, but from my own experience, it is crucial to understand
those "implementation details" in order to handle even more complex scenarios.

The demo was meant to be something anyone can replicate in their own
environment. Once you follow the demo details, you should be able to see the
exact definitions of the deployments, and add extra tooling such as GitOps to
help manage the complexity.

## 🌅 Contents

### Prerequisites

In order to run through the demo steps, you will need the following tools:

- Docker
- `kubectl`
- `kustomize`
- `helm`

If you are to use KinD clusters instead of Civo, you will need `kind` as well.
Also, please note that having 3 KinD clusters will require some significant
compute resource on your machine.

### Detailed Steps

Please check out [demo.org](demo.org) for details.

### Clean Up

If you followed the demo steps above using KinD, you can clean up by simply removing the clusters.

```sh
{
    kind delete cluster --name cluster-1
    kind delete cluster --name cluster-2
    kind delete cluster --name cluster-3
}
```

If you followed the demo steps with Civo clusters, you can either use Civo console, or CLI to delete the clusters.

### Troubleshooting

If you found any misbehaviour with the setup, please feel free to create an issue. While I'm not intending to maintain with the latest details here, I still check activities and may be able to help.
