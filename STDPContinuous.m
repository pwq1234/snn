function [neuron]=STDPContinuous(neuron,spikeList,afferentList,dump,beSmart,PARAM)
%  *  This code was used in:
%  *  Masquelier T, Guyonneau R, Thorpe SJ (2008). Competitive STDP-based Spike Pattern Learning. Neural Computation: in press.
%  *  Feel free to use and modify but please cite us.
%  *  timothee.masquelier@alum.mit.edu
%  *
%  *  Arguments:
%  *      neuron: structure array with fields:
%  *          weights (double): array of synaptic weights (size=number of afferents)
%  *          epspAmplitude (double): array of EPSP magnitudes (only zeros if starting from the scratch)
%  *          epspTime (double): array of EPSP times (only zeros if starting from the scratch)
%  *          epspAfferent (uint16): array of EPSP afferent indexes (only zeros if starting from the scratch)
%  *          nEpsp (double): current number of EPSP (which can be bigger that the size of the 3 above mentioned arrays. We use cycling indexes and erase old (no longer efficient) EPSP). Zero if starting from the scratch.
%  *          ipspTime (double): array of IPSP times (only zeros if starting from the scratch)
%  *          nIpsp (double): current number of IPSP (which can be bigger that the size of the ipspTime array. We use cycling indexes and erase old (no longer efficient) IPSP). Zero if starting from the scratch.
%  *          nextFiring (double): next scheduled firing time, taken the current EPSPs into account. Inf if starting from the scratch.
%  *          firingTime (double): array of past firing times (only zeros if starting from the scratch).
%  *          nFiring (double): number of stored past firing times in the above mentioned array (which must be bigger). Zero if starting from the scratch.
%  *          alreadyDepressed (logical): array of flags saying if a given afferent has already been depressed (nearest spike approximation for LTD)(size=number of afferents). All false if starting from the scratch.
%  *          maxPotential (double): upper bound on potential wich could be reached with the current EPSPs. Avoid unnecessary computation if threshold is not reachable. Zero if starting from the scratch.
%  *          trPot (double): MUST BE 0 (not used any longer)
%  *      spikeList (double): array of input spike times in s.
%  *      afferentList (uint16): array of input spike afferent indexes.
%  *      dump (logical): if true will dump potential as a function of time in a file called dump.txt
%  *      beSmart (logical): save time by not computing the potential when it is estimated that the threshold cannot be reached. Rigorous only when no inhibition, and no PSP Kernel. Otherwise use at your own risks...
%  *      PARAM: structure with fields:
%  *          stdp_t_pos (double): tau^+ STDP time constant in s (for LTP)
%  *          stdp_t_neg (double): tau^- STDP time constant in s (for LTD)
%  *          stdp_a_pos (double): a^+ STDP constant (for LTP)
%  *          stdp_a_neg (double): a^- STDP constant (for LTD). Should be <0
%  *          stdp_cut (double): time delay (in number of time constants) for STDP modifications to be considered negligible (eg 7)
%  *          minWeight (double): lower bound for weight (usually 0). Upper bound is 1-minWeight
%  *          tmpResolution (double): temporal resolution in s
%  *          epspKernel (double): array containing the EPSP kernel (should be scaled so that the max is 1)
%  *          epspMaxTime (double): index of the max in above mentioned kernel
%  *          usePssKernel (logical): use or not the post synaptic spike kernel (negative spike after potential that follows the pulse)
%  *          pssKernel (double): array containing the PSS kernel
%  *          ipspKernel (double): array containing IPSP kernel (positive, by convention. should be scaled so that the max is 1)
%  *          inhibStrength (double): inhibition strength (in fraction of threshold. positive, by convention)
%  *          nAfferent (double): number of afferents
%  *          threshold (double): neurons' threshold (arbitrary units)
%  *          refractoryPeriod (double): refractory period in s, during which the neuron is not allowed to fire (but does integrate the EPSPs)
%  *          fixedFiringMode (logical): use or not the fixed firing mode, in which periodic firing is imposed
%  *          fixedFiringLatency (double): in fixedFiringMode specify the latency of the first firing
%  *          fixedFiringPeriod (double): in fixedFiringMode specify the period of the first firing