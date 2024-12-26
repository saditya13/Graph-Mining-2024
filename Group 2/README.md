Outputs are present in the results/ folder

## Setup

### Environment
```
conda create --name env_name python=3.9 --solver=libmamba -y
conda activate env_name
python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
python -m pip install torch-geometric
python -m pip install transformers
```

### Dataset
Get the cora dataset from [https://github.com/XiaoxinHe/TAPE](https://github.com/XiaoxinHe/TAPE) and place it in the `datasets` folder

### Bugfix
Replace `[conda path]/envs/[env name]/lib/python3.9/site-packages/transformers/models/deberta/modeling_deberta.py` with the `modeling_deberta.py` file in this repo. See [https://github.com/huggingface/transformers/pull/35336] (this PR) for more details

## Run
BERT:
```
python finetune_lm.py --lm_type bert --epochs 4 --lr 5e-5 --batch_size 6
```

SentenceBERT:
```
python finetune_lm.py --lm_type sentencebert --epochs 4 --lr 5e-5 --batch_size 6
```

Deberta:
```
python finetune_lm.py --lm_type deberta --epochs 4 --lr 2e-5 --batch_size 6 --weight_decay 0

```